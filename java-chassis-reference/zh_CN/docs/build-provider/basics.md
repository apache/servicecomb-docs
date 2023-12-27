# 基础概念

Java Chassis 是以 OpenAPI 为基础的微服务开发框架。一个微服务提供的功能，可以通过 OpenAPI 进行描述，开发任务就是实现这些 OpenAPI 描述的功能。 可以将一个微服务开发分为两个基础性的工作：

* 定义微服务的功能。
* 实现微服务的功能。

Java Chassis提供了3种方式定义微服务功能：

* Spring Web MVC: 简称SpringMVC。Spring Web MVC是Spring Boot提供的一组描述 `REST` 接口的注解。
* JAX-RS: JAX-RS 是 Java SE 和 Java EE 提供的一组描述 `REST` 接口的注解。
* PRC: RPC是一种简洁的开发模式，用户无需通过注解描述 `REST` 接口，Java Chassis通过系统默认的规则，将服务定义映射为 OpenAPI 的描述。 

尽管Java Chassis支持在一个微服务中混合使用上述几种方式，项目中通常只会选择一种方式。从使用广泛性的角度，推荐Spring Web MVC。 

Spring Web MVC 的例子：

```java
@RestSchema(schemaId = "HelloWorld")
@RequestMapping("/")
public class SpringMVCExample {
  @PostMapping("/helloWorld")
  public String helloWorld(@RequestBody String name) {
    return "Hello " + name;
  }
}
```

JAX-RS 的例子：

```java
@RestSchema(schemaId = "HelloWorld")
@Path("/")
public class JAXRSExample {
  @POST
  @Path("/helloWorld")
  public String helloWorld(String name) {
    return "Hello " + name;
  }
}
```

这两种写法总体上是等价的，他们都定义了如下使用 OpenAPI 描述的服务：

```yaml
openapi: 3.0.1
info:
  version: 1.0.0
servers:
- url: /
paths:
  /helloWorld:
    post:
      operationId: helloWorld
      requestBody:
        content:
          application/json:
            schema:
              type: string
          application/protobuf:
            schema:
              type: string
          text/plain:
            schema:
              type: string
        x-name: name
      responses:
        "200":
          description: response of 200
          content:
            application/json:
              schema:
                type: string
            application/protobuf:
              schema:
                type: string
            text/plain:
              schema:
                type: string
components: {}
```

RPC 的例子：

```java
@RpcSchema(schemaId = "HelloWorld")
public class RPCExample {
  public String helloWorld(String name) {
    return "Hello " + name;
  }
}
```

这个服务使用 OpenAPI 描述如下。 可以看出 RPC 接口都会被描述为 `POST` 方法，参数都会使用 `RequestBody` 进行包装。 RPC模式通常用于使用者不关注 `REST` 规范的场景，Java Chassis的服务描述文件，给第三方工具测试 RPC 接口提供了便利。 

```yaml
openapi: 3.0.1
info:
  version: 1.0.0
servers:
- url: /
paths:
  /helloWorld:
    post:
      operationId: helloWorld
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/helloWorldBody'
          application/protobuf:
            schema:
              $ref: '#/components/schemas/helloWorldBody'
          text/plain:
            schema:
              $ref: '#/components/schemas/helloWorldBody'
        x-name: helloWorldBody
      responses:
        "200":
          description: response of 200
          content:
            application/json:
              schema:
                type: string
            application/protobuf:
              schema:
                type: string
            text/plain:
              schema:
                type: string
components:
  schemas:
    helloWorldBody:
      type: object
      properties:
        name:
          type: string
```

* 使用 `OpenAPI` 注解

Spring Web MVC 和 JAX-RS 注解只定义了一些基础的服务描述功能，比如参数、返回值等信息。 如果需要更加细粒度的描述服务，还需要借助 `OpenAPI` 注解。 `OpenAPI` 注解可以在3种模式下混合使用。比如通过 `OpenAPIDefinition` 和 `Operation` 两个注解，给Spring Web MVC的服务增加了分组和接口唯一标识。 利用`OpenAPI` 注解能够更清晰的描述服务功能、示例、安全性等方面的约束。

```java
@RestSchema(schemaId = "SpringMVCExample")
@RequestMapping("/")
@OpenAPIDefinition(tags = {@Tag(name = "example")})
public class SpringMVCExample {
  @Operation(operationId = "spring-mvc-example")
  @PostMapping("/helloWorld")
  public String helloWorld(@RequestBody String name) {
    return "Hello " + name;
  }
}
```

* 服务定义和服务实现分离

为了更好的管理服务定义和实现，将服务定义和实现分离是一个好的工程实践。 Java Chassis提供了相关支持。 

服务定义在单独的 interface 里面描述：

```java
@OpenAPIDefinition(tags = {@Tag(name = "example")})
@RequestMapping("/")
public interface ExampleService {
  @Operation(operationId = "spring-mvc-example")
  @PostMapping("/helloWorld")
  String helloWorld(@RequestBody String name);
}
```

服务实现：

```java
@RestSchema(schemaId = "SpringMVCExample", schemaInterface = ExampleService.class)
public class SpringMVCExample implements ExampleService {
  @Override
  public String helloWorld(String name) {
    return "Hello " + name;
  }
}
```
