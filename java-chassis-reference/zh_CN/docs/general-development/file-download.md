# 文件下载开发指导

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

## 服务提供者开发

文件下载服务端定义建议使用 `Part`， 它提供了最丰富的功能，包括指定文件名、文件删除策略以及指定Content-Type等。 Java Chassis也提供了下面的一些类型支持。 

* File

最简单的例子，接口的返回参数声明为 File 类型的参数， 即可定义一个下载接口。 

```
@GetMapping(path = "/file")
public File file(String name)
```

* Resource

可以将接口声明为 org.springframework.core.io.Resource。 由于resource不一定表示文件下载，所以需要通过
@ApiResponse 标识这是一个文件下载场景

以ByteArrayResource为例说明：

```
@GetMapping(path = "/resource")
@ApiResponses({
  @ApiResponse(code = 200, response = File.class, message = "")
})
public Resource resource() {
  return new ByteArrayResource(bytes) {
    @Override
    public String getFilename() {
      return "resource.txt";
    }
  };
}
```

上例中，因为ByteArrayResource没有文件名的概念，所以需要实现Resource的getFilename方法，也可以通过ResponseEntity进行包装：

```
@GetMapping(path = "/resource")
@ApiResponses({
  @ApiResponse(code = 200, response = File.class, message = "")
})
public ResponseEntity<Resource> resource() {
  return ResponseEntity
      .ok()
      .header(HttpHeaders.CONTENT_TYPE, MediaType.TEXT_PLAIN_VALUE)
      .header(HttpHeaders.CONTENT_DISPOSITION, "attachment;filename=resource.txt")
      .body(resource);
}
```

* InputStream

一样的， 使用 InputStream 需要 @ApiResponse 标识这是一个文件下载场景

```
@GetMapping(path = "/inputStream")
@ApiResponses({
  @ApiResponse(code = 200, response = File.class, message = ""),
})
public ResponseEntity<InputStream> download() throws IOException {
    return ResponseEntity
        .ok()
        .header(HttpHeaders.CONTENT_TYPE, MediaType.TEXT_PLAIN_VALUE)
        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment;filename=resource.txt")
        .body(stream);
}
```

在下载完成后，ServiceComb会自动关闭stream，开发人员不必再关注。

* 文件类型判定

只要没有通过ResponseEntity直接设置HttpHeaders.CONTENT\_TYPE，Java Chassis都会尝试通过File、Part、Resource中的文件名后缀进行自动判定。

Java Chassis使用java的mime type机制进行文件类型判定，如果业务场景中的文件后缀无法被识别，Java Chassis会默认处理为application/octet-stream

如果这不满足要求，假设文件后缀为xyz，期望文件类型为application/file-xyz，以下方式任选一种均可解决：

   1. 通过Java的mime type机制扩展

在META-INF目录下，创建mime.types文件，其内容为：

```
application/file-xyz xyz
```

    2. 在业务代码中通过Part指定

```
@GetMapping(path = "/tempFilePart")
public Part tempFilePart(String content) throws IOException {
File file = createTempFile(content);

return new FilePart(null, file)
    .setDeleteAfterFinished(true)
    .contentType("application/file-xyz")
    .setSubmittedFileName("tempFilePart.txt");
}

```

    3. 在业务代码中通过ResponseEntity指定

```
@GetMapping(path = "/tempFileEntity")
public ResponseEntity<Part> tempFileEntity(String content) throws IOException {
    File file = createTempFile(content);
    
    return ResponseEntity
        .ok()
        .header(HttpHeaders.CONTENT_TYPE, "application/file-xyz")
        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment;filename=tempFileEntity.txt")
        .body(new FilePart(null, file)
            .setDeleteAfterFinished(true));
}
```

* 指定文件名

只要没有通过ResponseEntity直接设置HttpHeaders.CONTENT\_DISPOSITION，Java Chassis都会尝试通过File、Part、Resource中的文件名生成HttpHeaders.CONTENT\_DISPOSITION，假设文件名为file.txt，则生成的数据如下：

```
Content-Disposition: attachment;filename=file.txt;filename*=utf-8’’file.txt
```

不仅仅生成 `filename` ，还生成了 `filename\*` ，这是因为如果文件名中出现了中文、空格，并且filename正确地做了encode，ie、chrome都没有问题，但是firefox直接将encode后的串当作文件名直接使用了。firefox按照[https://tools.ietf.org/html/rtf6266](https://tools.ietf.org/html/rtf6266) ，只对 `filename\*` 进行解码。

如果业务代码中直接设置Content-Disposition，需要自行处理多浏览器支持的问题。

## 服务消费者开发

消费者统一使用 org.apache.servicecomb.foundation.vertx.http.ReadStreamPart 处理文件下载。
可以使用透明 RPC 方式， 

```
public interface ……{
  ReadStreamPart download1(……);
  ReadStreamPart download2(……);
}
```

或者 RestTemplate

```
ReadStreamPart part = restTemplate.getForObject(url, ReadStreamPart.class);
```

ReadStreamPart提供了一系列方法，将数据流保存为本地数据：

```
org.apache.servicecomb.foundation.vertx.http.ReadStreamPart.saveAsBytes()
org.apache.servicecomb.foundation.vertx.http.ReadStreamPart.saveAsString()
org.apache.servicecomb.foundation.vertx.http.ReadStreamPart.saveToFile(String)
org.apache.servicecomb.foundation.vertx.http.ReadStreamPart.saveToFile(File, OpenOptions)
```

***注意：***

* 在得到ReadStreamPart实例时，并没有完成文件内容的下载，调用save系列方法才开始真正从网络上读取文件数据。
* 如果使用saveAsBytes、saveAsString，数据是直接保存在内存中的，如果下载的文件很大，会导致内存溢出。
* save系列方法，返回的都是CompletableFuture对象， 如果要阻塞等待下载完成，通过future.get\(\)即可；
 如果通过future.whenComplete进行异步回调处理，要注意回调是发生在网络线程中的，此时需要遵守reactive的线程规则。
