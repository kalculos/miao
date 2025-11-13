struct UvNet {
  uv: LibuvRuntime
}

fn UvNet::uv(self: UvNet) -> LibuvRuntime {
  self.uv
}

pub impl @net.Network for UvNet with dial(self, network, address, options) {

}

pub impl @net.Network for UvNet with bind(self, network, address, options) {

}