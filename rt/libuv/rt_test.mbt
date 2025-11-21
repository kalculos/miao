///|
/// Tests for basic LibuvRuntime operations
/// These tests verify the basic functionality of the libuv runtime

///|
/// Test basic runtime creation and default instance
test "LibuvRuntime::default creates runtime" {
  @libuv.with_test(() => {
    let rt = LibuvRuntime::default()
    // Runtime should be created successfully
    // Just verify we can create tasks with it
    let task = rt.new_task(fn(_) {})
    let task2 = rt.new_task(fn(_) {})
    assert_true(task.id() != task2.id())
    inspect(task.state())
    inspect(task2.state())
  })
}

///|
/// Test sleep functionality  
test "LibuvRuntime::sleep delays execution" {
  @libuv.with_test(() => {
    let rt = LibuvRuntime::default()
    let time = @time.Instant::now()
    // Sleep for a short duration (50ms)
    rt.sleep(50)
    assert_true(@time.Instant::now().is_after(time))
  })
}

///|
/// Test task creation
test "LibuvRuntime::new_task creates task" {
  @libuv.with_test(() => {
    let rt = LibuvRuntime::default()
    let task = rt.new_task(fn(_) {
      // Empty task
    })
    
    // Task should be created in New state
    inspect(task.state(), content="New")
    inspect(task.id() > 0, content="true")
  })
}

///|
/// Test task execution
test "Task can be started and joined" {
  @libuv.with_test(() => {
    let rt = LibuvRuntime::default()
    let task = rt.new_task(fn(_) {
      let rt2 = LibuvRuntime::default()
      rt2.sleep(10)
    })
    
    task.start()
    task.join()
    
    // After join, task should be completed
    inspect(task.state(), content="Completed")
  })
}
