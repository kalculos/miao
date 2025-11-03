///|
struct UvNetwork {
  rt : LibuvRuntime
}

///|
fn UvNetwork::uv(self : UvNetwork) -> @uv.Loop {
  self.rt.uv
}

///|
impl @net.Network for UvNetwork with dial(self, network, address, options) {
  let _ = options
  match network {
    "tcp" => {
      let sockaddr = try parse_address(address) catch {
        _ => raise @net.NetworkError::InvalidAddress(msg="Invalid address: \{address}")
      }
      let tcp = @uv.Tcp::new(self.uv())
      uvrt_op_suspend((resolve, reject, _) => {
        let handle = tcp.connect(
          sockaddr_to_uv(sockaddr),
          () => resolve(UvTcpConnection::{ tcp, rt: self.rt, local: None, remote: Some(sockaddr) }),
          err => reject(@net.NetworkError::DeviceFailure(msg="Failed to connect: \{err}")),
        )
        () => {
          defer reject(@rt.CoroutineError::Cancelled)
          handle.cancel()
        }
      })
    }
    "udp" => {
      let sockaddr = try parse_address(address) catch {
        _ => raise @net.NetworkError::InvalidAddress(msg="Invalid address: \{address}")
      }
      let udp = @uv.Udp::new(self.uv())
      try udp.connect(sockaddr_to_uv(sockaddr)) catch {
        err => raise @net.NetworkError::DeviceFailure(msg="Failed to connect UDP: \{err}")
      }
      UvDatagramConnection::{ udp, rt: self.rt, sockaddr, buffer: @buffer.Buffer::new() }
    }
    _ => raise @net.NetworkError::InvalidAddress(msg="Unsupported network type: \{network}")
  }
}

///|
impl @net.Network for UvNetwork with bind(self, network, address, options) {
  match network {
    "tcp" => {
      let sockaddr = try parse_address(address) catch {
        _ => raise @net.NetworkError::InvalidAddress(msg="Invalid address: \{address}")
      }
      let tcp = @uv.Tcp::new(self.uv())
      try tcp.bind(sockaddr_to_uv(sockaddr), reuseaddr=(options & 1) != 0) catch {
        err => raise @net.NetworkError::DeviceFailure(msg="Failed to bind TCP: \{err}")
      }
      UvTcpSocket::{ tcp, rt: self.rt, local: Some(sockaddr) }
    }
    "udp" => {
      let sockaddr = try parse_address(address) catch {
        _ => raise @net.NetworkError::InvalidAddress(msg="Invalid address: \{address}")
      }
      let udp = @uv.Udp::new(self.uv())
      try udp.bind(sockaddr_to_uv(sockaddr), reuseaddr=(options & 1) != 0) catch {
        err => raise @net.NetworkError::DeviceFailure(msg="Failed to bind UDP: \{err}")
      }
      UvDatagramSocket::{ udp, rt: self.rt, local: Some(sockaddr) }
    }
    _ => raise @net.NetworkError::InvalidAddress(msg="Unsupported network type: \{network}")
  }
}

///|
struct UvTcpSocket {
  tcp : @uv.Tcp
  rt : LibuvRuntime
  local : @net.SockAddr?
}

///|
impl @net.Socket for UvTcpSocket with accept(self, timeout) {
  self.accept(timeout, opt=@net.TcpOption::new())
}

///|
impl @net.Socket for UvTcpSocket with close(self) {
  guard !self.tcp.is_closing()
  uvrt_op_suspend((resolve, _, _) => {
    self.tcp.close(() => resolve(()))
    () => ()
  })
}

///|
impl @net.Socket for UvTcpSocket with is_closed(self) {
  self.tcp.is_closing()
}

///|
impl @net.TcpSocket for UvTcpSocket with accept(self, timeout, opt?) {
  let _ = opt
  let _ = timeout
  uvrt_op_suspend((resolve, reject, _) => {
    self.tcp.listen(
      128,
      _ => {
        let client = @uv.Tcp::new(self.rt.uv)
        self.tcp.accept(client) catch {
          err => reject(@net.NetworkError::DeviceFailure(msg="Failed to accept: \{err}"))
        } noraise {
          _ => resolve(UvTcpConnection::{ tcp: client, rt: self.rt, local: self.local, remote: None })
        }
      },
    ) catch {
      err => reject(@net.NetworkError::DeviceFailure(msg="Failed to listen: \{err}"))
    }
    () => {
      defer reject(@rt.CoroutineError::Cancelled)
      ()
    }
  })
}

///|
impl @net.TcpSocket for UvTcpSocket with dial(self, host, opt) {
  let _ = opt
  uvrt_op_suspend((resolve, reject, _) => {
    let handle = self.tcp.connect(
      sockaddr_to_uv(host),
      () => resolve(UvTcpConnection::{ tcp: self.tcp, rt: self.rt, local: self.local, remote: Some(host) }),
      err => reject(@net.NetworkError::DeviceFailure(msg="Failed to dial: \{err}")),
    )
    () => {
      defer reject(@rt.CoroutineError::Cancelled)
      handle.cancel()
    }
  })
}

