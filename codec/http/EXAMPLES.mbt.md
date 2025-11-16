# HTTP Codec 使用示例

这个文档展示了如何使用 `codec/http` 模块来解析和生成 HTTP/1.1 请求和响应。

## 基本概念

HTTP 模块提供了以下主要组件：

- `HttpRequest` - HTTP 请求
- `HttpResponse` - HTTP 响应
- `HttpReader` - 读取和解析 HTTP 消息
- `HttpWriter` - 写入和序列化 HTTP 消息
- `HttpHeaders` - HTTP 头部管理
- `HttpContentReader` - 懒加载的请求/响应体读取器

## 示例 1: 创建和发送简单的 GET 请求

```moonbit
async fn example_simple_get_request() -> Unit {
  // 创建一个 buffer 用于写入请求
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  
  // 创建 GET 请求
  let request = HttpRequest::new(
    HttpMethod::GET,
    "/api/users",
    HttpVersion::HTTP_1_1
  )
  
  // 添加请求头
  request.headers.add("Host", "example.com")
  request.headers.add("User-Agent", "MoonBit-HTTP/1.0")
  request.headers.add("Accept", "application/json")
  
  // 写入请求（GET 请求通常没有 body）
  let empty_body = @buffer.HeapByteBuf::new(0)
  http_writer.write_request(request, empty_body as &@buffer.Buffer)
  
  // 此时 buffer 包含了完整的 HTTP 请求，可以发送到服务器
  let request_bytes = buffer.to_bytes()
  println(@encoding/utf8.decode(request_bytes))
}
```

输出类似：
```
GET /api/users HTTP/1.1
Host: example.com
User-Agent: MoonBit-HTTP/1.0
Accept: application/json

```

## 示例 2: 创建带请求体的 POST 请求

```moonbit
async fn example_post_request_with_json() -> Unit {
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  
  // 创建 POST 请求
  let request = HttpRequest::new(
    HttpMethod::POST,
    "/api/users",
    HttpVersion::HTTP_1_1
  )
  
  // 准备 JSON 请求体
  let json_body = "{\"name\":\"Alice\",\"age\":30}"
  let body_buffer = @buffer.HeapByteBuf::new(100)
  let body_bytes = @encoding/utf8.encode(json_body)
  body_buffer.write(body_bytes.to_fixedarray(), 0, body_bytes.length()) |> ignore
  
  // 添加请求头
  request.headers.add("Host", "example.com")
  request.headers.add("Content-Type", "application/json")
  request.headers.add("Content-Length", json_body.length().to_string())
  
  // 写入请求
  http_writer.write_request(request, body_buffer as &@buffer.Buffer)
  
  let request_bytes = buffer.to_bytes()
  println(@encoding/utf8.decode(request_bytes))
}
```

## 示例 3: 解析 HTTP 请求

```moonbit
async fn example_parse_request() -> Unit {
  // 模拟接收到的 HTTP 请求数据
  let request_str = "GET /api/users?page=1&limit=10 HTTP/1.1\r\n" +
                    "Host: example.com\r\n" +
                    "User-Agent: TestClient/1.0\r\n" +
                    "Accept: application/json\r\n\r\n"
  
  // 将字符串放入 buffer
  let buffer = @buffer.HeapByteBuf::new(1024)
  let bytes = @encoding/utf8.encode(request_str)
  buffer.write(bytes.to_fixedarray(), 0, bytes.length()) |> ignore
  
  // 创建 reader 并解析
  let reader = @io.ByteBufReader::new(buffer as &@buffer.Buffer)
  let http_reader = HttpReader::new(reader as &@io.Reader)
  
  let request = http_reader.read_request() catch {
    error => {
      println("解析失败: \{error}")
      return
    }
  }
  
  // 访问请求信息
  println("Method: \{request.method()}")
  println("URI: \{request.uri}")
  println("Version: \{request.version}")
  println("Host: \{request.headers.get("Host")}")
  println("User-Agent: \{request.headers.get("User-Agent")}")
  
  // 检查是否有请求体
  match request.content_reader() {
    Some(_) => println("有请求体")
    None => println("没有请求体")
  }
}
```

## 示例 4: 解析带请求体的 POST 请求

