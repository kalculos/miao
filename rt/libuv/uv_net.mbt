///|
struct UvNet {
  uv : LibuvRuntime
}

///|
fn UvNet::uv(self : UvNet) -> LibuvRuntime {
  self.uv
}

///|
fn parse_and_convert_addr(
  address : String,
) -> Result[(@net.SockAddrIn, @uv.Sockaddr), @net.NetworkError] {
  let addr = match
    (try? @net.SockAddrIn::parse(address)).map_err(err => @net.NetworkError::InvalidAddress(
      msg="Failed to parse address: \{err}",
    )) {
    Ok(a) => a
    Err(e) => return Err(e)
  }
  let uv_addr = match
    (try? @net.SockAddr::Inet(addr).to_uv()).map_err(err => @net.NetworkError::InvalidAddress(
      msg="Failed to convert address: \{err}",
    )) {
    Ok(a) => a
    Err(e) => return Err(e)
  }
  Ok((addr, uv_addr))
}

///|
pub impl @net.Network for UvNet with dial(self, network, address, options) {
  match network {
    "tcp" => {
      let (addr, _) = match parse_and_convert_addr(address) {
        Ok(result) => result
        Err(e) => return Err(e)
      }
      let handle = match
        (try? @uv.Tcp::new(self.uv.uv)).map_err(err => @net.NetworkError::DeviceFailure(
          msg="Failed to create TCP handle: \{err.to_bytes() |> @encoding/utf8.decode_lossy}",
        )) {
        Ok(h) => h
        Err(e) => return Err(e)
      }
      let socket = UvTcpSocket::{ uv: handle, rt: self.uv }
      let opt = @net.TcpOption::new(reuseaddr=(options & 1) != 0)
      @net.TcpSocket::dial(socket, @net.SockAddr::Inet(addr), opt).map(it => it
        as &@net.Connection)
    }
    "udp" => {
      let (addr, uv_sock) = match parse_and_convert_addr(address) {
        Ok(result) => result
        Err(e) => return Err(e)
      }
      let handle = match
        (try? @uv.Udp::new(self.uv.uv)).map_err(err => @net.NetworkError::DeviceFailure(
          msg="Failed to create UDP handle: \{err.to_bytes() |> @encoding/utf8.decode_lossy}",
        )) {
        Ok(h) => h
        Err(e) => return Err(e)
      }
      handle.connect(uv_sock) catch {
        err => {
          handle.close(() => ())
          raise @net.NetworkError::DeviceFailure(
            msg="Failed to connect UDP: \{err.to_bytes() |> @encoding/utf8.decode_lossy}",
          )
        }
      }
      let socket = UvDatagramSocket::{
        udp: handle,
        rt: self.uv,
        closed: false,
        packet_queue: @pipe.ArrayBlockingQueue::new(self.uv, 128, fn() {
          (@net.SockAddr::Unspec, Bytes::new(0))
        }),
        receiving: false,
      }
      let buffer = @buffer.HeapByteBuf::new(65536)
      // For connected UDP, set the remote address explicitly
      Ok(
        UvDatagram::{
          sock: socket,
          buf: buffer,
          udp: handle,
          remote: @net.SockAddr::Inet(addr),
        }
        as &@net.Connection,
      )
    }
    _ =>
      Err(
        @net.NetworkError::InvalidAddress(
          msg="Unknown network type: \{network}",
        ),
      )
  }
}

///|
pub impl @net.Network for UvNet with bind(self, network, bind, options) {
  match network {
    "tcp" => {
      let (_, uv_sock) = match parse_and_convert_addr(bind) {
        Ok(result) => result
        Err(e) => return Err(e)
      }
      let handle = match
        (try? @uv.Tcp::new(self.uv.uv)).map_err(err => @net.NetworkError::DeviceFailure(
          msg="Failed to create TCP handle: \{err.to_bytes() |> @encoding/utf8.decode_lossy}",
        )) {
        Ok(h) => h
        Err(e) => return Err(e)
      }
      let opt = @net.TcpOption::new(reuseaddr=(options & 1) != 0)
      let flags = @uv.TcpBindFlags::new(reuse_port=opt.reuseaddr())
      handle.bind(uv_sock, flags) catch {
        err => {
          handle.close(() => ())
          raise @net.NetworkError::DeviceFailure(
            msg="Failed to bind: \{err.to_bytes() |> @encoding/utf8.decode_lossy}",
          )
        }
      }
      Ok(UvTcpSocket::{ uv: handle, rt: self.uv } as &@net.Socket)
    }
    "udp" => {
      let (_, uv_sock) = match parse_and_convert_addr(bind) {
        Ok(result) => result
        Err(e) => return Err(e)
      }
      let handle = match
        (try? @uv.Udp::new(self.uv.uv)).map_err(err => @net.NetworkError::DeviceFailure(
          msg="Failed to create UDP handle: \{err.to_bytes() |> @encoding/utf8.decode_lossy}",
        )) {
        Ok(h) => h
        Err(e) => return Err(e)
      }
      let opt = @net.UdpOption::new(broadcast=(options & 1) != 0)
      let flags = @uv.UdpFlags::new()
      handle.bind(uv_sock, flags) catch {
        err => {
          handle.close(() => ())
          raise @net.NetworkError::DeviceFailure(
            msg="Failed to bind UDP: \{err.to_bytes() |> @encoding/utf8.decode_lossy}",
          )
        }
      }
      if opt.broadcast() {
        handle.set_broadcast(true) catch {
          _ => ()
        }
      }
      Ok(
        UvDatagramSocket::{
          udp: handle,
          rt: self.uv,
          closed: false,
          packet_queue: @pipe.ArrayBlockingQueue::new(self.uv, 128, fn() {
            (@net.SockAddr::Unspec, Bytes::new(0))
          }),
          receiving: false,
        }
        as &@net.Socket,
      )
    }
    _ =>
      Err(
        @net.NetworkError::InvalidAddress(
          msg="Unknown network type: \{network}",
        ),
      )
  }
}

