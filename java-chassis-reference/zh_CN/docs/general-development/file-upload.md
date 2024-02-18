# 文件上传开发指导

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

>>> multipart/form-data 也可以表示 Form 参数， 和 application/x-www-form-urlencoded 用法一样。为了避免混淆和简洁，建议multipart/form-data专用于文件上传场景。

## 服务提供者开发
服务提供者可以采用Spring MVC 或者 Jax RS定义上传接口。

* 采用Spring MVC

```java
@PostMapping(path = "multiPartSpringMVCExample", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
public String multiPartSpringMVCExample(@RequestPart("multiPartParamExample1") MultipartFile example1,
@RequestPart("multiPartParamExample2") MultipartFile example2)
```

文件上传需要通过 @RequestPart 声明参数，参数类型支持 servlet 定义的 javax.servlet.http.Part 类型，也支持
org.springframework.web.multipart.MultipartFile 类型，两种数据类型功能是一致的，MultipartFile 的底
层也是Part。 两种数据类型可以混合使用，比如第一个参数是Part，第二个参数是MultipartFile。 

除了通过定义多个参数的方式上传多个文件，也可以通过List或者数组的方式声明上传多个文件。

```java
@PostMapping(path = "/fileUpload", produces = MediaType.TEXT_PLAIN_VALUE, 
  consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
public String fileUpload(@RequestPart(name = "files")  List<MultipartFile> files)

@PostMapping(path = "/fileUpload", produces = MediaType.TEXT_PLAIN_VALUE, 
  consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
public String fileUpload(@RequestPart(name = "files") MultipartFile[] files)
```

>>> 说明： 使用 List 或者数组，在HTTP参数映射中，多个文件对应于同名的 form 内容，这不是一个好的 API 设计实践。建议非必要不使用 List 或者数组作为文件上传参数。 

可以通过 `@RequestAttribute` 获取其他额外信息。

```java
@PostMapping(path = "multiPartSpringMVCExample", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
public String multiPartSpringMVCExample(@RequestPart("multiPartParamExample1") MultipartFile example1,
@RequestPart("multiPartParamExample2") MultipartFile example2,
     @RequestAttribute("message") String message)
```

>>> 说明：`@RequestAttribute` 读取 form 内容， 并将 form 内容转换为 String 类型。 由于 `multipart/form-data` 的 Content-Type 可能存在多样性， 建议文件上传场景不使用 `@RequestAttribute`， 而是使用 `@RequestHeader` 传递额外信息。 

* 采用Jax RS

```java
@POST
@Path("multiPartJAXRSExample")
@Consumes(MediaType.MULTIPART_FORM_DATA)
public String multiPartJAXRSExample(@FormParam("multiPartParamExample1") Part example1,
@FormParam("multiPartParamExample2") Part example2)
```

文件上传需要通过 @FormParam 声明参数，参数类型支持servlet定义的javax.servlet.http.Part类型。

除了通过定义多个参数的方式上传多个文件，也可以通过List或者数组的方式声明上传多个文件。

```java
@Path("/fileUpload")
@POST
@Produces(MediaType.TEXT_PLAIN)
public String fileUpload(@FormParam(name = "files") List<Part> files)

@Path("/fileUpload")
@POST
@Produces(MediaType.TEXT_PLAIN)
public String fileUpload(@FormParam(name = "files") Part[] files)
```

>>> 说明： 使用 List 或者数组，在HTTP参数映射中，多个文件对应于同名的 form 内容。 尽管在非浏览器场景，使用 List 或者数组会带来便利，但是对于浏览器上传场景则不利于理解。建议非必要不使用 List 或者数组作为文件上传参数。

可以通过@FormParam获取其他额外信息。

```java
@POST
@Path("multiPartJAXRSExample")
@Consumes(MediaType.MULTIPART_FORM_DATA)
public String multiPartJAXRSExample(@FormParam("multiPartParamExample1") Part example1,
@FormParam("multiPartParamExample2") Part example2,
    @FormParam("message") String message)
```

>>> 说明：`@FormParam` 读取 form 内容， 并将 form 内容转换为 String 类型。 由于 `multipart/form-data` 的 Content-Type 可能存在多样性， 建议文件上传场景不使用 `@FormParam`， 而是使用 `@RequestHeader` 传递额外信息。


* 业务开发注意事项

   通过MultipartFile或Part打开流后，记得关闭，否则上传的临时文件会无法删除，导致资源泄露和磁盘空间耗尽。

## 开发服务消费者

可以使用透明 RPC 

```java
 interface UploadIntf {
   String upload(File file);
 }

 @RpcReference(microserviceName = "name", schemaId = "schema")
 UploadIntf uploadIntf;

 String result = uploadIntf.upload(file);
```

或者 RestTemplate 进行文件上传。 

```java
Map<String, Object> map = new HashMap<>();
map.put("file", new FileSystemResource("a file path!"));
map.put("param1", "test");
HttpHeaders headers = new HttpHeaders();
headers.setContentType(org.springframework.http.MediaType.MULTIPART_FORM_DATA);
HttpEntity<Map<String, Object>> entity = new HttpEntity<>(map, headers);

String reseult = template.postForObject(url, entity, String.class);
```

服务消费者不区分服务提供者是 Spring MVC 或者 Jax RS。 在使用透明 RPC 或者 RestTemplate 的时候， 可以使用如下类型与服务提供者的文件对应： 

* java.io.File
* javax.servlet.http.Part
* java.io.InputStream
* org.springframework.core.io.Resource

使用InputStream时，因为是流的方式，此时没有客户端文件名的概念，服务提供者获取到的文件名为null。 如果既要使用内存数据，又想让producer可以获取客户端文件名，可以使用resource类型，继承org.springframework.core.io.ByteArrayResource，且需要实现 getFilename 方法。

## 使用浏览器上传文件

浏览器通过Form的方式上传文件，下面是一个简单的HTML 和 JS 示例

```html
<form id="upload_form" method="POST">
    <p>
        File Name: <input type="file" name="fileName"/>
    </p>
    <p>
        <input type="button" value="Upload" onclick="uploadAction()">
    </p>
</form>
```

事件处理：

```
function uploadAction() {
     var formData = new FormData(document.getElementById("upload_form"));

     $.ajax({
        type: 'POST',
        url: "/api/file-service/upload",
        data: formData,
        processData:false,
        contentType:false,
        success: function (data) {
            console.log(data);
            var error = document.getElementById("error");
            error.textContent="Upload Successfully, file id=" + data;
            error.hidden=false;
        },
        error: function(data) {
            console.log(data);
            var error = document.getElementById("error");
            error.textContent="Upload failed";
            error.hidden=false;
        },
        async: true
    });
```

## 配置参数说明

| 配置项 | 默认值 | 取值范围 | 含义 |
| :--- | :--- | :--- | :--- |
| servicecomb.uploads.directory | null |  | 上传的临时文件保存在哪个目录，**默认值null表示不支持文件上传** |
| servicecomb.uploads.maxSize | -1 |  | http body的最大允许大小，单位byte，默认值-1表示无限制 |