```moonbit
async fn example_parse_post_with_body() -> Unit {
  let body_content = "name=Alice&age=30"
  let request_str = "POST /api/users HTTP/1.1\r\n" +
                    "Host: example.com\r\n" +
                    "Content-Type: application/x-www-form-urlencoded\r\n" +
                    "Content-Length: " + body_content.length().to_string() + "\r\n\r\n" +
                    body_content
  
  let buffer = @buffer.HeapByteBuf::new(1024)
  let bytes = @encoding/utf8.encode(request_str)
  buffer.write(bytes.to_fixedarray(), 0, bytes.length()) |> ignore
  
  let reader = @io.ByteBufReader::new(buffer as &@buffer.Buffer)
  let http_reader = HttpReader::new(reader as &@io.Reader)
  
  let request = http_reader.read_request() catch {
    error => {
      println("解析失败: \{error}")
      return
    }
  }
  
  println("Method: \{request.method()}")
  println("URI: \{request.uri}")
  
  // 读取请求体（懒加载）
  match request.content_reader() {
    Some(content_reader) => {
      println("Content-Length: \{content_reader.content_length()}")
      
      // 读取所有内容
      let body = content_reader.read_all() catch {
        error => {
          println("读取 body 失败: \{error}")
          return
        }
      }
      
      let body_text = @encoding/utf8.decode(body.to_bytes())
      println("Body: \{body_text}")
    }
    None => println("没有请求体")
  }
}
```

## 示例 5: 创建 HTTP 响应

```moonbit
async fn example_create_response() -> Unit {
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  
  // 创建 200 OK 响应
  let response = HttpResponse::new(
    HttpVersion::HTTP_1_1,
    HttpStatus::ok()
  )
  
  // 准备响应体
  let json_response = "{\"status\":\"success\",\"data\":[1,2,3]}"
  let body_buffer = @buffer.HeapByteBuf::new(100)
  let body_bytes = @encoding/utf8.encode(json_response)
  body_buffer.write(body_bytes.to_fixedarray(), 0, body_bytes.length()) |> ignore
  
  // 添加响应头
  response.headers.add("Content-Type", "application/json")
  response.headers.add("Content-Length", json_response.length().to_string())
  response.headers.add("Server", "MoonBit-Server/1.0")
  response.headers.add("Cache-Control", "no-cache")
  
  // 写入响应
  http_writer.write_response(response, body_buffer as &@buffer.Buffer)
  
  let response_bytes = buffer.to_bytes()
  println(@encoding/utf8.decode(response_bytes))
}
```

## 示例 6: 创建不同状态码的响应

```moonbit
async fn example_different_status_codes() -> Unit {
  // 404 Not Found
  let response_404 = HttpResponse::new(
    HttpVersion::HTTP_1_1,
    HttpStatus::not_found()
  )
  response_404.headers.add("Content-Type", "text/plain")
  println("404 状态: \{response_404.status.code} \{response_404.status.reason}")
  
  // 500 Internal Server Error
  let response_500 = HttpResponse::new(
    HttpVersion::HTTP_1_1,
    HttpStatus::internal_server_error()
  )
  println("500 状态: \{response_500.status.code} \{response_500.status.reason}")
  
  // 301 Moved Permanently
  let response_301 = HttpResponse::new(
    HttpVersion::HTTP_1_1,
    HttpStatus::moved_permanently()
  )
  response_301.headers.add("Location", "https://new-location.com")
  println("301 状态: \{response_301.status.code} \{response_301.status.reason}")
  
  // 自定义状态码
  let custom_status = HttpStatus::new(418, "I'm a teapot")
  let response_custom = HttpResponse::new(HttpVersion::HTTP_1_1, custom_status)
  println("自定义状态: \{response_custom.status.code} \{response_custom.status.reason}")
}
```

## 示例 7: HTTP Headers 操作

```moonbit
fn example_headers_operations() -> Unit {
  let headers = HttpHeaders::new()
  
  // 添加头部
  headers.add("Content-Type", "application/json")
  headers.add("Accept", "application/json")
  headers.add("Accept", "text/html")  // 可以有多个相同名称的头
  
  // 获取头部
  match headers.get("Content-Type") {
    Some(value) => println("Content-Type: \{value}")
    None => println("Content-Type 未设置")
  }
  
  // 获取所有同名头部
  let accepts = headers.get_all("Accept")
  println("Accept 头数量: \{accepts.length()}")
  
  // 设置头部（替换已有的）
  headers.set("Content-Type", "text/html")
  
  // 检查头部是否存在
  if headers.contains("Host") {
    println("包含 Host 头")
  } else {
    println("不包含 Host 头")
  }
  
  // 删除头部
  headers.remove("Accept")
  
  // 获取头部数量
  println("总共 \{headers.length()} 个头部")
}
```

## 示例 8: 处理 URI 和查询参数