///|
struct UvTcpConnection {
  tcp : @uv.Tcp
  rt : LibuvRuntime
  local : @net.SockAddr?
  remote : @net.SockAddr?
}

///|
impl @net.Connection for UvTcpConnection with local_addr(self) {
  self.local.unwrap_or(@net.SockAddr::{ inet: @net.InetAddr::IPv4(host=0), port: 0 })
}

///|
impl @net.Connection for UvTcpConnection with remote_addr(self) {
  self.remote.unwrap_or(@net.SockAddr::{ inet: @net.InetAddr::IPv4(host=0), port: 0 })
}

///|
impl @net.Connection for UvTcpConnection with flush(self) {
  // TCP flushes automatically
  ()
}

///|
impl @io.Channel for UvTcpConnection with read(self, buffer, offset, length) {
  let stream = self.tcp.to_stream()
  uvrt_op_suspend((resolve, reject, _) => {
    let mut read_once = false
    stream.read_start(
      (_, _) => buffer.unsafe_reinterpret_as_bytes()[offset:offset + length],
      (_, _, bytes) => {
        if !read_once {
          read_once = true
          stream.read_stop()
          resolve(bytes.length())
        }
      },
      (_, err) => reject(err),
    )
    () => {
      defer reject(@rt.CoroutineError::Cancelled)
      stream.read_stop()
    }
  })
}

///|
impl @io.Channel for UvTcpConnection with write(self, buffer, offset, length) {
  let stream = self.tcp.to_stream()
  uvrt_op_suspend((resolve, reject, _) => {
    let _ = stream.write(
      [buffer.unsafe_reinterpret_as_bytes()[offset:offset + length]],
      () => resolve(length),
      err => reject(err),
    )
    () => ()
  })
}

///|
impl @io.Channel for UvTcpConnection with close(self) {
  guard !self.tcp.is_closing()
  self.tcp.close(() => ())
}

///|
impl @io.Channel for UvTcpConnection with is_closed(self) {
  self.tcp.is_closing()
}

///|
impl @net.TcpConnection for UvTcpConnection {}

///|
struct UvDatagramSocket {
  udp : @uv.Udp
  rt : LibuvRuntime
  local : @net.SockAddr?
}

///|
impl @net.Socket for UvDatagramSocket with accept(self, timeout) {
  let buffer = @buffer.Buffer::new()
  self.accept(buffer, timeout).map(fn(pair) { pair.0 })
}

///|
impl @net.Socket for UvDatagramSocket with close(self) {
  guard !self.udp.is_closing()
  uvrt_op_suspend((resolve, _, _) => {
    self.udp.close(() => resolve(()))
    () => ()
  })
}

///|
impl @net.Socket for UvDatagramSocket with is_closed(self) {
  self.udp.is_closing()
}

///|
impl @net.DatagramSocket for UvDatagramSocket with accept(self, buffer, timeout) {
  let _ = timeout
  let recv_buffer = FixedArray::make(65536, 0)
  uvrt_op_suspend((resolve, reject, _) => {
    self.udp.recv_start(
      (_, _) => recv_buffer.unsafe_reinterpret_as_bytes(),
      (_, nread, sockaddr, _) => {
        self.udp.recv_stop()
        if nread > 0 {
          buffer.write_bytes(recv_buffer.unsafe_reinterpret_as_bytes()[0:nread])
          let addr = uv_to_sockaddr(sockaddr)
          resolve((addr, nread))
        } else {
          reject(@net.NetworkError::ConnClose(msg="Connection closed"))
        }
      },
      (_, err) => {
        self.udp.recv_stop()
        reject(@net.NetworkError::DeviceFailure(msg="Receive failed: \{err}"))
      },
    ) catch {
      err => reject(@net.NetworkError::DeviceFailure(msg="Failed to start receive: \{err}"))
    }
    () => {
      defer reject(@rt.CoroutineError::Cancelled)
      self.udp.recv_stop()
    }
  })
}

///|
impl @net.DatagramSocket for UvDatagramSocket with send(self, dst, buffer, opt) {
  let _ = opt
  let data = buffer.to_bytes()
  uvrt_op_suspend((resolve, reject, _) => {
    let handle = self.udp.send(
      [data],
      sockaddr_to_uv(dst),
      () => resolve(()),
      err => reject(@net.NetworkError::DeviceFailure(msg="Send failed: \{err}")),
    )
    () => {
      defer reject(@rt.CoroutineError::Cancelled)
      handle.cancel()
    }
  })
}

///|
struct UvDatagramConnection {
  udp : @uv.Udp
  rt : LibuvRuntime
  sockaddr : @net.SockAddr
  buffer : &@buffer.Buffer
}

