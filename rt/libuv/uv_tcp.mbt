struct UvTcpConnecion {
  tcp: @uv.Tcp
  mut closed: Bool
}

impl @net.Connection for UvTcpConnecion with local_addr(self) {
  self.tcp.getsockname().
}

impl @net.Connection for UvTcpConnecion with remote_addr(self) {
  self.tcp.getpeername()
}

impl @net.Connection for UvTcpConnecion with flush(self) {
  
}

impl @io.Writer

struct UvTcpSocket {
  uv: @uv.Tcp
  rt: LibuvRuntime
}

impl @net.TcpSocket for UvTcpSocket with accept(self, timeout, opt?) {
  uvrt_op_suspend((resolve, reject, task) => {
    self.uv.listen(16, tcp => {
      resolve()
    }, (_, errno)=> {
        reject(errno)
    })
    () => {
      defer reject(@rt.CoroutineError::Cancelled)
      self.close()
    }
  })
}
impl @net.TcpSocket for UvTcpSocket with dial(self, host, opt?) {}

impl @net.TcpSocket for UvTcpSocket with close(self) {}

impl @net.TcpSocket for UvTcpSocket with close_immediately(self) {}

impl @net.Socket for UvTcpSocket with accept(self, timeout) {}

impl @net.Socket for UvTcpSocket with close(self) {}

impl @net.Socket for UvTcpSocket with is_closed(self) {}


fn @uv.Sockaddr::to_uv(self: @uv.Sockaddr) -> @net.SockAddrIn {

}