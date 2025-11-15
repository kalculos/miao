///|
/// ArrayBlockingQueue is a thread-safe queue with blocking read/write operations.
/// It uses ArrayDeque as the underlying buffer and provides synchronization
/// primitives for cooperative multitasking.
struct ArrayBlockingQueue[T] {
  rt : &@rt.Runtime
  buffer : ArrayDeque[T]
  // Lock fields
  mut read_waiting : Bool
  mut read_waiter : () -> Unit
  mut write_waiting : Bool
  mut write_waiter : () -> Unit
  // Closed state
  mut closed : Bool
}

///|
/// Create a new ArrayBlockingQueue with the given runtime and buffer capacity.
pub fn [T] ArrayBlockingQueue::new(
  runtime : &@rt.Runtime,
  capacity : Int,
  default : () -> T
) -> ArrayBlockingQueue[T] {
  guard capacity > 0
  ArrayBlockingQueue::{
    rt: runtime,
    buffer: ArrayDeque::new(capacity, default),
    read_waiting: false,
    read_waiter: () => (),
    write_waiting: false,
    write_waiter: () => (),
    closed: false,
  }
}

///|
/// Returns the number of elements currently in the queue.
pub fn [T] ArrayBlockingQueue::available(self : ArrayBlockingQueue[T]) -> Int {
  if self.closed {
    return 0
  }
  self.buffer.length()
}

///|
/// Returns true if the queue is closed.
pub fn [T] ArrayBlockingQueue::is_closed(self : ArrayBlockingQueue[T]) -> Bool {
  self.closed
}

///|
/// Close the queue. After closing, no more reads or writes will succeed.
pub async fn [T] ArrayBlockingQueue::close(self : ArrayBlockingQueue[T]) -> Unit {
  guard !self.closed
  self.closed = true
  // Wake up any waiting readers/writers
  if self.read_waiting {
    self.rt.new_task(_ => (self.read_waiter)()).start()
  }
  if self.write_waiting {
    self.rt.new_task(_ => (self.write_waiter)()).start()
  }
}

///|
/// Returns true if we can write at least `amount` elements without blocking.
pub fn [T] ArrayBlockingQueue::can_write(self : ArrayBlockingQueue[T], amount : Int) -> Bool {
  !self.closed && self.buffer.available() >= amount
}

///|
/// Read elements from the queue into a destination array.
/// Blocks if the queue is empty until data becomes available or the queue is closed.
/// Returns the number of elements actually read.
pub async fn ArrayBlockingQueue::read_into(
  self : ArrayBlockingQueue[Byte],
  dst : FixedArray[Byte],
  dst_offset : Int,
  len : Int
) -> Int {
  if self.closed {
    return 0
  }
  if self.buffer.is_empty() {
    // Block until data is available
    self.block_read()
    if self.closed {
      return 0
    }
  }
  let read = self.buffer.read_into(dst, dst_offset, len)
  if read > 0 && self.write_waiting {
    self.rt.new_task(_ => (self.write_waiter)()).start()
  }
  read
}

///|
/// Write elements to the queue from a source array.
/// Blocks if there's not enough space until space becomes available or the queue is closed.
/// Returns the number of elements actually written.
pub async fn ArrayBlockingQueue::write_from(
  self : ArrayBlockingQueue[Byte],
  src : FixedArray[Byte],
  src_offset : Int,
  len : Int
) -> Int {
  if self.closed {
    return 0
  }
  if !self.can_write(len) {
    // Block until space is available
    self.block_write()
    if self.closed {
      return 0
    }
  }
  let written = self.buffer.write_from(src, src_offset, len)
  if written > 0 && self.read_waiting {
    self.rt.new_task(_ => (self.read_waiter)()).start()
  }
  written
}

///|
async fn [T] ArrayBlockingQueue::block_read(self : ArrayBlockingQueue[T]) -> Unit {
  guard !self.read_waiting else {
    raise fail("Someone called read() while someone is already waiting!")
  }
  self.read_waiting = true
  defer (fn() { self.read_waiting = false })()
  self.rt.suspend((onResolve, onReject, _) => {
    self.read_waiter = () => {
        defer (fn() { self.read_waiter = () => () })()
        onResolve(())
      }
    () => onReject(@rt.CoroutineError::Cancelled)
  })
}