```moonbit
fn example_uri_parsing() -> Unit {
  // 解析包含查询参数的 URI
  let uri = Uri::parse("/api/search?q=moonbit&page=1&limit=10")
  
  println("Path: \{uri.path()}")
  
  // 获取单个查询参数
  match uri.get_query("q") {
    Some(value) => println("查询词: \{value}")
    None => println("没有查询词")
  }
  
  // 获取所有同名查询参数
  let pages = uri.get_query_all("page")
  println("page 参数数量: \{pages.length()}")
  
  // 获取 fragment
  match uri.fragment() {
    Some(frag) => println("Fragment: \{frag}")
    None => println("没有 fragment")
  }
  
  // 转回字符串
  println("完整 URI: \{uri.to_string()}")
}
```

## 示例 9: URL 编码和解码

```moonbit
fn example_url_encoding() -> Unit {
  // URL 编码
  let original = "Hello World! 你好"
  let encoded = url_encode(original)
  println("编码后: \{encoded}")
  
  // URL 解码
  let decoded = url_decode(encoded)
  println("解码后: \{decoded}")
  
  // 构建查询字符串
  let params = Map::new()
  params.set("name", ["Alice", "Bob"])
  params.set("age", ["30"])
  
  let query_string = build_query_string(params)
  println("查询字符串: \{query_string}")
}
```

## 示例 10: Cookie 处理

```moonbit
fn example_cookie_handling() -> Unit {
  // 创建 Cookie
  let cookie = Cookie::new("session_id", "abc123")
    .with_path("/")
    .with_domain("example.com")
    .with_max_age(3600)
    .with_secure(true)
    .with_http_only(true)
    .with_same_site(SameSite::Strict)
  
  // 生成 Set-Cookie 头
  let set_cookie_header = cookie.to_set_cookie_string()
  println("Set-Cookie: \{set_cookie_header}")
  
  // 解析 Cookie 头
  let cookie_header = "session_id=abc123; user_pref=dark_mode"
  let cookies = parse_cookie_header(cookie_header)
  
  match cookies.get("session_id") {
    Some(value) => println("Session ID: \{value}")
    None => println("没有 session_id")
  }
  
  // 解析 Set-Cookie 头
  let set_cookie = "session_id=abc123; Path=/; HttpOnly; Secure"
  match parse_set_cookie(set_cookie) {
    Some(parsed) => {
      println("Cookie 名称: \{parsed.name}")
      println("Cookie 值: \{parsed.value}")
      println("HttpOnly: \{parsed.http_only}")
      println("Secure: \{parsed.secure}")
    }
    None => println("解析失败")
  }
}
```

## 示例 11: 完整的请求-响应循环

```moonbit
async fn example_full_request_response_cycle() -> Unit {
  // 1. 客户端创建请求
  let request_buffer = @buffer.HeapByteBuf::new(1024)
  let request_writer = @io.ByteBufWriter::new(request_buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(request_writer as &@io.Writer)
  
  let request = HttpRequest::new(
    HttpMethod::POST,
    "/api/login",
    HttpVersion::HTTP_1_1
  )
  request.headers.add("Host", "api.example.com")
  request.headers.add("Content-Type", "application/json")
  
  let request_body = "{\"username\":\"alice\",\"password\":\"secret\"}"
  request.headers.add("Content-Length", request_body.length().to_string())
  
  let req_body_buffer = @buffer.HeapByteBuf::new(100)
  let req_body_bytes = @encoding/utf8.encode(request_body)
  req_body_buffer.write(req_body_bytes.to_fixedarray(), 0, req_body_bytes.length()) |> ignore
  
  http_writer.write_request(request, req_body_buffer as &@buffer.Buffer)
  
  // 2. 服务器解析请求
  let req_reader = @io.ByteBufReader::new(request_buffer as &@buffer.Buffer)
  let http_reader = HttpReader::new(req_reader as &@io.Reader)
  
  let parsed_request = http_reader.read_request() catch {
    error => {
      println("解析请求失败: \{error}")
      return
    }
  }
  
  println("服务器收到: \{parsed_request.method()} \{parsed_request.uri}")
  
  // 读取请求体
  match parsed_request.content_reader() {
    Some(content_reader) => {
      let body = content_reader.read_all() catch {
        error => {
          println("读取请求体失败: \{error}")
          return
        }
      }
      println("请求体: \{@encoding/utf8.decode(body.to_bytes())}")
    }
    None => ()
  }
  
  // 3. 服务器创建响应
  let response_buffer = @buffer.HeapByteBuf::new(1024)
  let response_writer = @io.ByteBufWriter::new(response_buffer as &@buffer.Buffer)
  let http_response_writer = HttpWriter::new(response_writer as &@io.Writer)
  
  let response = HttpResponse::new(
    HttpVersion::HTTP_1_1,
    HttpStatus::ok()
  )
  
  let response_body = "{\"token\":\"xyz789\",\"expires_in\":3600}"
  response.headers.add("Content-Type", "application/json")
  response.headers.add("Content-Length", response_body.length().to_string())
  
  let res_body_buffer = @buffer.HeapByteBuf::new(100)
  let res_body_bytes = @encoding/utf8.encode(response_body)
  res_body_buffer.write(res_body_bytes.to_fixedarray(), 0, res_body_bytes.length()) |> ignore
  
  http_response_writer.write_response(response, res_body_buffer as &@buffer.Buffer)
  
  // 4. 客户端解析响应
  let res_reader = @io.ByteBufReader::new(response_buffer as &@buffer.Buffer)
  let http_res_reader = HttpReader::new(res_reader as &@io.Reader)
  
  let parsed_response = http_res_reader.read_response() catch {
    error => {
      println("解析响应失败: \{error}")
      return
    }
  }
  
  println("客户端收到状态: \{parsed_response.status.code} \{parsed_response.status.reason}")
  
  match parsed_response.content_reader {
    Some(content_reader) => {
      let body = content_reader.read_all() catch {
        error => {
          println("读取响应体失败: \{error}")
          return
        }
      }
      println("响应体: \{@encoding/utf8.decode(body.to_bytes())}")
    }
    None => ()
  }
}
```

