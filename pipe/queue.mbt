///|
/// This file documents the Queue interface that both ArrayDeque and SyncQueue follow.
/// 
/// Common Queue Operations:
/// - peek() -> Option[T] - Peek at the front element without removing it
/// - try_pop() -> Option[T] - Try to pop from front (non-blocking, returns None if empty)
/// - try_push(T) -> Bool - Try to push to back (non-blocking, returns false if full)
/// - length() -> Int - Number of elements in the queue
/// - capacity() -> Int - Total capacity of the queue
/// - available() -> Int - Number of available slots
/// - is_empty() -> Bool - Check if queue is empty
/// - is_full() -> Bool - Check if queue is full
/// - clear() -> Unit - Remove all elements
///
/// SyncQueue also provides blocking variants:
/// - pop() -> T - Pop from front (blocks if empty, async)
/// - push(T) -> Unit - Push to back (blocks if full, async)