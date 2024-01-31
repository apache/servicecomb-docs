# HTTP参数映射参考

HTTP协议是一个文本传输协议，RESTFul框架核心部分，就是将语言对象与HTTP协议的组成部件映射起来，提供远程过程调用(RPC)能力。 HTTP的请求响应可以简化描述为：

* 请求

```text
GET /apps HTTP/1.1

Host: 127.0.0.1:8080
Accept-Language: zh
Content-Type: application/x-www-form-urlencoded

queryParamExample1=example1&queryParamExample2=example2
```

* 响应

```text
Host: 127.0.0.1:8080
Content-Type: application/x-www-form-urlencoded

queryParamExample1=example1&queryParamExample2=example2
```

## HTTP请求参数映射

### Query

Query参数属于HTTP协议URL的一部分，比如:

```text
GET /apps?queryParamExample1=example1&queryParamExample2=example2 HTTP/1.1
Host: 127.0.0.1:8080
Accept-Language: zh
```

定义了Query参数 `queryParamExample1` 和 `queryParamExample2`。

* Spring MVC

```java
@GetMapping("")
public String queryExample(@RequestParam("queryParamExample1") String example1,
    @RequestParam("queryParamExample2") String example2)
```

* JAX-RS

```java
@GET
@Path("")
public String queryJAXRSExample(@QueryParam("queryParamExample1") String example1,
    @QueryParam("queryParamExample2") String example2)
```

### Path

Path参数属于HTTP协议URL的一部分，比如:

```text
GET /apps/pathParamExample1/pathParamExample2 HTTP/1.1
Host: 127.0.0.1:8080
Accept-Language: zh
```

定义了Path参数 `pathParamExample1` 和 `pathParamExample2`。

* Spring MVC

```java
@GetMapping("/{pathParamExample1}/{pathParamExample2}")
public String pathSpringMVCExample(@PathVariable("pathParamExample1") String example1,
    @PathVariable("pathParamExample2") String example2)
```

* JAX-RS

```java
@GET
@Path("/{pathParamExample1}/{pathParamExample2}")
public String pathJAXRSExample(@PathParam("pathParamExample1") String example1,
    @PathParam("pathParamExample2") String example2) 
```

### Header

Header对应于HTTP协议请求头，比如:

```text
GET /apps HTTP/1.1
Host: 127.0.0.1:8080
Accept-Language: zh
headerParamExample1: example1
headerParamExample2: example2
```

定义了Header参数 `headerParamExample1` 和 `headerParamExample2`。

* Spring MVC

```java
@GetMapping("")
public String headerSpringMVCExample(@RequestHeader("headerParamExample1") String example1,
    @RequestHeader("headerParamExample2") String example2)
```

* JAX-RS

```java
@GET
@Path("")
public String headerJAXRSExample(@HeaderParam("headerParamExample1") String example1,
    @HeaderParam("headerParamExample2") String example2)
```

### application/x-www-form-urlencoded

当 HTTP 消息体是 `application/x-www-form-urlencoded`， 可以使用 Form 参数。 

```text
GET /apps HTTP/1.1
Host: 127.0.0.1:8080
Accept-Language: zh
Content-Type: application/x-www-form-urlencoded

queryParamExample1=example1&queryParamExample2=example2
```

* Spring MVC

```java
@GetMapping(path = "formSpringMVCExample", consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
public String formSpringMVCExample(@RequestAttribute("formParamExample1") String example1,
    @RequestAttribute("formParamExample2") String example2)
```

>>> 原生 Spring MVC 的 RequestAttribute 表示 HTTP 的 Attribute， 使用 RequestParam 表示 form 参数，这会导致代码生成契约的时候产生歧义。 Java Chassis 3 推荐使用 RequestAttribute 表示Form参数。

* JAX-RS

```java
@GET
@Path("formJAXRSExample")
@Consumes(MediaType.APPLICATION_FORM_URLENCODED)
public String formJAXRSExample(@FormParam("formParamExample1") String example1,
    @FormParam("formParamExample2") String example2)
```

### application/json

当 HTTP 消息体是 `application/json`， 使用json进行对象序列化。

```text
GET /apps HTTP/1.1
Host: 127.0.0.1:8080
Accept-Language: zh
Content-Type: application/json

{"name": "wang", "age": 20}
```

* Spring MVC

```java
@PostMapping(path = "jsonSpringMVCExample", consumes = MediaType.APPLICATION_JSON_VALUE)
public String jsonSpringMVCExample(@RequestBody Person person) 
```

* JAX-RS

