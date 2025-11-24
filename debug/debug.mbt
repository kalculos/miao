///|
extern "C" fn ffi_print(len : Int, msg : Bytes) -> Int = "mbt_miao_print_error"

///|
pub fn printerr(str : String) -> Unit {
  let bytes = ((str + "\n").to_array().map(it => it.to_int().to_byte()) + [0b0])
    |> FixedArray::from_array
  ffi_print(bytes.length(), bytes.unsafe_reinterpret_as_bytes()) |> ignore
}
