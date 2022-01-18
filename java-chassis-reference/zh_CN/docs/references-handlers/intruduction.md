# 处理链参考

处理链(Handlers)是ServiceComb的核心组成部分，它们构成服务运行管控的基础。ServiceComb通过处理链来处理负载均衡、熔断容错、流量控制等。

## 处理链配置

处理链分为Consumer和Provider，分别配置如下：

```yaml
servicecomb:
  handler:
    chain:
      Consumer:
        default: qps-flowcontrol-consumer,loadbalance
      Provider: 
        default: qps-flowcontrol-provider
```

通过名字配置处理链，可以根据需要调整处理链的顺序，配置在前面的处理链先执行。不同的处理链可能存在一定的逻辑关联，处理链的顺序
不同，程序运行的效果会存在差异。

上述配置指定目标微服务缺省处理链，开发者还可以对特定的微服务配置不同的处理链，比如：

```yaml
servicecomb:
  handler:
    chain:
      Consumer:
        default: auth,qps-flowcontrol-consumer,loadbalance
        service:
          authentication-server: qps-flowcontrol-consumer,loadbalance
```

对于转发到authentication-server的请求，不经过auth处理链，转发到其他的微服务的请求，则经过auth处理链。

## 开发新的处理链

开发者自定义处理链包含如下几个步骤。由于ServiceComb的核心组成就是处理链，开发者可以参考handlers目录的实现详细了解处理链。下面简单总结下几个关键步骤：

* 实现Handler接口

```java
public class AuthHandler implements Handler {
  @Override
  public void handle(Invocation invocation, AsyncResponse asyncResponse) throws Exception {
    String token = invocation.getContext(Constants.CONTEXT_HEADER_AUTHORIZATION);
    if (token == null) {
      asyncResponse.consumerFail(new InvocationException(403, "forbidden", "not authenticated"));
      return;
    }
    Jwt jwt = JwtHelper.decode(token);
    try {
      jwt.verifySignature(BeanUtils.getBean("authSigner"));
    } catch (InvalidSignatureException e) {
      asyncResponse.consumerFail(new InvocationException(403, "forbidden", "not authenticated"));
      return;
    }
    invocation.next(asyncResponse);
  }
}
```

* 增加*.handler.xml文件，给Handler取一个名字,并且文件要放在```classpath*:config/```路径下

```xml
<config>
  <handler id="auth"
    class="org.apache.servicecomb.authentication.gateway.AuthHandler" />
</config>
```

* 在microservice.yaml中启用新增加的处理链

```yaml
servicecomb:
  handler:
    chain:
      Consumer:
        default: auth,loadbalance
        service:
          authentication-server: loadbalance
```




