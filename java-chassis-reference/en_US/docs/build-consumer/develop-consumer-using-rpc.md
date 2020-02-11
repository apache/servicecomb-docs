# Develop consumer with transparent RPC
## Concepts

The transparent RPC allows user to access services like a local call through a simple java interface.
Transparent RPC is just a development mode:

- Not associated with highway or RESTful transport
- The RPC does not rely on producers' development mode(transparent RPC/Jax-RS or SpringMVC)
- The RPC works even if the producer doesn't implement the interface.

The transparent RPC is similar to spring cloud's feign, but simpler because there is no need to add any RESTful annotations in interface.



## Declare PRC by @RpcReference in spring bean

```java
@Component
public class SomeBean {
  ......
  
  @RpcReference(microserviceName = "helloService", schemaId = "helloSchema")
  private Hello hello;
  
  ......
}
```

## Declare by API without spring bean

```java
Hello hello = Invoker.createProxy("helloService", "helloSchema", Hello.class);
```

## reactive

Just use jdk's CompletableFuture to wrap the return value:

```java
interface Hello {
  CompletableFuture<String> sayHi(String name);
}
```

In the same interface, you can declare both the reactive and synchronous prototypes of the same method.
It is illegal in java that the method name is the same with the operationId in the contract while the return value type is different, so you need to modify the method name and declare the real operationId through the swagger annotation.

```java
interface Hello {
  String sayHi(String name);
  
  @ApiOperation(nickname = "sayHi", value = "reactive method for sayHi")
  CompletableFuture<String> asyncSayHi(String name);
}
```

