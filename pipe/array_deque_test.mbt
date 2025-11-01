///|
/// Tests for ArrayDeque creation and basic properties

test "ArrayDeque::new creates deque with correct capacity" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(5, () => 0)
  inspect(deque.capacity(), content="5")
  inspect(deque.length(), content="0")
  inspect(deque.is_empty(), content="true")
  inspect(deque.is_full(), content="false")
  inspect(deque.available(), content="5")
}

///|
test "ArrayDeque::new with capacity 1" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(1, () => 0)
  inspect(deque.capacity(), content="1")
  inspect(deque.length(), content="0")
}

///|
/// Tests for push_back and pop_front operations

test "push_back single element" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(5, () => 0)
  let success = deque.push_back(42)
  inspect(success, content="true")
  inspect(deque.length(), content="1")
  inspect(deque.is_empty(), content="false")
  inspect(deque.available(), content="4")
}

///|
test "push_back and pop_front single element" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(5, () => 0)
  deque.push_back(42) |> ignore
  let value = deque.pop_front()
  inspect(value, content="Some(42)")
  inspect(deque.length(), content="0")
  inspect(deque.is_empty(), content="true")
}

///|
test "push_back multiple elements" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(5, () => 0)
  deque.push_back(1) |> ignore
  deque.push_back(2) |> ignore
  deque.push_back(3) |> ignore
  inspect(deque.length(), content="3")
  inspect(deque.available(), content="2")
}

///|
test "pop_front maintains FIFO order" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(5, () => 0)
  deque.push_back(1) |> ignore
  deque.push_back(2) |> ignore
  deque.push_back(3) |> ignore
  inspect(deque.pop_front(), content="Some(1)")
  inspect(deque.pop_front(), content="Some(2)")
  inspect(deque.pop_front(), content="Some(3)")
  inspect(deque.is_empty(), content="true")
}

///|
test "pop_front from empty deque returns None" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(5, () => 0)
  inspect(deque.pop_front(), content="None")
}

///|
/// Tests for full deque behavior

test "push_back to full deque returns false" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(3, () => 0)
  inspect(deque.push_back(1), content="true")
  inspect(deque.push_back(2), content="true")
  inspect(deque.push_back(3), content="true")
  inspect(deque.is_full(), content="true")
  inspect(deque.push_back(4), content="false")
  inspect(deque.length(), content="3")
}

///|
/// Tests for peek operations

test "peek_front returns front element without removing" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(5, () => 0)
  deque.push_back(10) |> ignore
  deque.push_back(20) |> ignore
  inspect(deque.peek_front(), content="Some(10)")
  inspect(deque.length(), content="2")
  inspect(deque.peek_front(), content="Some(10)")
}

///|
test "peek_front on empty deque returns None" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(5, () => 0)
  inspect(deque.peek_front(), content="None")
}

///|
test "peek alias works correctly" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(5, () => 0)
  deque.push_back(42) |> ignore
  inspect(deque.peek(), content="Some(42)")
}

///|
/// Tests for ring buffer wrap-around behavior

test "wrap-around behavior when tail wraps" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(3, () => 0)
  // Fill the deque
  deque.push_back(1) |> ignore
  deque.push_back(2) |> ignore
  deque.push_back(3) |> ignore
  // Remove two elements
  deque.pop_front() |> ignore
  deque.pop_front() |> ignore
  // Add two more (tail should wrap around)
  deque.push_back(4) |> ignore
  deque.push_back(5) |> ignore
  // Check order is maintained
  inspect(deque.pop_front(), content="Some(3)")
  inspect(deque.pop_front(), content="Some(4)")
  inspect(deque.pop_front(), content="Some(5)")
}

///|
test "wrap-around with continuous push and pop" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(4, () => 0)
  deque.push_back(1) |> ignore
  deque.push_back(2) |> ignore
  inspect(deque.pop_front(), content="Some(1)")
  deque.push_back(3) |> ignore
  deque.push_back(4) |> ignore
  inspect(deque.pop_front(), content="Some(2)")
  deque.push_back(5) |> ignore
  inspect(deque.pop_front(), content="Some(3)")
  inspect(deque.pop_front(), content="Some(4)")
  inspect(deque.pop_front(), content="Some(5)")
  inspect(deque.is_empty(), content="true")
}

///|
/// Tests for clear operation

test "clear empties the deque" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(5, () => 0)
  deque.push_back(1) |> ignore
  deque.push_back(2) |> ignore
  deque.push_back(3) |> ignore
  deque.clear()
  inspect(deque.length(), content="0")
  inspect(deque.is_empty(), content="true")
  inspect(deque.available(), content="5")
}

///|
test "clear on empty deque" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(5, () => 0)
  deque.clear()
  inspect(deque.length(), content="0")
  inspect(deque.is_empty(), content="true")
}

///|
test "deque can be reused after clear" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(3, () => 0)
  deque.push_back(1) |> ignore
  deque.push_back(2) |> ignore
  deque.clear()
  deque.push_back(10) |> ignore
  deque.push_back(20) |> ignore
  inspect(deque.pop_front(), content="Some(10)")
  inspect(deque.pop_front(), content="Some(20)")
}

