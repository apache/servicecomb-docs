# JAVA应用方式开发步骤


使用JAVA方式集成，为Spring Boot应用增加了一个高效的HTTP服务器和REST开发框架。这种方式集成非常简单。只需要在项目中引入相关依赖，并且使用@EnableServiceComb注解即可。

* 引入依赖

参考[java-chassis 提供的spring boot starter说明](components-for-spring-boot.md)，注意区分使用的java-chassis版本和spring boot版本。

* 启用java chassis的核心功能

在启动类前面增加@EnableServiceComb。

```
@SpringBootApplication
@EnableServiceComb
public class WebsiteMain {
    public static void main(final String[] args) {
        SpringApplication.run(WebsiteMain.class, args);
    }
}
```

通过以上配置，就可以完整使用java chassis提供的所有功能，使用java chassis开发REST服务，并开启各种治理功能。


* 配置微服务

集成以后，可以在microservice.yaml中增加应用配置，也可以使用spring boot的application.yml增加配置，application.yml的配置优先级高于microservice.yaml。 为了保持spring boot的开发习惯，建议开发者配置文件使用application.yml, 可以在application.yml中定制微服务的信息，包括应用名称、微服务名称、监听的地址和端口等。


集成java chassis后，可以通过它的方式开发REST接口：

```
@RestSchema(schemaId = "hello")
@RequestMapping(path = "/")
public class HelloService {
    @RequestMapping(path = "hello", method = RequestMethod.GET)
    public String sayHello(@RequestParam(name="name") String name) {
        return "Hello " + name;
    }
}
```

然后可以通过：http://localhost:9093/hello?name=world来访问。