///|
async fn [T] ArrayBlockingQueue::block_write(self : ArrayBlockingQueue[T]) -> Unit {
  guard !self.write_waiting else {
    raise fail("Someone called write() while someone is already waiting!")
  }
  self.write_waiting = true
  defer (fn() { self.write_waiting = false })()
  self.rt.suspend((onResolve, onReject, _) => {
    self.write_waiter = () => {
        defer (fn() { self.write_waiter = () => () })()
        onResolve(())
      }
    () => onReject(@rt.CoroutineError::Cancelled)
  })
}

///|
/// Queue interface: returns the number of elements in the queue.
pub fn [T] ArrayBlockingQueue::length(self : ArrayBlockingQueue[T]) -> Int {
  self.buffer.length()
}

///|
/// Queue interface: returns the capacity of the queue.
pub fn [T] ArrayBlockingQueue::capacity(self : ArrayBlockingQueue[T]) -> Int {
  self.buffer.capacity()
}

///|
/// Queue interface: returns true if the queue is empty.
pub fn [T] ArrayBlockingQueue::is_empty(self : ArrayBlockingQueue[T]) -> Bool {
  self.buffer.is_empty()
}

///|
/// Queue interface: returns true if the queue is full.
pub fn [T] ArrayBlockingQueue::is_full(self : ArrayBlockingQueue[T]) -> Bool {
  self.buffer.is_full()
}

///|
/// Queue interface: clear all elements from the queue.
pub fn [T] ArrayBlockingQueue::clear(self : ArrayBlockingQueue[T]) -> Unit {
  self.buffer.clear()
}

///|
/// Queue interface: peek at the front element without removing it (non-blocking).
/// Returns None if the queue is empty or closed.
pub fn [T] ArrayBlockingQueue::peek(self : ArrayBlockingQueue[T]) -> Option[T] {
  if self.closed {
    return None
  }
  self.buffer.peek()
}

///|
/// Queue interface: try to pop an element from the front (non-blocking).
/// Returns None if the queue is empty or closed.
pub fn [T] ArrayBlockingQueue::try_pop(self : ArrayBlockingQueue[T]) -> Option[T] raise {
  if self.closed {
    return None
  }
  let result = self.buffer.try_pop()
  match result {
    Some(_) => {
      if self.write_waiting {
        self.rt.new_task(_ => (self.write_waiter)()).start()
      }
    }
    None => ()
  }
  result
}

///|
/// Queue interface: try to push an element to the back (non-blocking).
/// Returns false if the queue is full or closed.
pub fn [T] ArrayBlockingQueue::try_push(self : ArrayBlockingQueue[T], value : T) -> Bool raise {
  if self.closed {
    return false
  }
  let success = self.buffer.try_push(value)
  if success && self.read_waiting {
    self.rt.new_task(_ => (self.read_waiter)()).start()
  }
  success
}

///|
/// Blocking pop: pop an element from the front, blocking if empty.
/// Returns the element if successful. Raises an error if the queue is closed while waiting.
pub async fn [T] ArrayBlockingQueue::pop(self : ArrayBlockingQueue[T]) -> T {
  if self.closed {
    raise fail("Cannot pop from a closed queue")
  }
  while self.buffer.is_empty() {
    self.block_read()
    if self.closed {
      raise fail("Queue was closed while waiting to pop")
    }
  }
  let result = self.buffer.try_pop()
  match result {
    Some(value) => {
      if self.write_waiting {
        self.rt.new_task(_ => (self.write_waiter)()).start()
      }
      value
    }
    None => raise fail("Unexpected: buffer should not be empty")
  }
}

///|
/// Blocking push: push an element to the back, blocking if full.
/// Raises an error if the queue is closed while waiting.
pub async fn [T] ArrayBlockingQueue::push(self : ArrayBlockingQueue[T], value : T) -> Unit {
  if self.closed {
    raise fail("Cannot push to a closed queue")
  }
  while self.buffer.is_full() {
    self.block_write()
    if self.closed {
      raise fail("Queue was closed while waiting to push")
    }
  }
  let success = self.buffer.try_push(value)
  if not(success) {
    raise fail("Unexpected: buffer should not be full")
  }
  if self.read_waiting {
    self.rt.new_task(_ => (self.read_waiter)()).start()
  }
}
