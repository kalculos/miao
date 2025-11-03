///|
pub fn LibuvRuntime::run(entry : async () -> Unit noraise) -> Unit raise {
  let rt = LibuvRuntime::default()
  @rt._current_runtime.val = () => current_coroutine()
    .map(it => it.rt)
    .unwrap_or(rt)
  @fs.set_default_fs(LibuvFileSystem::{ rt, })
  @net.set_network(UvNetwork::{ rt, })
  ___run_async(() => {
    let task = assert_uvtask(rt.new_task(_ => entry()))
    ___suspend((resolve, _) => task.on_exit(Any, () => resolve(())) |> ignore) catch {
      _ => panic()
    }
  })
}

///|
fn assert_uvtask(task : &@rt.Task) -> UvTask = "%identity"