///|
/// Tests for Queue interface aliases

test "try_push alias works correctly" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(3, () => 0)
  inspect(deque.try_push(1), content="true")
  inspect(deque.try_push(2), content="true")
  inspect(deque.try_push(3), content="true")
  inspect(deque.try_push(4), content="false")
}

///|
test "try_pop alias works correctly" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(3, () => 0)
  deque.push_back(42) |> ignore
  inspect(deque.try_pop(), content="Some(42)")
  inspect(deque.try_pop(), content="None")
}

///|
/// Tests for read_into operation (Byte-specific)

test "read_into reads bytes into destination array" {
  let deque : ArrayDeque[Byte] = ArrayDeque::new(5, () => b'\x00')
  deque.push_back(b'A') |> ignore
  deque.push_back(b'B') |> ignore
  deque.push_back(b'C') |> ignore
  
  let dst : FixedArray[Byte] = FixedArray::make(5, b'\x00')
  let read = deque.read_into(dst, 0, 3)
  inspect(read, content="3")
  inspect(dst[0].to_int(), content="65")  // 'A'
  inspect(dst[1].to_int(), content="66")  // 'B'
  inspect(dst[2].to_int(), content="67")  // 'C'
  inspect(deque.length(), content="0")
}

///|
test "read_into with offset" {
  let deque : ArrayDeque[Byte] = ArrayDeque::new(5, () => b'\x00')
  deque.push_back(b'X') |> ignore
  deque.push_back(b'Y') |> ignore
  
  let dst : FixedArray[Byte] = FixedArray::make(5, b'\x00')
  let read = deque.read_into(dst, 2, 2)
  inspect(read, content="2")
  inspect(dst[0].to_int(), content="0")
  inspect(dst[1].to_int(), content="0")
  inspect(dst[2].to_int(), content="88")  // 'X'
  inspect(dst[3].to_int(), content="89")  // 'Y'
  inspect(dst[4].to_int(), content="0")
}

///|
test "read_into reads less when deque has fewer elements" {
  let deque : ArrayDeque[Byte] = ArrayDeque::new(5, () => b'\x00')
  deque.push_back(b'A') |> ignore
  deque.push_back(b'B') |> ignore
  
  let dst : FixedArray[Byte] = FixedArray::make(5, b'\x00')
  let read = deque.read_into(dst, 0, 5)
  inspect(read, content="2")
  inspect(deque.length(), content="0")
}

///|
test "read_into from empty deque returns 0" {
  let deque : ArrayDeque[Byte] = ArrayDeque::new(5, () => b'\x00')
  let dst : FixedArray[Byte] = FixedArray::make(5, b'\x00')
  let read = deque.read_into(dst, 0, 5)
  inspect(read, content="0")
}

///|
test "read_into with wrap-around" {
  let deque : ArrayDeque[Byte] = ArrayDeque::new(4, () => b'\x00')
  // Fill and partially drain to create wrap-around
  deque.push_back(b'A') |> ignore
  deque.push_back(b'B') |> ignore
  deque.push_back(b'C') |> ignore
  deque.pop_front() |> ignore
  deque.pop_front() |> ignore
  // Now add more to wrap tail around
  deque.push_back(b'D') |> ignore
  deque.push_back(b'E') |> ignore
  deque.push_back(b'F') |> ignore
  
  let dst : FixedArray[Byte] = FixedArray::make(5, b'\x00')
  let read = deque.read_into(dst, 0, 4)
  inspect(read, content="4")
  inspect(dst[0].to_int(), content="67")  // 'C'
  inspect(dst[1].to_int(), content="68")  // 'D'
  inspect(dst[2].to_int(), content="69")  // 'E'
  inspect(dst[3].to_int(), content="70")  // 'F'
}

///|
/// Tests for write_from operation (Byte-specific)

test "write_from writes bytes from source array" {
  let deque : ArrayDeque[Byte] = ArrayDeque::new(5, () => b'\x00')
  let src : FixedArray[Byte] = [b'A', b'B', b'C', b'D', b'E']
  let written = deque.write_from(src, 0, 3)
  inspect(written, content="3")
  inspect(deque.length(), content="3")
  inspect(deque.pop_front(), content="Some(b'\\x41')")  // 'A'
  inspect(deque.pop_front(), content="Some(b'\\x42')")  // 'B'
  inspect(deque.pop_front(), content="Some(b'\\x43')")  // 'C'
}

///|
test "write_from with offset" {
  let deque : ArrayDeque[Byte] = ArrayDeque::new(5, () => b'\x00')
  let src : FixedArray[Byte] = [b'A', b'B', b'C', b'D', b'E']
  let written = deque.write_from(src, 2, 2)
  inspect(written, content="2")
  inspect(deque.pop_front(), content="Some(b'\\x43')")  // 'C'
  inspect(deque.pop_front(), content="Some(b'\\x44')")  // 'D'
}

///|
test "write_from writes less when deque has less space" {
  let deque : ArrayDeque[Byte] = ArrayDeque::new(3, () => b'\x00')
  let src : FixedArray[Byte] = [b'A', b'B', b'C', b'D', b'E']
  let written = deque.write_from(src, 0, 5)
  inspect(written, content="3")
  inspect(deque.is_full(), content="true")
}

