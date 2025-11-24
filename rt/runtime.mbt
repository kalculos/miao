///|
pub type CancellationToken = () -> Unit raise

///|
type ResolvedToken

///|
pub(open) trait Runtime {
  async unsafe_suspend(
    Self,
    ((ResolvedToken) -> Unit, (Error) -> Unit, &Task) -> CancellationToken,
  ) -> ResolvedToken
  new_task(Self, task : async (&Task) -> Unit) -> &Task raise
  async sleep(Self, time_millis : UInt64) -> Unit
}

///|
pub async fn[T] &Runtime::suspend(
  self : &Runtime,
  f : ((T) -> Unit, (Error) -> Unit, &Task) -> CancellationToken,
) -> T {
  self.unsafe_suspend((resolve, reject, task) => f(
    result => resolve(anycast(result)),
    err => reject(err),
    task,
  ))
  |> anycast
}

///|
fn[I, T] anycast(input : I) -> T = "%identity"
