///|
/// Tests for URI parsing
test "Uri::parse parses simple path" {
  let uri = Uri::parse("/path/to/resource")
  inspect(uri.path(), content="/path/to/resource")
  inspect(uri.fragment(), content="None")
}

///|
test "Uri::parse parses path with query" {
  let uri = Uri::parse("/search?q=moonbit&lang=en")
  inspect(uri.path(), content="/search")
  inspect(uri.get_query("q"), content="Some(\"moonbit\")")
  inspect(uri.get_query("lang"), content="Some(\"en\")")
  inspect(uri.get_query("missing"), content="None")
}

///|
test "Uri::parse parses path with fragment" {
  let uri = Uri::parse("/page#section")
  inspect(uri.path(), content="/page")
  inspect(uri.fragment(), content="Some(\"section\")")
}

///|
test "Uri::parse parses full URI" {
  let uri = Uri::parse("/path?key=value#frag")
  inspect(uri.path(), content="/path")
  inspect(uri.get_query("key"), content="Some(\"value\")")
  inspect(uri.fragment(), content="Some(\"frag\")")
}

///|
test "Uri::parse handles multiple query values" {
  let uri = Uri::parse("/items?tag=a&tag=b&tag=c")
  let tags = uri.get_query_all("tag")
  inspect(tags.length(), content="3")
  inspect(tags[0], content="a")
  inspect(tags[1], content="b")
  inspect(tags[2], content="c")
}

///|
test "Uri::parse handles empty query value" {
  let uri = Uri::parse("/page?flag&key=value")
  inspect(uri.get_query("flag"), content="None")
  inspect(uri.get_query("key"), content="Some(\"value\")")
}

///|
test "url_encode encodes special characters" {
  inspect(url_encode("hello world"), content="hello%20world")
  inspect(url_encode("a+b"), content="a%2Bb")
  inspect(url_encode("100%"), content="100%25")
}

///|
test "url_encode preserves safe characters" {
  inspect(url_encode("abc123-_.~"), content="abc123-_.~")
  inspect(url_encode("ABC"), content="ABC")
}

///|
test "url_decode decodes percent encoding" {
  inspect(url_decode("hello%20world"), content="hello world")
  inspect(url_decode("a%2Bb"), content="a+b")
  inspect(url_decode("100%25"), content="100%")
}

///|
test "url_decode handles plus as space" {
  inspect(url_decode("hello+world"), content="hello world")
  inspect(url_decode("a+b+c"), content="a b c")
}

///|
test "url_encode and url_decode round-trip" {
  let original = "hello world & test=value"
  let encoded = url_encode(original)
  let decoded = url_decode(encoded)
  inspect(decoded, content="hello world & test=value")
}

///|
test "build_query_string builds from map" {
  let params : Map[String, Array[String]] = Map::new()
  params.set("key1", ["value1"])
  params.set("key2", ["value2"])
  let query = build_query_string(params)
  // Order might vary, so just check contains
  inspect(query.contains("key1=value1"), content="true")
  inspect(query.contains("key2=value2"), content="true")
}

///|
test "build_query_string handles multiple values" {
  let params : Map[String, Array[String]] = Map::new()
  params.set("tag", ["a", "b", "c"])
  let query = build_query_string(params)
  inspect(query.contains("tag=a"), content="true")
  inspect(query.contains("tag=b"), content="true")
  inspect(query.contains("tag=c"), content="true")
}

///|
test "Uri::parse handles encoded query values" {
  let uri = Uri::parse("/search?q=hello%20world&name=John%20Doe")
  inspect(uri.get_query("q"), content="Some(\"hello world\")")
  inspect(uri.get_query("name"), content="Some(\"John Doe\")")
}
