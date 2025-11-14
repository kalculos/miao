///|
test "simple path test" {
  inspect("a/b".split("/").to_array().join("/"), content="a/b")
}
