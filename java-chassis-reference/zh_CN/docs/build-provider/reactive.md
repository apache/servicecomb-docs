# 异步处理

异步处理可以更加充分的利用CPU，提升应用程序的性能。相对于同步处理，异步处理的开发过程更加复杂，出现的问题也更加难于定位。Java Chassis
提供了非常灵活的异步处理机制，使得开发者能够选择性的使用同步处理和异步处理。

## 定义异步处理的接口和使用异步访问

在Provider端，Spring MVC、JAX RS和RPC的异步接口定义类似，都使用`CompletableFuture`来声明异步接口。以透明RPC为例，定义方法如下：

```java
  public CompletableFuture<String> sayHello(String name) {
    CompletableFuture<String> future = new CompletableFuture<>();
    future.complete(name);
    return future;
  }
```

在Consumer端，可以使用透明RPC、InvokerUtils、AsyncRestTemplate来使用异步。以透明RPC为例，首先声明接口：

```java
public interface Hello {
  @ApiOperation(nickname = "sayHello", value = "")
  CompletableFuture<String> sayHelloAsync(String name);

  String sayHello(String name);
}
```

上面的例子同时定义了异步访问的接口和同步访问的接口，它们可以用来访问Provider的同一个接口。 使用异步接口和使用同步接口的过程一样：

```java
  @RpcReference(microserviceName = "name", schemaId = "Hello")
  public Hello hello;
```

## 异步逻辑执行的线程池

声明为异步接口，并不会改变业务逻辑入口被执行的线程。比如在Provider端，业务逻辑的入口还是在同步线程池中执行的，Edge Service在event-loop执行。
改变入口逻辑的执行线程，需要修改方法的默认线程池。异步接口执行完毕，回调逻辑在业务自定义的异步执行线程池执行。 

详细情况参考[线程池](thread-pool.md)。 

异步逻辑在更加复杂场景下的执行过程，请参考[reactive](../general-development/reactive.md)。

## 有关 event-loop 线程的特殊说明

在Edge Service等场景，或者在Provider使用了异步线程池的场景，所有的业务逻辑都是在event-loop执行的。在event-loop执行的业务代码，不能存在
任何阻塞操作，否则会破坏event-loop的事件派发，导致死锁。 这些场景访问其他微服务，必须采用异步接口。 event-loop执行阻塞操作导致死锁的情况，
或者导致性能下降的情况，需要在满足一定的并发条件才能够出现，不小心使用会给业务可靠性带来很大的风险。 Java Chassis针对常见的错误也提供了一些
检测机制，比如在event-loop执行同步Consumer调用的时候，会报告异常，让开发者及时发现问题。 


 


