///|
struct UvTcpConnecion {
  tcp : @uv.Tcp
  mut closed : Bool
  reader : &@io.Reader
}

///|
impl @net.Connection for UvTcpConnecion with local_addr(self) {
  (try? self.tcp.getsockname().to_miao()).unwrap()
}

///|
impl @net.Connection for UvTcpConnecion with remote_addr(self) {
  (try? self.tcp.getpeername().to_miao()).unwrap()
}

///|
impl @net.Connection for UvTcpConnecion with flush(self) {
  let _ = self

}

///|
impl @io.Writer for UvTcpConnecion with write(self, arr, off, len) {
  uvrt_op_suspend((resolve, reject, _) => {
    let _handle = self.tcp.write(
      [arr.unsafe_reinterpret_as_bytes()[off:off + len]],
      () => resolve(len),
      errno => reject(errno),
    )
    () => {
      defer reject(@rt.CoroutineError::Cancelled)

    }
  })
}

///|
impl @io.Writer for UvTcpConnecion with close(self) {
  guard !self.closed
  self.tcp.close(() => ())
  self.closed = true
}

///|
impl @io.Writer for UvTcpConnecion with is_closed(self) {
  self.closed
}

///|
impl @io.Reader for UvTcpConnecion with read(self, arr, off, len) {
  self.reader.read(arr, off, len)
}

///|
impl @io.Reader for UvTcpConnecion with close(self) {
  guard !self.closed
  self.reader.close()
  self.tcp.close(() => ())
  self.closed = true
}

///|
impl @io.Reader for UvTcpConnecion with is_closed(self) {
  self.closed
}

///|
impl @io.Channel for UvTcpConnecion with close(self) {
  guard !self.closed
  self.reader.close()
  self.tcp.close(() => ())
  self.closed = true
}

///|
impl @io.Channel for UvTcpConnecion with is_closed(self) {
  self.closed
}

///|
fn UvTcpConnecion::new(
  rt : &@rt.Runtime,
  tcp : @uv.Tcp,
) -> UvTcpConnecion raise {
  UvTcpConnecion::{
    tcp,
    closed: false,
    reader: read_stream(rt, tcp.to_stream()),
  }
}

///|
struct UvTcpSocket {
  uv : @uv.Tcp
  rt : LibuvRuntime
}

///|
impl @net.TcpSocket for UvTcpSocket with accept(self, _timeout, opt?) {
  let _ = opt
  uvrt_op_suspend((resolve, reject, _) => {
    self.uv.listen(
      16,
      tcp => resolve(
        (try? UvTcpConnecion::new(self.rt, tcp))
        .map(it => it as &@net.TcpConnection)
        .map_err(failure => @net.NetworkError::DeviceFailure(
          msg="Failed to initialize TCP connection: \{failure}",
        )),
      ),
      (_, errno) => resolve(
        Err(
          @net.NetworkError::DeviceFailure(
            msg="Failed to accept TCP connection: \{errno.to_bytes() |> @encoding/utf8.decode_lossy}",
          ),
        ),
      ),
    )
    () => {
      defer reject(@rt.CoroutineError::Cancelled)

    }
  })
}

///|
impl @net.TcpSocket for UvTcpSocket with dial(self, host, _opt) {
  uvrt_op_suspend((resolve, reject, _) => {
    let uv_addr = (try? host.to_uv()).map_err(err => @net.NetworkError::InvalidAddress(
      msg="Failed to convert address: \{err}",
    ))
    match uv_addr {
      Err(e) => {
        resolve(Err(e))
        () => ()
      }
      Ok(addr) => {
        let _handle = self.uv.connect(
          addr,
          () => resolve(
            (try? UvTcpConnecion::new(self.rt, self.uv))
            .map(it => it as &@net.TcpConnection)
            .map_err(failure => @net.NetworkError::DeviceFailure(
              msg="Failed to initialize TCP connection: \{failure}",
            )),
          ),
          errno => resolve(
            Err(
              @net.NetworkError::DeviceFailure(
                msg="Failed to connect: \{errno.to_bytes() |> @encoding/utf8.decode_lossy}",
              ),
            ),
          ),
        )
        () => {
          defer reject(@rt.CoroutineError::Cancelled)

        }
      }
    }
  })
}

///|
impl @net.TcpSocket for UvTcpSocket with close(self) {
  self.uv.close(() => ())
}

///|
impl @net.TcpSocket for UvTcpSocket with close_immediately(self) {
  self.uv.close_reset(() => ()) catch {
    _ => ()
  }
}

///|
impl @net.Socket for UvTcpSocket with accept(self, timeout) {
  @net.TcpSocket::accept(self, timeout).map(it => it as &@net.Connection)
}

///|
impl @net.Socket for UvTcpSocket with close(self) {
  self.uv.close(() => ())
}

///|
impl @net.Socket for UvTcpSocket with is_closed(self) {
  self.uv.to_handle().is_closing()
}
