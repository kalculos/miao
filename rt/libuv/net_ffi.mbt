///|
/// FFI declarations for sockaddr accessors
extern "C" fn mbt_miao_get_safamily(addr : @uv.Sockaddr) -> UInt16 = "mbt_miao_get_safamily"

///|
extern "C" fn mbt_miao_get_sadata(addr : @uv.Sockaddr) -> Bytes = "mbt_miao_get_sadata"

///|
/// IPv4 sockaddr_in accessors
extern "C" fn mbt_miao_get_sin_port(addr : @uv.Sockaddr) -> UInt16 = "mbt_miao_get_sin_port"

///|
extern "C" fn mbt_miao_get_sin_addr(addr : @uv.Sockaddr) -> Bytes = "mbt_miao_get_sin_addr"

///|
/// IPv6 sockaddr_in6 accessors
extern "C" fn mbt_miao_get_sin6_port(addr : @uv.Sockaddr) -> UInt16 = "mbt_miao_get_sin6_port"

///|
extern "C" fn mbt_miao_get_sin6_addr(addr : @uv.Sockaddr) -> Bytes = "mbt_miao_get_sin6_addr"

///|
extern "C" fn mbt_miao_get_sin6_flowinfo(addr : @uv.Sockaddr) -> UInt = "mbt_miao_get_sin6_flowinfo"

///|
extern "C" fn mbt_miao_get_sin6_scope_id(addr : @uv.Sockaddr) -> UInt = "mbt_miao_get_sin6_scope_id"

///|
/// Unix domain socket sockaddr_un accessors
extern "C" fn mbt_miao_get_sun_path(addr : @uv.Sockaddr) -> Bytes = "mbt_miao_get_sun_path"

///|
extern "C" fn mbt_miao_safamily_inet() -> UInt16 = "mbt_miao_safamily_inet"

///|
extern "C" fn mbt_miao_safamily_inet6() -> UInt16 = "mbt_miao_safamily_inet6"

///|
extern "C" fn mbt_miao_safamily_unix() -> UInt16 = "mbt_miao_safamily_unix"

///|
let _AF_INET : UInt16 = mbt_miao_safamily_inet()

///|
let _AF_INET6 : UInt16 = mbt_miao_safamily_inet6()

///|
let _AF_UNIX : UInt16 = mbt_miao_safamily_unix()
