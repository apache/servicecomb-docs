# Java Chassis 3技术解密：流式响应和人工智能应用开发

随着生成式人工智能技术的发展，应用程序开发者对于流式响应(Streaming Responses)的诉求越来越多。服务器事件推送(Server Push Events)技术能够在使用HTTP协议的前提下，提供流式响应能力。然而，在微服务架构下使用流式响应并不是那么方便，现有的各个微服务开发框架都需要使用不同于响应应答的普通REST接口额外能力，采用新的技术或者API来满足流式响应的开发诉求，增加了技术成本。 

Java Chassis 3基于服务器事件推送和响应式流(reactive streams)标准，提供了非常简洁的流式响应开发能力，简化人工智能应用开发体验。

## 使用流式响应

首先，看看微服务架构下一个简单的调用场景。

      前端(浏览器) -> 应用网关(edge service) -> 消费者微服务 -> 提供者微服务

* 提供者微服务：定义流式响应服务和生成流式响应

定义流式响应服务非常简单，只需要将响应类型声明为 `Publisher`。 业务逻辑可以使用 `RxJava` 或者 `Reactor` 等框架生成流式响应。 在下面的例子中，使用 `RxJava3` 的API来实现流式响应。 

```java
@RestSchema(schemaId = "ReactiveStreamController")
@RequestMapping(path = "/")
public class ReactiveStreamController {
  @GetMapping("/sseString")
  public Publisher<String> sseString() {
    return Flowable.fromArray("a", "b", "c");
  }

  @GetMapping("/sseModel")
  public Publisher<Model> sseModel() {
    return Flowable.intervalRange(0, 5, 0, 1, TimeUnit.SECONDS)
        .map(item -> new Model("jack", item.intValue()));
  }
}
```

* 消费者微服务: 消费流式响应，并对外提供新的流式响应服务

消费者可以像调用普通REST接口一样调用流式响应服务，开发起来非常简单。 

```java
@RestSchema(schemaId = "ReactiveStreamController")
@RequestMapping(path = "/")
public class ConsumerReactiveStreamController {
  interface ProviderReactiveStreamController {
    Publisher<String> sseString();

    Publisher<Model> sseModel();
  }

  @RpcReference(microserviceName = "provider", schemaId = "ReactiveStreamController")
  ProviderReactiveStreamController controller;

  @GetMapping("/sseString")
  public Publisher<String> sseString() {
    return controller.sseString();
  }

  @GetMapping("/sseModel")
  public Publisher<Model> sseModel() {
    return controller.sseModel();
  }
}
```

* 应用网关：透明转发

应用网关无需做额外配置，能够实现流式响应的透明转发。 

* 前端(浏览器)：消费消息

大部分浏览器都支持通过 `EventSource` 消费流式响应。下面是简单的代码片段：

```javascript
<script>
    var sse = new EventSource("http://localhost:9090/sseModel");

    sse.onmessage = function (ev) {
        var elementById = document.getElementById("ssediv");
        elementById.innerHTML = elementById.innerHTML + "\n" + ev.data;
    }

    sse.onerror = function (){
        sse.close()
    }

    sse.onopen = function (){
    }
</script>
```

## 相关的技术实现

`Spring Boot`采用`SseEmitter`来定义服务器事件推送，如果需要使用流式响应，则必须使用`WebFlux`，在微服务场景下，则需要使用`WebClient`来消费。这些使用方式与`WebMvc`集成和注册发现集成都会带来非常大的开发麻烦。 Java Chassis 3给开发者提供了非常棒的统一一致的开发体验。

> 在 `小艺` 人工智能应用中，需要大量使用流式响应，包括微服务之间。为了实现这些功能，需要额外开发大量代码，并且与现有的REST框架没有实现统一一致的服务治理规范，给应用的可维护性和质量带来了隐患。 通过新的流式响应API能够极大的简化`小艺`场景的开发。

