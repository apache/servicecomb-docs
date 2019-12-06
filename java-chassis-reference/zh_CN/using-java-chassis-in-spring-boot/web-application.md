Web开发方式和JAVA应用方式的开发步骤基本类似。

主要有如下区别：

* JAVA应用方式基于spring-boot-starter，而Web开发方式基于spring-boot-starter-web。

* Web开发方式通过@EnableServiceComb会启用org.apache.servicecomb.transport.rest.servlet.RestServlet, 可以通过声明

```
@SpringBootApplication(exclude=DispatcherServletAutoConfiguration.class)
```

来关闭org.springframework.web.servlet.DispatcherServlet。虽然排除DispatcherServlet不是必须的，但是大多数场景一个微服务里面存在多个REST框架都不是很好的主意，容易误用。

***注意：*** 有些spring boot版本在加上这个配置以后，启动会失败。也可以不关闭DispatcherServlet，而是将他们指定为不同的URL前缀，让这两个Servlet共存。这种方式在一些历史遗留系统改造，必须使用DispatcherServlet发布REST接口的场景非常有用。

```
## DispatcherServlet path
server.servlet.path: /ui
## RestServlet path
servicecomb.rest.servlet.urlPattern: /api/*
```

* 通过配置项servicecomb.rest.servlet.urlPattern来指定RestServlet的URL根路径。并且配置项servicecomb.rest.address里面的监听端口，必须和tomcat监听的端口保持一致（默认是8080，可以通过application.yml中增加server.port修改）

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

可以看到使用的标签和Spring MVC大部分是一样的。但也有少量不一样的地方，比如：

1. 通过RestSchema替换RestController

2. 需要显示声明@RequestMapping

如果业务代码不是新开发，而是基于Spring MVC做的开发，现在java chassis基于做改造，还需要注意在禁用DispatcherServlet后，和其有关的功能特性将不再生效。

在下面的章节，还会详细介绍在Spring MVC模式下两者的区别。

