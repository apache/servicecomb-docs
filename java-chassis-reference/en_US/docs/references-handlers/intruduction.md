## Handlers Reference
Handlers are the core components of ServiceComb, which form the basis of service operation and control. ServiceComb handles load balancing, fuse tolerance, flow control, and more through the Handlers.

### Enable Handlers
There are Consumer Handlers and Provider Handlers. Enable handlers in microservice.yaml:

```
servicecomb:
  handler:
    chain:
      Consumer:
        default: qps-flowcontrol-consumer,loadbalance
      Provider: 
        default: qps-flowcontrol-provider
```

We can also enable different handlers for each microservice, 

```
servicecomb:
  handler:
    chain:
      Consumer:
        default: auth,qps-flowcontrol-consumer,loadbalance
        service:
          authentication-server: qps-flowcontrol-consumer,loadbalance
```

Requests to authentication-server, auth handler is enabled, and others not. 

### Development Handlers
The developer's custom handlers consists of the following steps. Since the core component of ServiceComb is the handlers, developers can refer to the implementation of the handlers directory to learn more about the Handlers. Here are a few key steps to summarize:

* Implement Handler interface

```
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

* Add *.handler.xml file, give handler a name


```
<config>
  <handler id="auth"
    class="org.apache.servicecomb.authentication.gateway.AuthHandler" />
</config>
```


* Enable the newly added Handlers in microservice.yaml


```
servicecomb:
  handler:
    chain:
      Consumer:
        default: auth,loadbalance
        service:
          authentication-server: loadbalance
```

