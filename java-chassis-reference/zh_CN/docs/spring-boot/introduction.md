# Java Chassis与Spring Boot 集成介绍

将 [Spring Boot](https://projects.spring.io/spring-boot/) 用于微服务开发，可以极大的简化开发者配置和部署。Java Chassis在Spring Boot基础之上，提供了完善的的微服务架构模式需要的能力，包括服务注册发现、服务治理、良好的跨语言特性和高效的异步通信等能力。 

Java Chassis有两种方式使用Spring Boot：

  1. 高性能模式：使用Java Chassis高性能HTTP服务器。

  2. Web开发方式：使用Spring Boot自带的Tomcat或者Jetty服务器。

<br/>

* 高性能模式

引入依赖

```xml
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>java-chassis-spring-boot-starter-standalone</artifactId>
</dependency>
```

WebApplicationType指定为NONE

```java
@SpringBootApplication
public class ProviderApplication {
  public static void main(String[] args) throws Exception {
    try {
      new SpringApplicationBuilder()
          .web(WebApplicationType.NONE)
          .sources(ProviderApplication.class)
          .run(args);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
```

* Web模式

引入依赖

```xml
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>java-chassis-spring-boot-starter-servlet</artifactId>
</dependency>
```

WebApplicationType指定为NONE

```java
@SpringBootApplication
public class ProviderApplication {
  public static void main(String[] args) throws Exception {
    try {
      new SpringApplicationBuilder()
          .web(WebApplicationType.SERVLET)
          .sources(ProviderApplication.class)
          .run(args);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
```


两种开发方式都会启用Java Chassis的全量功能，高性能模式运行于独立的HTTP服务器（基于vert.x构建）上，性能上存在很大的优势。Web模式运行于Tomcat或者其他内置的Web服务器之上，作为一个Servlet接收请求，因此在开发过程中，可以使用Web容器提供的一些功能，比如提供页面服务，使用Filter等。当应用只需要提供REST服务，并且对性能要求很高的场景，建议高性能模式。
