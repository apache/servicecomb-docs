File upload, currently supported in vertx rest channel and servlet rest.

File uploads use the standard http form format, which can directly upload the file from the browser.

## Producer:
Support jaxrs and springmvc development mode

Jaxrs development model:
* javax.servlet.http.Part type that supports servlet definitions

* You can directly use @FormParam to pass file types and common parameters

Springmvc development mode:

* Supports servlet-defined javax.servlet.http.Part type, also supports org.springframework.web.multipart.MultipartFile type

* The two datatype functions are consistent, and MultipartFile is also base on Part type

* Two data types can be mixed, for example, the first parameter is Part and the second parameter is MultipartFile

* You can directly use @RequestPart to pass file types and common parameters

note:

* First file upload temporary directory, the default is null does not support file upload, file upload request Content-Type must be multipart/form-data

* The same name parameter only supports one file

* Supports transferring files with multiple different parameter names at one time

* After opening the stream through MultipartFile or Part, remember to close it. Otherwise the uploaded temporary file will not be deleted, and eventually, the upload temporary directory will be exploded.

Sample code in Springmvc mode:

```java
@PostMapping(path = "/upload", consumes = MediaType.MULTIPART_FORM_DATA)
public String fileUpload(@RequestPart(name = "file1") MultipartFile file1, @RequestPart(name = "file2") Part file2, @RequestPart String param1) {
  ......
}
```

### Configuration instructions:

| Configuration Item | Default Value | Range of Value |
| :--- | :--- | :--- | :--- |
| servicecomb.uploads.directory | null | | In which directory the uploaded temporary file is saved, **default value null means file upload is not supported** |
| servicecomb.uploads.maxSize | -1 | | The maximum allowable size of http body in bytes. the default value of -1 means unlimited |

## Consumer:

The following data types are supported:

* java.io.File

* javax.servlet.http.Part

* java.io.InputStream

* org.springframework.core.io.Resource

When using InputStream, because it is a stream, there is no concept of client file name at this time, so the producer will get the client file name will get null.

If you want to use both memory data and the producer to get the client file name, you can use the resource type, inherit org.springframework.core.io.ByteArrayResource, and override getFilename.

### Transparent RPC Code Sample:

```java
interface UploadIntf {
  String upload(File file);
}
```

After getting the interface reference, you can call it directly:

```java
String result = uploadIntf.upload(file);
```

### RestTemplate code example:

```java
Map<String, Object> map = new HashMap<>();
map.put("file", new FileSystemResource("a file path!"));
map.put("param1", "test");
HttpHeaders headers = new HttpHeaders();
headers.setContentType(org.springframework.http.MediaType.MULTIPART_FORM_DATA);
HttpEntity<Map<String, Object>> entry = new HttpEntity<>(map, headers);

String reseult = template.postForObject(
    url,
    entry,
    String.class);
```
