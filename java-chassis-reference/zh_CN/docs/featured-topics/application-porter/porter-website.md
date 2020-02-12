# 开发界面

在技术选择上，界面完全由html+js+css等静态网页技术构成，不采用动态页面技术。采用静态页面技术构建界面，使得整个微服务系统更加具备弹性，能够非常容易的进行扩容，相关开发成果也能够更好的被其他应用继承。

采用静态页面技术，也使得界面服务部署更加灵活多样：

* 将静态页面部署到nginx，nginx将REST请求转发到gateway-service。
* 将静态页面直接部署到gateway-service。
* 静态页面通过Tomcat、Spring Boot等Web服务器部署，并注册到服务中心，gateway-service将请求转发到对应的应用服务器上。
* 静态页面由第三方开发，第三方直接通过gateway-service访问REST接口。由第三方选择界面的开发技术。

这几种方式都被广泛使用。

## 将静态页面直接部署到gateway-service
在[porter_lightweight](https://github.com/apache/servicecomb-samples/tree/master/porter_lightweight)项目中，采用了将静态页面直接部署到gateway-service的方式，这种方式简洁高效。这种方式的核心代码是StaticWebpageDispatcher。它采用vert.x提供的静态页面功能，直接挂载了静态页面服务。

```
public class StaticWebpageDispatcher implements VertxHttpDispatcher {
  private static final Logger LOGGER = LoggerFactory.getLogger(StaticWebpageDispatcher.class);

  private static final String WEB_ROOT = DynamicPropertyFactory.getInstance()
      .getStringProperty("gateway.webroot", "/var/static")
      .get();

  @Override
  public int getOrder() {
    return Integer.MAX_VALUE;
  }

  @Override
  public void init(Router router) {
    String regex = "/ui/(.*)";
    StaticHandler webpageHandler = StaticHandler.create();
    webpageHandler.setWebRoot(WEB_ROOT);
    LOGGER.info("server static web page for WEB_ROOT={}", WEB_ROOT);
    router.routeWithRegex(regex).failureHandler((context) -> {
      LOGGER.error("", context.failure());
    }).handler(webpageHandler);
  }

}
```

## 静态页面通过Tomcat、Spring Boot等Web容器部署，并注册

在架构图中，界面的请求需要被网关转发，并且需要支持多实例部署，因此界面服务需要增加的功能是服务注册和发现。有两种方法集成和使用J2EE：

1. 运行于独立的web服务器中，如tomcat等。

2. 运行于Spring Boot的Embedded Tomcat中。


在Spring Boot中提供静态页面服务，核心问题是解决服务注册、发现能力。在Spring Boot的Embeded Tomcat中使用ServiceComb的服务注册发现，需要完成如下步骤：

* 增加依赖关系

依赖关系定义了对于Spring Boot的依赖和java-chassis的依赖。

```
<dependency>

  <groupId>org.apache.servicecomb</groupId>

  <artifactId>java-chassis-spring-boot-starter-servlet</artifactId>

</dependency>
```

* 配置微服务信息\(microservice.yaml\)

需要注意配置项servicecomb.rest.address的端口与application.yml的server.port保持一致。application.yml是Spring Boot的配置文件，用于指定Embeded Tomcat的监听端口。microservice.yam的信息用于服务注册。另外也需要注意一下配置项servicecomb.rest.servlet.urlPattern，当使用@EnableServiceComb时，会加载REST框架org.apache.servicecomb.transport.rest.servlet. RestServlet，而且默认接管了/\*的请求。在我们的场景下，仅仅需要提供web页面，不需要提供REST服务，这个配置项的含义就是将它的路径改为一个和静态页面不冲突的路径，以保证静态页面能够被正常访问。

```
APPLICATION_ID: porter
service_description:
  name: porter-website
  version: 0.0.1

servicecomb:
  rest:
    address: 0.0.0.0:9093
    servlet:
      urlPattern: /servicecomb/rest/*
```

* 增加静态页面

按照Spring Boot的惯例，静态页面需要放到源代码的resources/static目录。项目开始前，增加了如下静态页面和目录：

```
css
js
index.html
```

* 使用@EnableServiceComb启用注册发现

```
@SpringBootApplication
@EnableServiceComb
public class WebsiteMain {
    public static void main(final String[] args) {
        SpringApplication.run(WebsiteMain.class, args);
    }
}
```

经过以上的步骤，界面服务就开发完成了。通过运行WebsiteMain，就可以通过[http://localhost:9093](http://localhost:9093) 来访问。

