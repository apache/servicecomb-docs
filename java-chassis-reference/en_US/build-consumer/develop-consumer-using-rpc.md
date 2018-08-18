# 使用透明RPC方式开发服务消费者

## 概念阐述

透明RPC开发模式允许用户通过简单的java interface像本地调用一样进行服务调用。  
透明RPC仅仅是一种开发模式：
* 与使用highway还是RESTful传输没有关联
* 与producer使用透明RPC/Jax-RS还是SpringMVC模式开发没有关联
* 也与producer代码是否实现这个interface没有关联。  
  
透明RPC开发模式与spring cloud的feign类似，不过更简单，因为不必在这个interface中增加任何RESTful annotation。

## 在spring bean中通过@RpcReference声明
```java
@Component
public class SomeBean {
  ......
  
  @RpcReference(microserviceName = "helloService", schemaId = "helloSchema")
  private Hello hello;
  
  ......
}
```
## 脱离spring bean，直接通过api声明
```java
Hello hello = Invoker.createProxy("helloService", "helloSchema", Hello.class);
```

## reactive
只需要使用jdk的CompletableFuture对返回值进行包装即可
```java
interface Hello {
  CompletableFuture<String> sayHi(String name);
}
```

同一个interface中，可以同时声明同一个方法的reactive和同步原型  
因为要求方法名与契约中的operationId一一对应，而仅有返回值类型不同，在java中是非法的，所以需要修改方法名，并通过swagger annotation来声明真正的operationId
```java
interface Hello {
  String sayHi(String name);
  
  @ApiOperation(nickname = "sayHi", value = "reactive method for sayHi")
  CompletableFuture<String> asyncSayHi(String name);
}
```