///|
fn @uv.Sockaddr::to_miao(self : @uv.Sockaddr) -> @net.SockAddr raise {
  match mbt_miao_get_safamily(self) {
    _AF_INET => {
      // IPv4
      let port = mbt_miao_get_sin_port(self)
      let addr_bytes = mbt_miao_get_sin_addr(self)
      let ip : Int = (addr_bytes[0].to_int() << 24) |
        (addr_bytes[1].to_int() << 16) |
        (addr_bytes[2].to_int() << 8) |
        addr_bytes[3].to_int()
      @net.SockAddr::Inet(@net.SockAddrIn::{
        port,
        addr: @net.InetAddr::IPv4(host=ip),
      })
    }
    _AF_INET6 => {
      // IPv6
      let port = mbt_miao_get_sin6_port(self)
      let addr_bytes = mbt_miao_get_sin6_addr(self)
      let segments : Array[UInt16] = []
      let mut i = 0
      while i < 8 {
        let high = addr_bytes[i * 2].to_int()
        let low = addr_bytes[i * 2 + 1].to_int()
        segments[i] = ((high << 8) | low).to_uint16()
        i += 1
      }
      @net.SockAddr::Inet(@net.SockAddrIn::{
        port,
        addr: @net.InetAddr::IPv6(
          msb=(segments[0].to_int64() << 48) |
            (segments[1].to_int64() << 32) |
            (segments[2].to_int64() << 16) |
            segments[3].to_int64(),
          lsb=(segments[4].to_int64() << 48) |
            (segments[5].to_int64() << 32) |
            (segments[6].to_int64() << 16) |
            segments[7].to_int64(),
        ),
      })
    }
    _AF_UNIX => {
      // Unix domain socket
      let path_bytes = mbt_miao_get_sun_path(self)
      @net.SockAddr::Unix(
        path=@encoding/utf8.decode(path_bytes) catch {
          _ => raise fail("Failed to decode Unix socket path")
        },
      )
    }
    _ => @net.SockAddr::Unspec
  }
}

///|
fn @net.SockAddr::to_uv(self : @net.SockAddr) -> @uv.Sockaddr raise {
  match self {
    @net.SockAddr::Inet(sockaddr_in) => {
      let addr = sockaddr_in.addr
      let port = sockaddr_in.port
      match addr {
        @net.InetAddr::IPv4(host~) => {
          // Convert Int to dotted decimal string
          let a = (host >> 24) & 0xFF
          let b = (host >> 16) & 0xFF
          let c = (host >> 8) & 0xFF
          let d = host & 0xFF
          let ip_str = "\{a}.\{b}.\{c}.\{d}\u{0000}"
          let ip_bytes = @encoding/utf8.encode(ip_str)
          (@uv.ip4_addr(ip_bytes, port.to_int()) catch {
            _ => raise fail("Failed to create IPv4 address")
          }).to_sockaddr()
        }
        @net.InetAddr::IPv6(msb~, lsb~) => {
          // Convert to colon-separated hex string
          let parts : Array[Int64] = [
            (msb >> 48) & 0xFFFF,
            (msb >> 32) & 0xFFFF,
            (msb >> 16) & 0xFFFF,
            msb & 0xFFFF,
            (lsb >> 48) & 0xFFFF,
            (lsb >> 32) & 0xFFFF,
            (lsb >> 16) & 0xFFFF,
            lsb & 0xFFFF,
          ]
          let ip_str = parts
            .map(fn(x) { @net.int64_to_hex(x).to_lower() })
            .join(":") +
            "\u{0000}"
          let ip_bytes = @encoding/utf8.encode(ip_str)
          (@uv.ip6_addr(ip_bytes, port.to_int()) catch {
            _ => raise fail("Failed to create IPv6 address")
          }).to_sockaddr()
        }
      }
    }
    @net.SockAddr::Unix(_) =>
      // For Unix domain sockets, we would need a different approach
      // libuv may not directly support Unix sockets in the same way
      raise fail("Unix domain socket conversion not yet implemented")
    @net.SockAddr::Local | @net.SockAddr::File | @net.SockAddr::Unspec =>
      raise fail("Cannot convert \{self} to uv Sockaddr")
  }
}
