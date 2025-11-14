///|
struct UvDatagram {
  sock : &@net.DatagramSocket
  buf : @buffer.HeapByteBuf
  udp : @uv.Udp
}

///|
impl @net.Connection for UvDatagram with local_addr(self) {
  (try? self.udp.getsockname().to_miao()).unwrap_or(@net.SockAddr::Unspec)
}

///|
impl @net.Connection for UvDatagram with remote_addr(self) {
  (try? self.udp.getpeername().to_miao()).unwrap_or(@net.SockAddr::Unspec)
}

///|
impl @net.Connection for UvDatagram with flush(self) {
  let _ = self
}

///|
impl @io.Writer for UvDatagram with write(_self, _arr, _off, _len) {
  abort("UDP datagrams do not support write operation")
}

///|
impl @io.Writer for UvDatagram with close(_self) {
  // Datagram connections are ephemeral, no-op
}

///|
impl @io.Writer for UvDatagram with is_closed(_self) {
  false
}

///|
impl @io.Reader for UvDatagram with read(self, arr, off, len) {
  self.buf.read(arr, off, len)
}

///|
impl @io.Reader for UvDatagram with close(_self) {
  // Datagram connections are ephemeral, no-op
}

///|
impl @io.Reader for UvDatagram with is_closed(_self) {
  false
}

///|
impl @io.Channel for UvDatagram with close(_self) {
  // Datagram connections are ephemeral, no-op
}

///|
impl @io.Channel for UvDatagram with is_closed(_self) {
  false
}

///|
impl @net.DatagramConnection for UvDatagram with socket(self) {
  self.sock
}

///|
impl @net.DatagramConnection for UvDatagram with buffer(self) {
  self.buf
}

///|
struct UvDatagramSocket {
  udp : @uv.Udp
  rt : LibuvRuntime
  mut closed : Bool
}

///|
impl @net.DatagramSocket for UvDatagramSocket with accept(self, buffer, _timeout) {
  uvrt_op_suspend((resolve, reject, _) => {
    let mut received = false
    self.udp.recv_start(
      (_, size) => FixedArray::make(size, b'\x00').unsafe_reinterpret_as_bytes().op_as_view(),
      (_, nread, buf, addr, _flags) => {
        if !received {
          received = true
          let arr = FixedArray::makei(nread, fn(i) { buf[i] })
          (buffer as &@buffer.Buffer).write(arr, 0, nread) |> ignore
          let sockaddr = (try? addr.to_miao()).unwrap_or(@net.SockAddr::Unspec)
          resolve(Ok((sockaddr, nread)))
          self.udp.recv_stop() catch { _ => () }
        }
      },
      (_, errno) => {
        if !received {
          received = true
          resolve(
            Err(
              @net.NetworkError::DeviceFailure(
                msg="Failed to receive UDP packet: \{errno.to_bytes() |> @encoding/utf8.decode_lossy}",
              ),
            ),
          )
        }
      },
    ) catch {
      err => resolve(
        Err(
          @net.NetworkError::DeviceFailure(
            msg="Failed to start receiving: \{err.to_bytes() |> @encoding/utf8.decode_lossy}",
          ),
        ),
      )
    }
    () => {
      defer reject(@rt.CoroutineError::Cancelled)
      self.udp.recv_stop() catch { _ => () }
    }
  })
}

///|
impl @net.DatagramSocket for UvDatagramSocket with send(self, dst, buffer, _opt) {
  let uv_addr = (try? dst.to_uv()).map_err(err => @net.NetworkError::InvalidAddress(
    msg="Failed to convert address: \{err}",
  ))
  match uv_addr {
    Err(e) => Err(e)
    Ok(addr) => {
      let data = (buffer as &@buffer.Buffer).to_bytes()
      uvrt_op_suspend((resolve, reject, _) => {
        let _handle = self.udp.send(
          [data.op_as_view()],
          () => resolve(Ok(())),
          errno => resolve(
            Err(
              @net.NetworkError::DeviceFailure(
                msg="Failed to send UDP packet: \{errno.to_bytes() |> @encoding/utf8.decode_lossy}",
              ),
            ),
          ),
          addr=addr,
        )
        () => {
          defer reject(@rt.CoroutineError::Cancelled)
        }
      })
    }
  }
}

///|
impl @net.Socket for UvDatagramSocket with accept(self, timeout) {
  let buffer = @buffer.HeapByteBuf::new(65536)
  (@net.DatagramSocket::accept(self, buffer, timeout)).map(
    fn(pair) {
      let _ = pair
      UvDatagram::{ sock: self, buf: buffer, udp: self.udp } as &@net.Connection
    },
  )
}

///|
impl @net.Socket for UvDatagramSocket with close(self) {
  guard !self.closed
  self.udp.close(() => ())
  self.closed = true
}

///|
impl @net.Socket for UvDatagramSocket with is_closed(self) {
  self.closed
}


