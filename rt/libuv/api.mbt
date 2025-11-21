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
  let err : Ref[Error?] = Ref::new(None)
  let task = rt.new_uv_task(_ => entry())
  task.start()
  task.on_exit(Any, () => rt.uv.stop()) |> ignore
  rt.uv.run(Default)
  rt.uv.close()
  guard err.val is None else { raise err.val.unwrap() }
}

///|
pub fn with_test(entry : async () -> Unit) -> Unit raise {
  let result : Ref[Error?] = Ref::new(None)
  with_runtime(() => entry() catch { e => result.val = Some(e) })
  guard result.val is Some(e) else { return }
  println(e)
  raise e
}
