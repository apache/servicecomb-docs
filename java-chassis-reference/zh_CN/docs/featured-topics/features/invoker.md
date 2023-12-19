# 特性介绍： 泛化调用

泛化调用指在不知道 Provider 接口定义信息的情况下，访问 Provider 提供的服务。 与泛化调用对应的方式包括透明 RPC（POJO）和 
RestTemplate。 透明 RPC 需要提供 Provider 对应的接口， RestTemplate 需要提供 Provider 对应的 URL 和 数据 Model 。 泛化
调用需要提供 Provider 的服务元数据： 微服务名称， 版本， Schema ID， Operation ID, 契约参数等信息。 

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
