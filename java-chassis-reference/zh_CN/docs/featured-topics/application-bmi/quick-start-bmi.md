# 体质指数微服务应用开发

在您进一步阅读之前，请确保您已阅读了[快速入门](quick-start.md)，并已成功运行**体质指数**微服务。接下来将进入**体质指数**微服务应用的开发之旅。

## 快速开发微服务应用
BMI主要由两个微服务组成：

* **体质指数计算器**：负责处理运算事务。

* **体质指数界面**：提供用户界面及网关服务。

在开始前，需要先在服务的父工程中添加以下依赖项：

```java
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.apache.servicecomb</groupId>
        <artifactId>java-chassis-dependencies</artifactId>
        <version>${project.version}</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
```
**注意**: `java-chassis-dependencies` 这个依赖是以pom的形式导入来统一项目中的依赖项的版本管理。

下面将对这两个微服务的实现进行介绍，其代码已托管于[github](https://github.com/apache/servicecomb-samples/tree/master/java-chassis-samples/bmi)上。

### 体质指数计算器实现
体质指数计算器提供运算服务，其实现分为三部分：

* 具体运算实现

* 服务端点定义

* 服务启动入口

#### 具体运算实现
本模块负责计算体质指数，根据公式 `体质指数=体重 / 身高^2 ` 进行实现，代码如下：

```java
public interface CalculatorService {
  double calculate(double height, double weight);
}

@Service
public class CalculatorServiceImpl implements CalculatorService {
  @Override
  public double calculate(double height, double weight) {
    if (height <= 0 || weight <= 0) {
      throw new IllegalArgumentException("Arguments must be above 0");
    }
    double heightInMeter = height / 100;
    return weight / (heightInMeter * heightInMeter);
  }
}
``` 

#### 服务端点定义
服务端点用于生成服务契约，使得服务间能无缝进行通信。首先定义端点接口：

```java
public interface CalculatorEndpoint {
  double calculate(double height, double weight);
}
```

引入 **ServiceComb** 依赖：

```xml
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>java-chassis-spring-boot-starter-servlet</artifactId>
    </dependency>
```

暴露运算服务的Restful端点：

```java
@RestSchema(schemaId = "calculatorRestEndpoint")
@RequestMapping("/")
public class CalculatorRestEndpoint implements CalculatorEndpoint {

  private final CalculatorService calculatorService;

  @Autowired
  public CalculatorRestEndpoint(CalculatorService calculatorService) {
    this.calculatorService = calculatorService;
  }

  @Override
  @GetMapping("/bmi")
  public double calculate(double height, double weight) {
    return calculatorService.calculate(height, weight);
  }
}
```

这里用`@RestSchema`注释端点后， **ServiceComb** 微服务框架会自动生成对应的服务端点契约，并根据
如下的 `application.yml` 文件中的定义来配置端点端口，将契约和服务一起注册到服务注册中心。

```yaml
APPLICATION_ID: bmi
service_description:
  name: calculator
  version: 0.0.1
servicecomb:
  service:
    registry:
      address: http://127.0.0.1:30100
  rest:
    address: 0.0.0.0:7777
```

***注意***: **ServiceComb**默认的配置文件名称是`microservice.yaml`。 本应用采用 spring boot作为运行环境，因此遵循
spring boot的规范，配置文件名称使用 `application.yml`。

#### 服务启动入口
服务启动入口中只需添加 `@EnableServiceComb` 的注解即可启用 *ServiceComb* 微服务框架，代码如下：

```java
@SpringBootApplication
@EnableServiceComb
public class CalculatorApplication {
  public static void main(String[] args) {
    SpringApplication.run(CalculatorApplication.class, args);
  }
}
```

### 体质指数界面实现
本模块负责提供用户界面及网关服务。其实现主要分为三部分：

* 前端界面

* 网关及路由规则

* 服务启动入口

其中，前端界面的组件使用了[Bootstrap](http://getbootstrap.com/)来开发。

#### 网关及路由规则
网关服务使用 **ServiceComb** 提供的 [Edge Service](http://localhost:8000/edge/by-servicecomb-sdk/) 来实现。

引入依赖：
```xml
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>java-chassis-spring-boot-starter-standalone</artifactId>
</dependency>
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>edge-core</artifactId>
</dependency>
```

在 `application.yml` 文件中配置路由规则及服务端口信息：

```yaml
ervicecomb:
  service:
    registry:
      address: http://127.0.0.1:30100
  rest:
    address: 0.0.0.0:8889

  tracing:
    enabled: false

  http:
    dispatcher:
      edge:
        default:
          enabled: false
          prefix: api
          withVersion: false
          prefixSegmentCount: 1
        url:
          enabled: true
          mappings:
            calculator:
              prefixSegmentCount: 1
              path: "/calculator/.*"
              microserviceName: calculator
              versionRule: 0.0.0+

# This is web root for windows server, change this path according to where you put your source code
gateway:
  webroot: /code/servicecomb-samples/java-chassis-samples/bmi/webapp/src/main/resources/static
```

其中 `servicecomb.http.dispatcher.edge.default.enabled` 禁用了默认的路由规则， `servicecomb.http.dispatcher.edge.url.enabled`
启用了基于URL映射的路由规则。 规则的含义表示将URL为 `/calculator/.*` 的请求转发到 `calculator`服务。

`gateway.webroot` 配置了静态页面所在的目录位置。 示例里面采用的是 Windows 目录环境，如果采用 Linux 环境，需要配置相对路径。

`StaticWebpageDispatcher` 扩展了 Edge Service 的转发规则， 使用了 vert.x 提供的 `StaticHandler` 发布静态页面。 Edge 
Service 采用 SPI 的方式扩展 Dispatcher， 需要创建文件 `org.apache.servicecomb.transport.rest.vertx.VertxHttpDispatcher`。 

#### 服务启动入口

服务启动入口也只需要声明启用 `ServiceComb` 即可。

```java
@SpringBootApplication
@EnableServiceComb
public class GatewayApplication {
  public static void main(String[] args) {
    new SpringApplicationBuilder().web(WebApplicationType.NONE).sources(GatewayApplication.class).run(args);
  }
}
```

至此，**体质指数**应用已开发完毕，您可以通过[快速入门](quick-start.md)中的步骤对其进行验证。

## 下一步

* 阅读 [微服务开发进阶](quick-start-advance.md)