```java
@POST
@Path("jsonJAXRSExample")
@Consumes(jakarta.ws.rs.core.MediaType.APPLICATION_JSON)
public String jsonJAXRSExample(Person person)
```

>>> JAX-RS没有声明标签的时候表示Body参数。 

### application/protobuf

当 HTTP 消息体是 `application/protobuf`， 使用protobuf进行对象序列化。

```text
GET /apps HTTP/1.1
Host: 127.0.0.1:8080
Accept-Language: zh
Content-Type: application/protobuf

proto-buffer-binary-data
```

* Spring MVC

```java
@PostMapping(path = "protobufSpringMVCExample", consumes = SwaggerConst.PROTOBUF_TYPE)
public String protobufSpringMVCExample(@RequestBody Person person)
```

* JAX-RS

```java
@POST
@Path("protobufJAXRSExample")
@Consumes(SwaggerConst.PROTOBUF_TYPE)
public String protobufJAXRSExample(Person person)
```

>>> JAX-RS没有声明标签的时候表示Body参数。

### application/text

当 HTTP 消息体是 `application/text`， 使用json进行对象序列化。

>>> application/text 和 application/json 在对象序列化上都采用 json，对于大多数场景两者是等价的。只有当对象类型为 String 的时候， 存在差异：application/text 的 String 序列化后的文本没有双引号；application/json 的 String 序列化后的文本有双引号；

```text
GET /apps HTTP/1.1
Host: 127.0.0.1:8080
Accept-Language: zh
Content-Type: application/text

{"name": "wang", "age": 20}
```

* Spring MVC

```java
@PostMapping(path = "textSpringMVCExample", consumes = MediaType.TEXT_PLAIN_VALUE)
public String textSpringMVCExample(@RequestBody Person person)
```

* JAX-RS

```java
@POST
@Path("textJAXRSExample")
@Consumes(MediaType.TEXT_PLAIN)
public String textJAXRSExample(Person person) 
```

>>> JAX-RS没有声明标签的时候表示Body参数。

### 文件上传：multipart/form-data

当 HTTP 消息体是 `multipart/form-data`， 表示文件上传。

```text
GET /apps HTTP/1.1
Host: 127.0.0.1:8080
Accept-Language: zh
Content-Type: multipart/form-data; boundary=----boundary-example----

----boundary-example----
Content-Disposition: form-data; name="multiPartParamExample1"

contents of multiPartParamExample1
----boundary-example----
Content-Disposition: form-data; name="multiPartParamExample2"

contents of multiPartParamExample2
----boundary-example----
```

>>> multipart/form-data 也可以表示 Form 参数， 和 application/x-www-form-urlencoded 用法一样。为了避免混淆和简洁，建议multipart/form-data用于文件上传场景。

```java
@PostMapping(path = "multiPartSpringMVCExample", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
public String multiPartSpringMVCExample(@RequestPart("multiPartParamExample1") MultipartFile example1,
    @RequestPart("multiPartParamExample2") MultipartFile example2)
```

* JAX-RS

```java
@POST
@Path("multiPartJAXRSExample")
@Consumes(MediaType.MULTIPART_FORM_DATA)
public String multiPartJAXRSExample(@FormParam("multiPartParamExample1") Part example1,
    @FormParam("multiPartParamExample2") Part example2)
```

## HTTP响应参数映射

### 状态码 和 Header

在没有特殊声明的情况下，正常响应的状态码是 `200`，也可以声明其他状态码。

>>> Java Chassis 2xx 状态码表示正常响应，会进行对象序列化。 可以使用 `@ApiResponse` 自定义状态码，所有 2xx 状态码声明的对象类型必须一样。 其他状态码表示异常，会对 `InvocationException` 进行序列化，不要求对象类型一样。 

* Spring MVC

```java
@PostMapping(path = "statusHeaderSpringMVCExample")
@ApiResponses(value = {
    @ApiResponse(
        responseCode = "200",
        content = @Content(schema = @Schema(implementation = Person.class)),
        headers = {
            @Header(name = "h1", schema = @Schema(implementation = String.class)),
            @Header(name = "h2", schema = @Schema(implementation = String.class))}),
    @ApiResponse(
        responseCode = "202",
        content = @Content(schema = @Schema(implementation = Person.class)),
        headers = {
            @Header(name = "h1", schema = @Schema(implementation = String.class)),
            @Header(name = "h2", schema = @Schema(implementation = String.class))}),
    @ApiResponse(
        responseCode = "400",
        content = @Content(schema = @Schema(implementation = MultiResponse400.class)),
        headers = {
            @Header(name = "h1", schema = @Schema(implementation = String.class)),
            @Header(name = "h2", schema = @Schema(implementation = String.class))})})
public ResponseEntity<Person> statusHeaderSpringMVCExample(@RequestBody Person person) {
    return ResponseEntity.status(200).header("h1", "h1")
    .header("h2", "h2").body(person);
}
```

