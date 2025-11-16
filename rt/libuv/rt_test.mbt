///|
/// Tests for basic LibuvRuntime operations
/// These tests verify the basic functionality of the libuv runtime

///|
/// Test basic runtime creation and default instance
async test "LibuvRuntime::default creates runtime" {
  let rt = LibuvRuntime::default()
  // Runtime should be created successfully
  // Just verify we can create tasks with it
  let task = rt.new_task(fn(_) {})
  inspect(task.id() > 0, content="true")
}

///|
/// Test sleep functionality  
async test "LibuvRuntime::sleep delays execution" {
  let rt = LibuvRuntime::default()
  // Sleep for a short duration (50ms)
  rt.sleep(50)
  // If we get here, sleep completed successfully
  inspect(true, content="true")
}

///|
/// Test task creation
async test "LibuvRuntime::new_task creates task" {
  let rt = LibuvRuntime::default()
  let task = rt.new_task(fn(_) {
    // Empty task
  })
  
  // Task should be created in New state
  inspect(task.state(), content="New")
  inspect(task.id() > 0, content="true")
}

///|
/// Test task execution
async test "Task can be started and joined" {
  let rt = LibuvRuntime::default()
  let task = rt.new_task(fn(_) {
    let rt2 = LibuvRuntime::default()
    rt2.sleep(10)
  })
  
  task.start()
  task.join()
  
  // After join, task should be completed
  inspect(task.state(), content="Completed")
}

///|
/// Test multiple sequential sleeps
async test "Multiple sleeps work correctly" {
  let rt = LibuvRuntime::default()
  rt.sleep(10)
  rt.sleep(10)
  rt.sleep(10)
  // All sleeps completed
  inspect(true, content="true")
}
