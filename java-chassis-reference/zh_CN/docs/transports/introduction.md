# 多协议介绍

Java Chassis提出编程模型和通信模型分离的创新概念，提供方便、简洁的多协议通信开发。编程模型指用户写代码的方式，即`Provider`如何定义服务，`Consumer`如何访问服务: 

* Provider编程模型：JAX-RS、Spring Web MVC、透明RPC
* Consumer编程模型：透明RPC、RestOperations、InvokerUtils

开发者可以在项目中自由组合Provider和Consumer的编程模型，即存在 3 * 3 种开发组合。大部分项目会采用如下两种组合：

* 组合一：Provider Spring Web MVC + Consumer 透明RPC
* 组合二：Provider JAX-RS + Consumer 透明RPC

多协议支持通常指通信模型。通信模型一般包括两个核心功能：对象如何编码，比如采用Json还是采用proto-buffer；通信协议采用什么，比如采用HTTP还是采用私有TCP协议。 对象编码方式和通信协议的组合，称为通信模型。 Java Chassis的通信模型可以分成两类：REST 和 Highway。 

* REST： 支持接口参数与HTTP Query、Path、Header、Body的映射关系。对象编码支持Json、proto-buffer、text等，通过Content-Type进行区分。通信协议采用HTTP协议族，比如HTTP、HTTPS、HTTP2（H2和H2C）。 
* Highway： 对象编码支持proto-buffer。通信协议采用Java Chassis自定义的私有TCP协议。 

这两类通信模型支持大部分的编程模型，这意味着业务代码开发的时候，不需要关注通信模型，可以在不修改业务代码的情况下，把通信模型从REST修改为Highway，或者把通信模型由Highway修改为REST。 

但是仍然有些情况，受限于技术条件，无法实现完全透明。比如Highway不支持文件上传、下载，也不支持SSE等只能运行于HTTP协议的功能。Java Chassis还提供了一些使用场景受限的通信模型，比如`Websocket`，它有自己特定的编程模型，这种编程模型的代码不能使用REST或者Highway来运行。针对这些小众情况，可以在Provider使用`Transport`标签来声明通信模型，比如下面的代码声明了`WebsocketController`所有的接口只允许通过`Websocket`通信模型来访问，通过其他通信模型来访问，请求会被拒绝。`Transport`标签也可以作用于方法，指定方法只能通过该通信模型访问。

```java
@RestSchema(schemaId = "WebsocketController")
@RequestMapping(path = "/ws")
@Transport(name = CoreConst.WEBSOCKET)
public class WebsocketController {
  @PostMapping("/websocket")
  public void websocket(ServerWebSocket serverWebsocket) {
    AtomicInteger receiveCount = new AtomicInteger(0);
    serverWebsocket.writeTextMessage("hello", r -> {
    });
    serverWebsocket.textMessageHandler(s -> {
      receiveCount.getAndIncrement();
    });
    serverWebsocket.closeHandler((v) -> System.out.println("closed"));
    new Thread(() -> {
      for (int i = 0; i < 5; i++) {
        serverWebsocket.writeTextMessage("hello " + i, r -> {
        });
        try {
          Thread.sleep(500);
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
      }
      serverWebsocket.writeTextMessage("total " + receiveCount.get());
      serverWebsocket.close();
    }).start();
  }
}
```

除了使用`Transport`，也可以在`Consumer`端使用:

```yaml
servicecomb:
  references:
    transport:
      ${serviceName}.${schemaId}.${operationId}: rest
```

来指定访问目标服务（或者具体接口）所使用的协议。 

## 如何选择通信模型

在多数场景，建议使用REST通信模型。 Java Chassis对REST协议进行了很好的优化，能够满足绝大多数应用场景的需要。REST协议具备更好的跨平台特性，能够支持不同系统直接对接，HTTP协议在应对大规模并发场景，提供了非常好的健壮性。在兼容性方面，REST协议和Json编码能够更好的支持业务平滑升级，当业务接口存在变化（接口参数个数、参数顺序、Model增减字段等场景）的大部分常见情况，客户端未升级能够成功调用服务端，这样给服务端和客户端独立升级带来很多方便。

采用proto-buffer编码，序列化更快，数据量更小，能够提供更高的吞吐量。 但是proto-buffer业务接口存在变化的情况，如果客户端未升级，服务端先升级，可能导致客户端调用失败。在客户端使用的接口和服务端不存在编译时依赖的场景下，这种问题会难于发现。

采用Highway协议，在涉及系统集成的时候，会碰到麻烦。

总结起来，多数情况建议使用REST协议。在少量需要高性能、并且功能相对稳定，不怎么变化的场景，使用proto-buffer或者使用Highway协议提升系统吞吐量和降低时延。 

> Tips: 可以在一个微服务中同时启用REST和Highway，使用@Transport标签设置不同的接口访问的协议。