* JAX-RS

```java
@PostMapping(path = "statusHeaderJAXRSExample")
@ApiResponses(value = {
    @ApiResponse(
        responseCode = "200",
        content = @Content(schema = @Schema(implementation = Person.class)),
        headers = {
            @Header(name = "h1", schema = @Schema(implementation = String.class)),
            @Header(name = "h2", schema = @Schema(implementation = String.class))}),
    @ApiResponse(
        responseCode = "202",
        content = @Content(schema = @Schema(implementation = Person.class)),
        headers = {
            @Header(name = "h1", schema = @Schema(implementation = String.class)),
            @Header(name = "h2", schema = @Schema(implementation = String.class))}),
    @ApiResponse(
        responseCode = "400",
        content = @Content(schema = @Schema(implementation = MultiResponse400.class)),
        headers = {
            @Header(name = "h1", schema = @Schema(implementation = String.class)),
            @Header(name = "h2", schema = @Schema(implementation = String.class))})})
public Response statusHeaderJAXRSExample(@RequestBody Person person) {
    return Response.status(200).entity(new Person()).header("h1", "h1")
    .header("h2", "h2").build();
}
```

### application/json

响应类型根据 `Accept` 来确定，默认是 application/json。 也可以声明接口只支持 application/json 响应。 

* Spring MVC

```java
@PostMapping(path = "produceJsonSpringMVCExample", produces = MediaType.APPLICATION_JSON_VALUE)
public Person produceJsonSpringMVCExample()
```

* JAX-RS

```java
@POST
@Path("produceJsonJAXRSExample")
@Produces(MediaType.APPLICATION_JSON)
public Person produceJsonJAXRSExample() 
```

### application/protobuf

响应类型根据 `Accept` 来确定，默认是 application/json。 也可以声明接口只支持 application/protobuf 响应。

* Spring MVC

```java
@PostMapping(path = "produceProtobufSpringMVCExample", produces = SwaggerConst.PROTOBUF_TYPE)
public Person produceProtobufSpringMVCExample()
```

* JAX-RS

```java
@POST
@Path("produceProtobufJAXRSExample")
@Produces(SwaggerConst.PROTOBUF_TYPE)
public Person produceProtobufJAXRSExample() 
```

### application/text

响应类型根据 `Accept` 来确定，默认是 application/json。 也可以声明接口只支持 application/text 响应。

* Spring MVC

```java
@PostMapping(path = "produceTextSpringMVCExample", produces = MediaType.TEXT_PLAIN_VALUE)
public Person produceTextSpringMVCExample()
```

* JAX-RS

```java
@POST
@Path("produceTextJAXRSExample")
@Produces(MediaType.TEXT_PLAIN)
public Person produceTextJAXRSExample() 
```

### 文件下载

Java Chassis提供了通用的 `文件下载` 支持。 如果返回值类型为 `File`、`Resource`、`InputStream`、`Part` 等，则被认为是 `文件下载`。 文件MIME类型和文件名可以使用 `Part` 的 API 指定。

* Spring MVC

```java
@GetMapping(path = "/downloadSpringMVCExample")
public Part downloadSpringMVCExample(String content) throws IOException {
    File file = createTempFile(content);
    return new FilePart(null, file)
        .setDeleteAfterFinished(true)
        .setSubmittedFileName("test.bin")
        .contentType("application/octet-stream");
}
```

上述接口会返回如下响应头:

```text
Content-Disposition: attachment;filename=test.bin;filename*=utf-8’’test.bin
Content-Encoding: gzip
Content-Type: application/octet-stream
Transfer-Encoding: chunked
```

* JAX-RS

```java
@GET
@Path("/downloadSpringMVCExample")
public Part downloadSpringMVCExample(String content) throws IOException {
    File file = createTempFile(content);
    return new FilePart(null, file)
        .setDeleteAfterFinished(true)
        .setSubmittedFileName("test.bin")
        .contentType("application/octet-stream");
}
```

上述接口会返回如下响应头:

```text
Content-Disposition: attachment;filename=test.bin;filename*=utf-8’’test.bin
Content-Encoding: gzip
Content-Type: application/octet-stream
Transfer-Encoding: chunked
```
