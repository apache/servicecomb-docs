# Java Chassis 3技术解密：WebSocket和人工智能应用开发

前一篇《Java Chassis 3技术解密：流式响应和人工智能应用开发》解密了Java Chassis 3使用流式响应和SSE开发人工智能应用的功能。为了获取更好的用户体验和提升人工智能后台资源调度效率，WebSocket的双向通信特征在人工智能场景也经常被采用。

以最常见的知识问答为例：当用户输入一段文本，人工智能会逐段生成应答，用户根据结果，提出新的问题和发表疑问，人工智能根据新的信息重新计算应答。在一些复杂的对话场景，人工智能的响应可能被打断，需要根据用户的输入时刻对处理结果进行调整。 

人工智能的处理后台需要保留用户会话上下文，并针对该会话合理调度处理资源和缓存会话信息。 

Java Chassis 3提供了非常简洁的WebSocket支持，满足上述场景对于微服务开发框架功能的要求。

## 使用WebSocket

首先，看看微服务架构下一个简单的调用场景。

      前端(浏览器) -> 应用网关(edge service) -> 消费者微服务 -> 提供者微服务

* 提供者微服务：定义WebSocket服务和响应用户请求

定义WebSocket非常简单，只需要使用 `Transport` 标签声明接口方法为 `WEBSOCKET` ，参数使用 `ServerWebSocket`。

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

上述例子使用后台线程给消费者写入5条消息，并记录收取到的消息次数，最终写入收取到消息次数。 Open API并没有对双向流式通信做出规范定义，Java Chassis 3要求WebSocket的方法使用 `Post`。 

`WebSocket`是一个新的 `Tranport`， 但是它直接构建于 `REST` 之上，因此底层实现复用了 `Rest Over Vert.x` 通信协议，只需要在其上增加 `websocketEnabled` 和 `websocket-prefix`两个参数。 需要注意Websocket接口定义的URL前缀需要和`websocket-prefix`保持一致。

```yaml
servicecomb:
  rest:
    address: 0.0.0.0:9094?websocketEnabled=true
    server:
      websocket-prefix: /ws
```

* 消费者微服务: 消费提供者WebSocket，并对外提供新的WebSocket服务

消费者可以像调用普通REST接口一样调用WebSocket，开发起来非常简单。

```java
@RestSchema(schemaId = "ClientWebsocketController")
@RequestMapping(path = "/ws")
@Transport(name = CoreConst.WEBSOCKET)
public class ClientWebsocketController {
  interface ProviderService {
    WebSocket websocket();
  }

  @RpcReference(schemaId = "WebsocketController", microserviceName = "provider")
  private ProviderService providerService;

  @PostMapping("/websocket")
  public void websocket(ServerWebSocket serverWebsocket) {
    WebSocket providerWebSocket = providerService.websocket();
    providerWebSocket.closeHandler(v -> serverWebsocket.close());
    providerWebSocket.textMessageHandler(m -> {
      System.out.println("send message " + m);
      serverWebsocket.writeTextMessage(m);
    });
    serverWebsocket.textMessageHandler(m -> {
      System.out.println("receive message " + m);
      providerWebSocket.writeTextMessage(m);
    });
  }
}
```

上述代码消费提供者的WebSocket服务，实现将前端的消息写给提供者，并将提供者的消息返回给前端。 和提供者微服务一样，也需要在配置文件增加 `websocketEnabled` 和 `websocket-prefix`两个参数。

* 应用网关：透明转发

应用网关无需开发代码，可以实现透明转发，只需要在配置文件里面启用WebSocket和设置路由信息。 

```yaml
servicecomb:
  rest:
    address: 0.0.0.0:9090?websocketEnabled=true
    server:
      websocket-prefix: /ws

  http:
    dispatcher:
      edge:
        websocket:
          mappings:
            consumer:
              prefixSegmentCount: 0
              path: "/ws/.*"
              microserviceName: consumer
              versionRule: 0.0.0+
```

上述代码将前端 `/ws/.*` 路径下的WebSocket请求转发给后端的 `consumer` 服务。 

* 前端(浏览器)：消费WebSocket

大部分浏览器都支持通过 `WebSocket` 与后端交互。下面是简单的代码片段：

```javascript
<!DOCTYPE html> 
<meta charset="utf-8" /> 
<title>WebSocket Test</title> 
<script language="javascript"type="text/javascript"> 
    var wsUri ="ws://localhost:9090/ws/websocket";
    var output; 
     
    function init() {
        output = document.getElementById("output");
        testWebSocket();
    } 
  
    function testWebSocket() {
        websocket = new WebSocket(wsUri);
        websocket.onopen = function(evt) {
            onOpen(evt)
        };
        websocket.onclose = function(evt) {
            onClose(evt)
        };
        websocket.onmessage = function(evt) {
            onMessage(evt)
        };
        websocket.onerror = function(evt) {
            onError(evt)
        };
    } 
  
    function onOpen(evt) {
        writeToScreen("CONNECTED");
        doSend("WebSocket rocks");
    } 
  
    function onClose(evt) {
        writeToScreen("DISCONNECTED");
    } 
  
    function onMessage(evt) {
        writeToScreen('<span style="color: blue;">RESPONSE: '+ evt.data+'</span>');
        doSend(evt.data);
    } 
  
    function onError(evt) {
        writeToScreen('<span style="color: red;">ERROR:</span> '+ evt.data);
    } 
  
    function doSend(message) {
        writeToScreen("SENT: " + message); 
        websocket.send(message);
    } 
  
    function writeToScreen(message) {
        var pre = document.createElement("p");
        pre.style.wordWrap = "break-word";
        pre.innerHTML = message;
        output.appendChild(pre);
    } 
  
    window.addEventListener("load", init, false); 
</script> 
<h2>WebSocket Test</h2> 
<div id="output"></div> 
</html>
```

上述代码将收取到的消息打印在控制台，并将消息写回服务器。 

## WebSocket、SSE、Long/Short Polling

WebSocket、SSE、Long/Short Polling都被应用于人工智能场景，它们都有各自的优点和适用场景。WebSocket可以提供最好的用户体验，但是在扩容、大规模并发方面会面临问题。Long/Short Polling可以提供更好的扩展性和可靠性，但是开发难度大，用户体验差。 SSE是两者非常好的权衡。 

> 在 `小艺` 人工智能应用中，为了提供更好的交互体验和提升后端资源调度能力，需要选择WebSocket。WebSocket在整个应用系统中使用的比例并不高，为了部分场景引入一个新的技术，开发和维护成本非常高。Java Chassis 3 的WebSocket功能具备和普通RPC/REST接口一样简单的开发体验，能够帮助开发团队提升开发效率和降低维护成本。 
