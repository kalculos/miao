///|
impl Network for Unit with dial(self, net, addr, opts) {
  abort("Network not supported on this runtime")
}

///|
impl Network for Unit with bind(self, net, bind) {
  abort("Network not supported on this runtime")
}

///|
let _network : Ref[&Network] = Ref::new(())

///|
pub fn set_network(network : &Network) -> Unit {
  _network.val = network
}
// todo dialer api facades