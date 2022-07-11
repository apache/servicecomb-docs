# HTTP Filter

使用 Java Chassis 对请求进行拦截推荐的方式是[处理链](../references-handlers/intruduction.md)。使用处理链不关注通信协议，
无论使用 HIGHWAY 还是使用 REST， 请求均会经过处理链进行处理。 当用户使用 REST 的时候，支持两种通道：`REST over Servlet` 和
`REST over Vertx`，这两种通道都支持通过 `HttpClientFilter` 和 `HttpServerFilter` 两个接口对请求进行拦截。 

比如某些场景中，业务使用 http 而不是 https，为了防止被伪造或篡改请求，需要提供consumer、producer之间对http码流的签名功能。
签名功能可以使用 `HttpClientFilter` 和 `HttpServerFilter` 实现， 详细参考[示例代码][demo-signature]。 本章节通过
签名功能的实现介绍如何使用 `HttpClientFilter` 和 `HttpServerFilter` 。

[demo-signature]: https://github.com/apache/servicecomb-java-chassis/tree/master/demo/demo-signature

## HttpClientFilter 和 HttpServerFilter 介绍

HttpClientFilter 和 HttpServerFilter 使用 Java 标准的 SPI 机制加载。 允许加载多个， 各实例之间的执行顺序由getOrder的返回值决定。
如果getOrder返回值相同，则相应的实例顺序随机决定。无论是request，还是response，读取body码流，都使用getBodyBytes\(\)，返回值可能为
null（比如get调用的场景），如果不为null，对应的码流长度，通过getBodyBytesLength\(\)获取。

>***注意事项***: 
>HttpClientFilter 的 beforeSendRequest 在接口调用的当前线程执行， afterReceiveResponse 在业务线程池中执行。
>HttpServerFilter 的 afterReceiveRequest 在业务线程池中执行，beforeSendResponse 和 beforeSendResponseAsync
>可能在业务线程池执行， 也可能在网络线程池执行， 务必保证不能够出现阻塞操作。
>
>Java Chassis底层是异步框架，线程切换频繁。当业务扩展Filter时，若涉及通过ThreadLocal获取线程上下文时，可能会出现获取为空的情况。针对这种场景，建议使用InHeritableThreadLocal来代替ThreadLocal存储数据，或者使用扩展Handler的方式来代替Filter。

## HttpClientFilter

系统内置2个HttpClientFilter，扩展功能时注意order值不要冲突：

* org.apache.servicecomb.provider.springmvc.reference.RestTemplateCopyHeaderFilter, order值为Integer.MIN\_VALUE

* org.apache.servicecomb.transport.rest.client.http.DefaultHttpClientFilter, order值为Integer.MAX\_VALUE

* 原型

```
public interface HttpClientFilter {
  int getOrder();

  void beforeSendRequest(Invocation invocation, HttpServletRequestEx requestEx);

  // if finished, then return a none null response
  // if return a null response, then sdk will call next filter.afterReceive
  Response afterReceiveResponse(Invocation invocation, HttpServletResponseEx responseEx);
}
```

* beforeSendRequest

用于在已经生成码流之后，发送请求之前，根据url、header、query、码流计算签名，并设置到header中去\(requestEx.setHeader\)。
从入参invocation中可以获取本次调用的各种元数据以及对象形式的参数（码流是根据这些参数生成的）。

* afterReceiveResponse

用于在从网络收到应答后，根据header、码流计算签名，并与header中的签名对比。如果签名不对，直接构造一个Response
作为返回值，只要不是返回NULL，则框架会中断对其他HttpClientFilter的调用。

## HttpServerFilter

* 原型

```
public interface HttpServerFilter {
  int getOrder();

  default boolean needCacheRequest(OperationMeta operationMeta) {
    return false;
  }

  // if finished, then return a none null response
  // if return a null response, then sdk will call next filter.afterReceiveRequest
  Response afterReceiveRequest(Invocation invocation, HttpServletRequestEx requestEx);

  // invocation maybe null
  void beforeSendResponse(Invocation invocation, HttpServletResponseEx responseEx);
}
```

* needCacheRequest

与HttpClientFilter不同的是，增加了决定是否缓存请求的功能。这是因为ServiceComb不仅仅能使用standalone的方式运行，也
能运行于web容器（比如tomcat），在servlet的实现上，请求码流只能读取一次，并且不一定支持reset（比如tomcat），REST 框架需要执行反序列化，需
要读取body码流，签名逻辑也需要读取body码流，如果使用默认的处理，必然有一方功能无法实现。

所以运行于web容器场景时，所有HttpServerFilter，只要有一个返回需要缓存请求，则body码流会被复制保存起来，以支持重复读取。

入参是本次请求对应的元数据，业务可以针对该请求决定是否需要缓存请求。

* afterReceiveRequest

在收到请求后，根据url、header、query、码流计算签名，并与header中的签名对比,如果签名不对，直接构造一个Response作为返回值，
只要不是返回NULL，则框架会中断对其他HttpClientFilter的调用。

* beforeSendResponse 和 beforeSendResponseAsync

在发送应答之前，根据header、码流计算签名，并设置到header中去。因为可能invocation还没来得及构造，调用流程
已经出错，所以入参invocation可能是null。



