# 基础概念

Java Chassis 是以 OpenAPI 为基础的微服务开发框架。一个微服务提供的功能，可以通过 OpenAPI 进行描述。 微服务消费者和提供者完全解耦，开发消费者无需知道提供者的开发方式，只需要知道提供者的OpenAPI信息。 

本章节介绍基于[开发服务提供者-基础概念](../build-provider/basics.md)提供的 `HelloWorld` 契约, 描述如何开发服务消费者。

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

## Restful风格 - 使用 RestOperations

```java
RestOperations restOperation = 
    RestTemplateBuilder.create();
String result = restOperation
    .postForObject("servicecomb://provider-service/helloWorld", 
    "World", String.class);
Assertions.assertTrue("Hello World", result);
```

使用Restful风格开发消费者，需要关注Open API的Path、参数位置（Body、Header等）、参数类型以及响应类型，并且使用RestOperations的相关接口和参数一一对应。 其中 `servicecomb://provider-service` 表示目标微服务，使用目标微服务的服务名称。 

## RPC风格

RPC风格是一种语言有关的开发方法，更加贴近语言的使用习惯。访问服务提供者的服务，就像调用本地的API一样。 

使用RPC风格，首先需要声明一个 `interface` 与提供者的服务对应。 

```java
interface HelloWorldService {
  String helloWorld(String name);
}
```

声明 `interface` 会使用到 Open API 的 `operationId`、 参数名称和参数类型、响应类型。 只需要保证方法名等于`operationId`， 参数名称等于Open API里面的参数名称（对于body，使用扩展属性x-name）。 

使用起来就非常简单了：

```java
@RpcReference(schemaId = "HelloWorld", 
    microserviceName = "provider-service")
private HelloWorldService helloWorldService;

String result = helloWorldService.helloWorld("World");
Assertions.assertTrue("Hello World", result);
```

>>> 在具体的开发实践中，开发Provider定义interface（API），然后Consumer依赖Provider发布的包，直接使用Provider的接口也是非常常见的。如果已经习惯这种使用方式，可以继续使用。 在讨论完全解耦和API依赖的好处的时候，存在非常复杂和细节的差异。完全解耦的形式，可以给独立开发带来很大的灵活性，能够提高并行开发的效率。 

## 泛化调用 - InvokerUtils

```java
Map<String, Object> args = new HashMap<>();
args.put("name", "World");
String result = InvokerUtils.syncInvoke("provider-service",
    "HelloWorld", "helloWorld", args, String.class));
Assertions.assertTrue("Hello World", result);
```

泛化调用使用服务名、契约名称、`operationId`、 参数直接请求服务提供者，对应到 Open API 的`operationId`、参数名称和参数类型、响应类型。

