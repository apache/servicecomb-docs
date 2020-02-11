File downloads are currently available in the vertx rest channel and servlet rest.

# First, producer

## 1. Download normal files

```
return new File(......);
```

## 2. Download temporary files

In this scenario, you need to create temporary files based on the request parameters dynamically. After the download is complete, you need to delete the temporary files.

```
return new FilePart(file).setDeleteAfterFinished(true);
```

## 3. Download org.springframework.core.io.Resource

Because the resource does not necessarily mean file download, you need to identify this file download scenario by swagger annotation (@ApiResponse).

Take ByteArrayResource as an example:

```
@GetMapping(path = "/resource")
@ApiResponses({
  @ApiResponse(code = 200, response = File.class, message = "")
})
public Resource resource() {
  ......
  return new ByteArrayResource(bytes) {
    @Override
    public String getFilename() {
      return "resource.txt";
    }
  };
}
```

In the above example, because ByteArrayResource does not have the concept of a file name, you need to implement the resource's getFilename method, or you can wrap it with ResponseEntity:

```
@GetMapping(path = "/resource")
@ApiResponses({
  @ApiResponse(code = 200, response = File.class, message = "")
})
public ResponseEntity<Resource> resource() {
  ......
  return ResponseEntity
      .ok()
      .header(HttpHeaders.CONTENT_TYPE, MediaType.TEXT_PLAIN_VALUE)
      .header(HttpHeaders.CONTENT_DISPOSITION, "attachment;filename=resource.txt")
      .body(resource);
}
```

## 4.Download InputStream

Because InputStream does not mean file downloading for sure, it needs to be annotated by 'swagger annotation' (@ApiResponse). This is a file download scenario.

In some scenarios, resources are not stored locally.
```
return ResponseEntity
    .ok()
    .header(HttpHeaders.CONTENT_TYPE, MediaType.TEXT_PLAIN_VALUE)
    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment;filename=resource.txt")
    .body(stream);
```

After the download is complete, ServiceComb will automatically close the stream, and developers don't have to pay attention

## 5. File type determination

As long as the HttpHeaders.CONTENT\_TYPE is not set directly via ResponseEntity, ServiceComb will try to automatically determine the file name suffix in File, Part, and Resource.

ServiceComb uses java's mime type mechanism for file type determination. If the file suffix in the business scenario cannot be identified, ServiceComb will default to application/octet-stream.

If this does not meet the requirements, assuming the file suffix is, and the expected file type is application/file-xyz, any of the following methods can be resolved:

### 1) Extend via Java's mime type mechanism

In the META-INF directory, create a mime.  Types file with the contents:

```
application/file-xyz xyz
```

### 2) Specify by Part in the business code

```
return new FilePart(null, file).contentType("application/file-xyz");
```

### 3) specified in the business code by ResponseEntity

```
return ResponseEntity
    .ok()
    .header(HttpHeaders.CONTENT_TYPE, "application/file-xyz")
    .body(……);
    .body(...);
```

## 6.File name

As long as HttpHeaders.CONTENT\_DISPOSITION is not set directly via ResponseEntity, ServiceComb will try to generate HttpHeaders.CONTENT\_DISPOSITION through the file names in File, Part, and Resource. Assuming the file name is file.txt, the generated data is as follows:

```
Content-Disposition: attachment;filename=file.txt;filename*=utf-8’’file.txt
```

Not only the filename is generated, but also filename\* is generated. This is because if there is Chinese, space, and filename correctly in the file name, i.e., chrome is fine, but firefox directly treats the string after the encoding as a text. The name of the item is used directly. Firefox only decodes filename\* according to [https://tools.ietf.org/html/rtf6266] (https://tools.ietf.org/html/rtf6266).

If Content-Disposition is set directly in the business code, you need to handle the problems supported by multiple browsers.

# Second, Consumer

The consumer side uses org.apache.servicecomb.foundation.vertx.http.ReadStreamPart to process file downloads.

## 1. Transparent RPC

```
public interface ......{
  ReadStreamPart download1(...);
  ReadStreamPart download2(...);
}
```

## 2.RestTemplate

Take get as an example:

```
ReadStreamPart part = restTemplate.getForObject(url, ReadStreamPart.class);
```

## 3. Read data from ReadStreamPart

ReadStreamPart provides a set of methods to save the data stream as local data:

```
org.apache.servicecomb.foundation.vertx.http.ReadStreamPart.saveAsBytes()
org.apache.servicecomb.foundation.vertx.http.ReadStreamPart.saveAsString()
org.apache.servicecomb.foundation.vertx.http.ReadStreamPart.saveToFile(String)
org.apache.servicecomb.foundation.vertx.http.ReadStreamPart.saveToFile(File, OpenOptions)
```

note:

* When the ReadStreamPart instance is obtained, the file content is not downloaded. The save or other methods is called to start reading the file data from the network.

* If you use saveAsBytes, saveAsString, the data is directly stored in the memory; if the downloaded file is large, there will be a risk of memory explosion.

* The save series method returns all CompletableFuture objects:

  * If you want to block waiting for the download to complete, you can use future.get\(\)
  * If asynchronous callback processing is performed through future.whenComplete, be aware that callbacks occur in network threads, and you must follow the reactive thread rules.
