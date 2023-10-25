# REST over Servlet(WAR)

和 [REST over Servlet(Spring Boot Embedded)](rest-over-servlet-embedded.md) 类似，可以将Spring Boot应用打包为 WAR，然后放到独立安装的 Tomcat 容器运行。 它们的工作机制一样，只是在Spring Boot应用配置方面有些差异。  

WAR相关Web容器参数需要结合Tomcat配置，这里不详细介绍。 Java Chassis配置参数和Embedded一样。

[basic-tomcat](https://github.com/apache/servicecomb-samples/tree/master/basic-tomcat) 提供了开发例子。 

## 使用 SpringBootServletInitializer

Spring Boot启动类需要继承 SpringBootServletInitializer, 并且设置 WebApplicationType.SERVLET。

```java
@SpringBootApplication
public class ProviderApplication extends SpringBootServletInitializer {
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

## 配置文件端口

REST协议监听端口需要保持和Tomcat端口一致。 

```yaml
servicecomb:
  # port should same as tomcat
  rest:
    address: 0.0.0.0:8080
```

## 依赖

需要在依赖中添加：

```xml
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>java-chassis-spring-boot-starter-servlet</artifactId>
  <exclusions>
    <exclusion>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-logging</artifactId>
    </exclusion>
  </exclusions>
</dependency>
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-tomcat</artifactId>
  <scope>provided</scope>
</dependency>
```

## 微服务网关 Edge Service

微服务网关Edge Service不支持Servlet协议，不建议将其部署到Tomcat。仍然使用可执行 jar 包部署。 
