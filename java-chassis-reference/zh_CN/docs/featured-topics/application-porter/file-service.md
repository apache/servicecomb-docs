文件上传功能、用户管理功能都只需要提供REST接口，在技术选型上，使用轻量级REST框架。开发新的微服务都涉及到配置微服务信息，写一个新的Main函数，这些公共步骤在文档前面已经描述，后续文档会省略这些内容。

* 增加依赖关系

```
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>solution-basic</artifactId>
    </dependency>
```

* 定义服务接口

服务接口定义上有3种选择：RPC、Spring MVC、JAX RS。 这里选择了Sping MVC，相比RPC需要额外增加Annotation，灵活性在于接口即可以通过RPC的方式在服务内部访问，也可以通过浏览器访问，期望前台js脚本开发者也能够对照生成的契约完成开发。

```
@RestSchema(schemaId = "file")
@RequestMapping(path = "/")
public class FileServiceEndpoint {
    @Autowired
    private FileService fileService;

    /**
     * 上传文件接口，用户上传一个文件，返回文件ID。
     */
    @PostMapping(path = "/upload", produces = MediaType.TEXT_PLAIN_VALUE)
    public String uploadFile(@RequestPart(name = "fileName") MultipartFile file) {
        return fileService.uploadFile(file);
    }

    /**
     * 删除文件接口。指定ID，返回删除成功还是失败.
     */
    @DeleteMapping(path = "/delete", produces = MediaType.APPLICATION_JSON_VALUE)
    public boolean deleteFile(@RequestParam(name = "id") String id) {
        return fileService.deleteFile(id);
    }
}
```

为了实现不同方式的文件存储，将实现抽象出来FileService。为了简单，当前只提供了本地文件实现。这个实现限制了该服务无法进行多实例部署。可以考虑使用对象存储服务器、分布式文件系统等满足存储要求。

* 设置临时目录

需要在microservice.yaml中增加servicecomb.uploads.directory配置项，指定临时目录的路径。需要保证目录有写权限。默认情况下如果没设置临时目录，不允许启用上传功能。如果使用网关，网关也需要增加这个配置项。

* 开发测试HTML，访问上传服务

为了测试开发的接口，可以写一个HTML程序。注意name参数需要和接口定义的名称一样。

```
<!DOCTYPE html>
<html>
<head>
<title>Upload Example</title>
</head>
<body>
    <h2>Upload Example</h2>
    <hr/>
    <form method="POST" enctype="multipart/form-data"
        action="http://localhost:9091/upload">
        <p>
            File Name: <input type="file" name="fileName" />
        </p>
        <p>
            <input type="submit" value="Upload" />
        </p>
    </form>
</body>
</html>
```

可以使用Postman等工具测试删除接口：

```
DELETE http://localhost:9091/delete?id=ba6bd8a2-d31a-42cd-a1be-9fb3d6ab4c82
```

还可以开发一个客户端测试这些接口，对于自动化测试用例是非常有用的。这里不再详细说明。

