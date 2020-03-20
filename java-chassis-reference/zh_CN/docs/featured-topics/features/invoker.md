# 2.0.1 新特性介绍： 泛化调用

泛化调用指在不知道 Provider 接口定义信息的情况下，访问 Provider 提供的服务。 与泛化调用对应的方式包括透明 RPC（POJO）和 
RestTemplate。 透明 RPC 需要提供 Provider 对应的接口， RestTemplate 需要提供 Provider 对应的 URL 和 数据 Model 。 泛化
调用需要提供 Provider 的服务元数据： 微服务名称， 版本， Schema ID， Operation ID, 契约参数等信息。 

java-chassis 很早就提供了泛化调用， 本文重点介绍 2.0.1 的功能。 2.0.1 对于泛化调用的接口进行了优化， 支持指定响应类型，
早期的版本的响应类型取决于运行上下文， 是不确定的。 

## 使用泛化调用

假设 Provider 采用透明 RPC 的方式提供了如下服务：

```java
@RpcSchema(schemaId = "InvokerEndpoint")
public class InvokerEndpoint {
  public ServerModel model(ServerModel request) {
    return request;
  }
}

public class ServerModel {
  private String name;
  private int code;

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public int getCode() {
    return code;
  }

  public void setCode(int code) {
    this.code = code;
  }
}
```

可以采用 InvokerUtils 访问这个服务：

```java
Map<String, Object> args = new HashMap<>();
ClientModel model = new ClientModel();
model.setCode(200);
model.setName("hello");
args.put("request", model);

ClientModel modelResult = InvokerUtils.syncInvoke("pojo", "InvokerEndpoint", "model", args, ClientModel.class);
TestMgr.check(model.getCode(), modelResult.getCode());
TestMgr.check(model.getName(), modelResult.getName());

public class ClientModel {
  private String name;
  private int code;

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public int getCode() {
    return code;
  }

  public void setCode(int code) {
    this.code = code;
  }
}
```

可以看出，在泛化调用的情况下， Provider 和 Consumer 可以使用不一样 package 的 Model。 Consumer 还可以不使用任何 Model, 而采用
Map 的方式访问：

```java
Map<String, Object> args = new HashMap<>();
Map model = new HashMap();
model.put("code", 20);
model.put("name", "hello");
args.put("request", model);

ClientModel modelResult = InvokerUtils.syncInvoke("pojo", "InvokerEndpoint", "model", args, ClientModel.class);
TestMgr.check(model.get("code"), modelResult.getCode());
TestMgr.check(model.get("name"), modelResult.getName());
```

需要特别说明的是参数 `swaggerArguments` ， 这个参数是和 Provider 接口生成的契约对应的， 不关注 Provider 是采用透明 RPC， 还是
采用 Spring MVC ， 或者 JAX RS 开发的服务。 需要注意 `swaggerArguments` 可能和 Provider 的接口定义的参数列表不一样，比如透明
RPC 开发模式下多个参数的场景， Spring MVC 的 Bean Param 的场景等等。 

## 采用 reactive API
2.0.1 泛化调用还增加了对应的 reactive API， 这样更加方便采用 reactive 方式调用 Provider 的服务。 

```java
CountDownLatch countDownLatch = new CountDownLatch(1);
InvokerUtils.reactiveInvoke("pojo", "InvokerEndpoint", "model", args, ClientModel.class, response -> {
  ClientModel reactiveResult = response.getResult();
  TestMgr.check(model.getCode(), reactiveResult.getCode());
  TestMgr.check(model.getName(), reactiveResult.getName());
  countDownLatch.countDown();
});
countDownLatch.await();
```  

## 2.0.1 版本之前的 API 

2.0.1 版本之前的 API 不能够指定 `responseType` ， 因此返回值类型是不确定的， 这个取决于运行的上下文。 如果 Consumer 没有加载
任何 `@RpcReference` 信息， 并且不存在 Provider 返回值 Model ， 那么返回值类型是 Map ； 否则返回结果可能是和 Provider 具备相同
package 类的实例， 这个返回接口的类型还可能和加载顺序有关。 由于这种不确定性， 早期的 API 使用 `@Deprecated` 声明为废弃。 将
`responseType`  设置为 null ， 能够获得和早期 API 一样的效果。 


