# 开发第一个微服务应用

## 准备工作

在开发第一个Java-Chassis微服务之前，请先确保本地开发环境已经准备就绪，参考[安装本地开发环境](./development-environment.md)。

运行这些例子之前，需要先安装[注册中心](https://github.com/apache/servicecomb-service-center)
和[配置中心](https://github.com/apache/servicecomb-kie)
。华为云提供一个出色的[本地轻量化微服务引擎](https://support.huaweicloud.com/devg-cse/cse_devg_0036.html) , 可以直接下载安装使用，它包含了注册中心和配置中心。

Java Chassis依赖于Spring Boot，如果对于Spring Boot比较陌生，可以先通过 [Spring Boot入门](https://spring.io/guides/gs/spring-boot/) 了解。 

## 例子介绍

[Basic示例](https://github.com/apache/servicecomb-samples/tree/master/basic) 包含了3个微服务： gateway, provider, consumer。
这3个服务完成了一个最简单的微服务架构。 其中 provider 提供一个 REST 接口， consumer 调用 provider 的 REST 接口完成同样的功能。 gateway 作为微服务的接入端， 负责所有外部请求的接入。

如果已经了解 JAVA + MAVEN 应用程序开发， 可以直接下载并运行这个示例。 下面介绍该示例的关键开发步骤。

## 开发一个带 REST 接口的微服务

### 配置pom文件

创建一个空的maven工程。建议先配置`dependencyManagement`来管理依赖项

```xml

<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>java-chassis-dependencies</artifactId>
      <version>${java-chassis-dependencies.version}</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>
```

依赖项需要引入`solution-basic`, 并且引入注册中心、配置中心和Logger系统的依赖

```xml

<dependencies>
  <dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>solution-basic</artifactId>
  </dependency>
  <!-- using log4j2 -->
  <dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-slf4j-impl</artifactId>
  </dependency>
  <dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-api</artifactId>
  </dependency>
  <dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-core</artifactId>
  </dependency>
  <!-- using service-center & kie -->
  <dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>registry-service-center</artifactId>
  </dependency>
  <dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>config-kie</artifactId>
  </dependency>
  <!-- using java chassis http transport -->
  <dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>java-chassis-spring-boot-starter-standalone</artifactId>
  </dependency>
</dependencies>
```

`solution-basic`中已经包含了常见场景下开发Java-Chassis微服务所需的全部依赖项。

引入`maven-compiler-plugin`插件，使项目打包时保留方法参数名：

```xml

<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-compiler-plugin</artifactId>
  <version>${maven-compiler-plugin.version}</version>
  <configuration>
    <compilerArgument>-parameters</compilerArgument>
    <source>17</source>
    <target>17</target>
  </configuration>
</plugin>
```

### 添加配置文件

按照Spring Boot应用程序要求，增加 `application.yaml` 文件 ，存放在`resources`目录中。

文件内容如下，这份文件表示当前开发的是`basic-application`应用下的名为`provider`的微服务，版本为0.0.1。该微服务连接的注册中心地址为`http://localhost:30100`
，配置中心地址为`http://localhost:30110`。 该微服务监听HTTP协议的`9093`端口。

```yaml
servicecomb:
  service:
    application: basic-application
    name: provider
    version: 0.0.1
  rest:
    address: 0.0.0.0:9093
  # 注册发现
  registry:
    sc:
      address: http://localhost:30100
  # 动态配置
  kie:
    serverUri: http://localhost:30110
```

### 编写启动类

Java Chassis应用是一个标准的Spring Boot应用。本示例中，设置 `WebApplicationType.NONE`， 这样会使用 Java Chassis自带的高性能 HTTP 容器，而不使用 Spring
Boot自带的WEB容器。

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

### 编写服务
本例子采用契约优先的开发方法。

首先定义服务接口：

```java
@RequestMapping(path = "/provider")
public interface ProviderService {
  @GetMapping("/sayHello")
  String sayHello(@RequestParam("name") String name);

  @GetMapping("/exampleConfig")
  String exampleConfig();
}
```

在工程中添加一个REST接口类用于接收请求：

```java
@RestSchema(schemaId = "ProviderController", schemaInterface = ProviderService.class)
public class ProviderController implements ProviderService {
  private DynamicProperties dynamicProperties;

  private String example;

  @Autowired
  public ProviderController(DynamicProperties dynamicProperties) {
    this.dynamicProperties = dynamicProperties;
    this.example = this.dynamicProperties.getStringProperty("basic.example",
        value -> this.example = value, "not set");
  }

  @Override
  public String sayHello(String name) {
    return "Hello " + name;
  }

  @Override
  public String exampleConfig() {
    return example;
  }
}
```

该类实现了两个REST接口，其中`sayHello`实现了一个简单的echo程序；`exampleConfig`演示了如何通过配置中心下发配置项，并动态监听配置项的变化。

### 添加日志配置文件

本例子引入了log4j2组件。如果想要看到运行日志，还需要手动添加一份日志配置文件，文件存放位置为`resources\log4j2.xml`，内容如下：

```xml

<Configuration status="INFO">
  <Appenders>
    <Console name="Console" target="SYSTEM_OUT">
      <PatternLayout pattern="[%d][%t][%p]%m [%c:%L]%n"/>
    </Console>
  </Appenders>
  <Loggers>
    <Root level="INFO">
      <AppenderRef ref="Console"/>
    </Root>
  </Loggers>
</Configuration>
```

### 调用服务

在 Consumer 里面，演示了如何调用 Provider 的服务。 首先声明一个 PRC 接口的 Bean。

```java
@Configuration
public class ProviderServiceConfiguration {
  @Bean
  public ProviderService providerService() {
    return Invoker.createProxy("provider", "ProviderController", ProviderService.class);
  }
}
```

使用 @Autowired 声明 RPC 接口的远程引用， 然后可以像调用本地方法一样，访问 Provider 的服务。

```java
@RestSchema(schemaId = "ConsumerController", schemaInterface = ConsumerService.class)
public class ConsumerController implements ConsumerService {
  private ProviderService providerService;

  @Autowired
  public void setProviderService(ProviderService providerService) {
    this.providerService = providerService;
  }

  @Override
  public String sayHello(String name) {
    return providerService.sayHello(name);
  }

  @Override
  public String exampleConfig() {
    return providerService.exampleConfig();
  }
}
```

### 微服务网关

微服务网关是一个普通的微服务，需要额外引入 `edge-core` 。

```xml

<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>edge-core</artifactId>
</dependency>
```

### 启动服务

依次启动 `ProviderApplication`、`ConsumerApplication`和`GatewayApplication`， 访问 `http://localhost:9090/sayHello?name=World`
，可以得到响应`"Hello World!"`。

打开注册中心、配置中心控制台，还可以看到微服务的实例列表。通过配置中心给 `ProviderApplication` 添加配置， 访问 `http://localhost:9090/exampleConfig` ,
可以得到响应，响应包含了最新的配置项的值。 

### 使用`Nacos`注册中心和配置中心

本例子还可以使用 `Nacos` 作为注册中心和配置中心。 

编译：

```text
mvn clean install -Pnacos
```

运行:

```text
java -Dspring.profiles.active=nacos -jar basic-provider-2.0-SNAPSHOT.jar
```

也可以在IDE里面选择 MAVEN 的 nacos PROFILE，并修改 application.yml 的 `spring.profiles.active` 为 nacos. 
