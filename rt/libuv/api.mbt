///|
let _is_uv_installed : Ref[Bool] = Ref::new(false)

///|
pub fn with_runtime(entry : async () -> Unit noraise) -> Unit raise {
  let rt = LibuvRuntime::default()
  if !_is_uv_installed.val {
    _is_uv_installed.val = true
    @rt._current_runtime.val = () => current_coroutine()
      .map(it => it.rt)
      .unwrap_or(rt)
    @fs.set_default_fs(LibuvFileSystem::{ rt, })
    @net.set_network(UvNet::{ uv: rt })
  }
  ___run_async(() => {
    let task = rt.new_uv_task(_ => entry())
    ___suspend((resolve, _) => task.on_exit(Any, () => resolve(())) |> ignore) catch {
      _ => panic()
    }
  })
}

///|
pub fn with_test(entry : async () -> Unit) -> Unit raise {
  let result : Ref[Error?] = Ref::new(None)
  with_runtime(() => entry() catch { e => result.val = Some(e) })
  guard result.val is Some(e) else { return }
  raise e
}