///|
test "write_from to full deque returns 0" {
  let deque : ArrayDeque[Byte] = ArrayDeque::new(2, () => b'\x00')
  deque.push_back(b'X') |> ignore
  deque.push_back(b'Y') |> ignore
  
  let src : FixedArray[Byte] = [b'A', b'B', b'C']
  let written = deque.write_from(src, 0, 3)
  inspect(written, content="0")
}

///|
test "write_from with wrap-around" {
  let deque : ArrayDeque[Byte] = ArrayDeque::new(4, () => b'\x00')
  // Fill and partially drain to create wrap-around
  deque.push_back(b'A') |> ignore
  deque.push_back(b'B') |> ignore
  deque.pop_front() |> ignore
  deque.pop_front() |> ignore
  
  let src : FixedArray[Byte] = [b'C', b'D', b'E', b'F', b'G']
  let written = deque.write_from(src, 0, 4)
  inspect(written, content="4")
  inspect(deque.is_full(), content="true")
  
  // Verify order
  inspect(deque.pop_front(), content="Some(b'\\x43')")  // 'C'
  inspect(deque.pop_front(), content="Some(b'\\x44')")  // 'D'
  inspect(deque.pop_front(), content="Some(b'\\x45')")  // 'E'
  inspect(deque.pop_front(), content="Some(b'\\x46')")  // 'F'
}

///|
/// Tests for combined operations

test "alternating push and pop operations" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(3, () => 0)
  deque.push_back(1) |> ignore
  inspect(deque.pop_front(), content="Some(1)")
  deque.push_back(2) |> ignore
  deque.push_back(3) |> ignore
  inspect(deque.pop_front(), content="Some(2)")
  deque.push_back(4) |> ignore
  deque.push_back(5) |> ignore
  inspect(deque.length(), content="3")
  inspect(deque.is_full(), content="true")
}

///|
test "read_into and write_from combined" {
  let deque : ArrayDeque[Byte] = ArrayDeque::new(6, () => b'\x00')
  
  // Write some data
  let src1 : FixedArray[Byte] = [b'A', b'B', b'C']
  deque.write_from(src1, 0, 3) |> ignore
  
  // Read some data
  let dst : FixedArray[Byte] = FixedArray::make(5, b'\x00')
  deque.read_into(dst, 0, 2) |> ignore
  inspect(dst[0].to_int(), content="65")  // 'A'
  inspect(dst[1].to_int(), content="66")  // 'B'
  
  // Write more data
  let src2 : FixedArray[Byte] = [b'D', b'E', b'F', b'G']
  let written = deque.write_from(src2, 0, 4)
  inspect(written, content="4")
  
  // Verify all remaining data
  inspect(deque.length(), content="5")
  inspect(deque.pop_front(), content="Some(b'\\x43')")  // 'C'
  inspect(deque.pop_front(), content="Some(b'\\x44')")  // 'D'
  inspect(deque.pop_front(), content="Some(b'\\x45')")  // 'E'
  inspect(deque.pop_front(), content="Some(b'\\x46')")  // 'F'
  inspect(deque.pop_front(), content="Some(b'\\x47')")  // 'G'
}

///|
/// Edge case tests

test "single element capacity deque" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(1, () => 0)
  inspect(deque.push_back(42), content="true")
  inspect(deque.is_full(), content="true")
  inspect(deque.push_back(43), content="false")
  inspect(deque.pop_front(), content="Some(42)")
  inspect(deque.is_empty(), content="true")
  inspect(deque.push_back(44), content="true")
  inspect(deque.pop_front(), content="Some(44)")
}

///|
test "large capacity deque" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(100, () => 0)
  // Fill half
  let mut i = 0
  while i < 50 {
    deque.push_back(i) |> ignore
    i = i + 1
  }
  inspect(deque.length(), content="50")
  inspect(deque.available(), content="50")
  
  // Remove half
  i = 0
  while i < 25 {
    deque.pop_front() |> ignore
    i = i + 1
  }
  inspect(deque.length(), content="25")
  
  // Add more
  i = 50
  while i < 75 {
    deque.push_back(i) |> ignore
    i = i + 1
  }
  inspect(deque.length(), content="50")
}

///|
test "stress test with many wrap-arounds" {
  let deque : ArrayDeque[Int] = ArrayDeque::new(10, () => 0)
  let mut counter = 0
  let mut iterations = 0
  
  // Perform many operations to ensure wrap-around happens multiple times
  while iterations < 100 {
    deque.push_back(counter) |> ignore
    counter = counter + 1
    
    if counter % 3 == 0 {
      deque.pop_front() |> ignore
    }
    iterations = iterations + 1
  }
  
  // Drain and verify FIFO order is maintained
  let mut last_value = -1
  while not(deque.is_empty()) {
    match deque.pop_front() {
      Some(v) => {
        if last_value >= 0 {
          inspect(v > last_value, content="true")
        }
        last_value = v
      }
      None => break
    }
  }
}