## 示例 12: 状态码检查工具函数

```moonbit
fn example_status_code_checks() -> Unit {
  let statuses = [
    HttpStatus::ok(),
    HttpStatus::not_found(),
    HttpStatus::internal_server_error(),
    HttpStatus::moved_permanently(),
    HttpStatus::continue_(),
  ]
  
  for i = 0; i < statuses.length(); i = i + 1 {
    let status = statuses[i]
    println("\n状态 \{status.code} \{status.reason}:")
    println("  信息性: \{status.is_informational()}")
    println("  成功: \{status.is_success()}")
    println("  重定向: \{status.is_redirection()}")
    println("  客户端错误: \{status.is_client_error()}")
    println("  服务器错误: \{status.is_server_error()}")
    println("  任何错误: \{status.is_error()}")
  }
}
```

## 常用 HTTP 方法

模块支持所有标准 HTTP 方法：

- `HttpMethod::GET` - 获取资源
- `HttpMethod::POST` - 创建资源
- `HttpMethod::PUT` - 更新资源
- `HttpMethod::DELETE` - 删除资源
- `HttpMethod::HEAD` - 获取头部
- `HttpMethod::OPTIONS` - 获取选项
- `HttpMethod::PATCH` - 部分更新
- `HttpMethod::CONNECT` - 建立隧道
- `HttpMethod::TRACE` - 回显请求

## 常用 HTTP 状态码

模块提供了所有常见状态码的快捷构造函数：

**1xx 信息性**
- `HttpStatus::continue_()` - 100
- `HttpStatus::switching_protocols()` - 101

**2xx 成功**
- `HttpStatus::ok()` - 200
- `HttpStatus::created()` - 201
- `HttpStatus::accepted()` - 202
- `HttpStatus::no_content()` - 204

**3xx 重定向**
- `HttpStatus::moved_permanently()` - 301
- `HttpStatus::found()` - 302
- `HttpStatus::see_other()` - 303
- `HttpStatus::not_modified()` - 304
- `HttpStatus::temporary_redirect()` - 307
- `HttpStatus::permanent_redirect()` - 308

**4xx 客户端错误**
- `HttpStatus::bad_request()` - 400
- `HttpStatus::unauthorized()` - 401
- `HttpStatus::forbidden()` - 403
- `HttpStatus::not_found()` - 404
- `HttpStatus::method_not_allowed()` - 405
- `HttpStatus::conflict()` - 409
- `HttpStatus::unprocessable_entity()` - 422
- `HttpStatus::too_many_requests()` - 429

**5xx 服务器错误**
- `HttpStatus::internal_server_error()` - 500
- `HttpStatus::not_implemented()` - 501
- `HttpStatus::bad_gateway()` - 502
- `HttpStatus::service_unavailable()` - 503
- `HttpStatus::gateway_timeout()` - 504

## 注意事项

1. **懒加载请求体**：`HttpContentReader` 提供了懒加载的方式读取请求/响应体，这样可以更高效地处理大文件或流式数据。

2. **异步操作**：所有涉及 I/O 的操作都是异步的（使用 `async`），需要在异步上下文中调用。

3. **错误处理**：解析操作可能会失败，使用 `catch` 来处理错误。

4. **头部大小写**：HTTP 头部名称是大小写不敏感的，`HttpHeaders` 会自动处理。

5. **Content-Length**：发送带 body 的请求时，记得设置正确的 `Content-Length` 头部。
