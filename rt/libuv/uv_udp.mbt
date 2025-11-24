///|
struct UvDatagram {
  sock : &@net.DatagramSocket
  buf : @buffer.HeapByteBuf
  udp : @uv.Udp
  // If not Unspec, this indicates the remote address for this datagram.
  // For connected UDP (from dial), this is the connected remote and libuv
  // filters incoming packets at the OS level to only accept from this address.
  // For unconnected UDP (from bind->accept), this is the source of the received packet.
  remote : @net.SockAddr
}

///|
impl @net.Connection for UvDatagram with local_addr(self) {
  (try? self.udp.getsockname().to_miao()).unwrap_or(@net.SockAddr::Unspec)
}

///|
impl @net.Connection for UvDatagram with remote_addr(self) {
  self.remote
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
  // The buffer contains the packet data - just read from it
  // For connected datagrams (from dial), subsequent packets should be read
  // by calling socket().accept() to get new UvDatagram instances
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
impl @net.Connection for UvDatagram with unsafe_udp_connection(self) {
  self as &@net.DatagramConnection
}

///|
impl @net.Connection for UvDatagram with unsafe_tcp_connection(_self) {
  println("unsupport")
  abort("unsupport")
}

///|
struct UvDatagramSocket {
  udp : @uv.Udp
  rt : LibuvRuntime
  mut closed : Bool
  packet_queue : @pipe.ArrayBlockingQueue[(@net.SockAddr, Bytes)]
  mut receiving : Bool
}

///|
impl @net.DatagramSocket for UvDatagramSocket with accept(
  self,
  buffer,
  _timeout,
) {
  // Start receiving if not already started
  if !self.receiving && !self.closed {
    self.receiving = true
    self.start_receiving()
  }

  // Wait for a packet from the queue
  let result = self.packet_queue.pop()
  match result {
    (addr, data) => {
      let view = data.op_as_view()
      let to_copy = @cmp.minimum(view.length(), buffer.writable_bytes())
      let arr = FixedArray::makei(to_copy, fn(i) { view[i] })
      (buffer as &@buffer.Buffer).write(arr, 0, to_copy) |> ignore
      Ok((addr, to_copy))
    }
  }
}

///|
fn UvDatagramSocket::start_receiving(self : UvDatagramSocket) -> Unit {
  self.udp.recv_start(
    (_, size) => FixedArray::make(size, b'\x00')
      .unsafe_reinterpret_as_bytes()
      .op_as_view(),
    (_, nread, buf, addr, _flags) => if nread > 0 && !self.closed {
      // Copy the received data into a Bytes object
      let data = Bytes::from_array(FixedArray::makei(nread, fn(i) { buf[i] }))
      let sockaddr = (try? addr.to_miao()).unwrap_or(@net.SockAddr::Unspec)
      // Try to push to queue (non-blocking to avoid issues in callback)
      let _ = self.packet_queue.try_push((sockaddr, data)) catch { _ => false }

    },
    (
      _,
      _errno,
      // Error in receiving, stop receiving
    ) => if !self.closed { self.receiving = false },
  ) catch {
    _ => self.receiving = false
  }
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
          addr~,
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
  @net.DatagramSocket::accept(self, buffer, timeout).map(fn(pair) {
    let (remote_addr, _) = pair
    // Create a datagram wrapper for this specific packet
    // The remote address indicates where this packet came from
    UvDatagram::{ sock: self, buf: buffer, udp: self.udp, remote: remote_addr }
    as &@net.Connection
  })
}

///|
impl @net.Socket for UvDatagramSocket with close(self) {
  guard !self.closed
  self.closed = true
  if self.receiving {
    self.udp.recv_stop() catch {
      _ => ()
    }
    self.receiving = false
  }
  self.packet_queue.close()
  self.udp.close(() => ())
}

///|
impl @net.Socket for UvDatagramSocket with is_closed(self) {
  self.closed
}

///|
impl @net.Socket for UvDatagramSocket with unsafe_udp_socket(self) {
  self as &@net.DatagramSocket
}

///|
impl @net.Socket for UvDatagramSocket with unsafe_tcp_socket(_self) {
  println("unsupport")
  abort("unsupport")
}