///|
impl @net.Connection for UvDatagramConnection with local_addr(self) {
  @net.SockAddr::{ inet: @net.InetAddr::IPv4(host=0), port: 0 }
}

///|
impl @net.Connection for UvDatagramConnection with remote_addr(self) {
  self.sockaddr
}

///|
impl @net.Connection for UvDatagramConnection with flush(self) {
  // UDP doesn't need flushing
  ()
}

///|
impl @io.Channel for UvDatagramConnection with read(self, buffer, offset, length) {
  let bytes_read = self.buffer.read_bytes(buffer.unsafe_reinterpret_as_bytes()[offset:offset + length])
  bytes_read
}

///|
impl @io.Channel for UvDatagramConnection with write(self, buffer, offset, length) {
  let stream_buffer = @buffer.Buffer::new()
  stream_buffer.write_bytes(buffer.unsafe_reinterpret_as_bytes()[offset:offset + length])
  uvrt_op_suspend((resolve, reject, _) => {
    let data = stream_buffer.to_bytes()
    let handle = self.udp.send(
      [data],
      sockaddr_to_uv(self.sockaddr),
      () => resolve(length),
      err => reject(err),
    )
    () => {
      defer reject(@rt.CoroutineError::Cancelled)
      handle.cancel()
    }
  })
}

///|
impl @io.Channel for UvDatagramConnection with close(self) {
  guard !self.udp.is_closing()
  self.udp.close(() => ())
}

///|
impl @io.Channel for UvDatagramConnection with is_closed(self) {
  self.udp.is_closing()
}

///|
impl @net.DatagramConnection for UvDatagramConnection with socket(self) {
  abort("DatagramConnection socket() not supported for dial connections")
}

///|
impl @net.DatagramConnection for UvDatagramConnection with buffer(self) {
  self.buffer
}

///|
fn parse_address(address : String) -> @net.SockAddr raise {
  // Parse address in format "host:port" or "[ipv6]:port"
  let parts = if address.has_prefix("[") {
    // IPv6 format [host]:port
    match address.index_of("]") {
      Some(end_bracket) => {
        let host = address[1:end_bracket].to_string()
        let port_str = address[end_bracket + 2:].to_string()
        (host, port_str)
      }
      None => raise @net.NetworkError::InvalidAddress(msg="Invalid IPv6 address format: \{address}")
    }
  } else {
    // IPv4 format host:port
    match address.last_index_of(":") {
      Some(colon_idx) => (address[0:colon_idx].to_string(), address[colon_idx + 1:].to_string())
      None => raise @net.NetworkError::InvalidAddress(msg="Missing port in address: \{address}")
    }
  }
  let port = try @strconv.parse_int(parts.1) catch {
    _ => raise @net.NetworkError::InvalidAddress(msg="Invalid port: \{parts.1}")
  }
  guard port >= 0 && port <= 65535 else {
    raise @net.NetworkError::InvalidAddress(msg="Port out of range: \{port}")
  }
  @net.from_host_port(parts.0, port.to_uint16())
}

///|
fn sockaddr_to_uv(addr : @net.SockAddr) -> @uv.SockAddr {
  match addr.inet {
    @net.InetAddr::IPv4(host~) => {
      let a = (host >> 24) & 0xFF
      let b = (host >> 16) & 0xFF
      let c = (host >> 8) & 0xFF
      let d = host & 0xFF
      @uv.SockAddrV4::new("\{a}.\{b}.\{c}.\{d}", addr.port.to_int())
    }
    @net.InetAddr::IPv6(msb~, lsb~) => {
      let parts = [
        (msb >> 48) & 0xFFFF,
        (msb >> 32) & 0xFFFF,
        (msb >> 16) & 0xFFFF,
        msb & 0xFFFF,
        (lsb >> 48) & 0xFFFF,
        (lsb >> 32) & 0xFFFF,
        (lsb >> 16) & 0xFFFF,
        lsb & 0xFFFF,
      ]
      let ipv6_str = parts.map(fn(x) { @net.int64_to_hex(x).to_lower() }).join(":")
      @uv.SockAddrV6::new(ipv6_str, addr.port.to_int())
    }
  }
}

///|
fn uv_to_sockaddr(uv_addr : @uv.SockAddr) -> @net.SockAddr {
  match uv_addr {
    @uv.SockAddrV4(ip~, port~) => {
      let inet = @net.InetAddr::from_ipv4(ip) catch {
        _ => @net.InetAddr::IPv4(host=0)
      }
      @net.SockAddr::{ inet, port: port.to_uint16() }
    }
    @uv.SockAddrV6(ip~, port~) => {
      let inet = @net.InetAddr::from_ipv6(ip) catch {
        _ => @net.InetAddr::IPv6(msb=0, lsb=0)
      }
      @net.SockAddr::{ inet, port: port.to_uint16() }
    }
    @uv.SockAddrUnspec => @net.SockAddr::{ inet: @net.InetAddr::IPv4(host=0), port: 0 }
  }
}
