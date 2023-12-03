# 开发网关

这个章节中，介绍如何通过网关转发请求。Java Chassis 提供了非常灵活的网关服务，开发者能够非常简单的实现微服务之间的转发，网关拥有客户端一样的服务治理能力。

网关服务由一系列的VertxHttpDispatcher组成，开发者通过继承AbstractEdgeDispatcher，来实现自己的转发机制。

为了实现gateway-service将请求转发到file-service，定义了如下规则：

* 直接请求file-service: DELETE [http://localhost:9091/delete](http://localhost:9091/delete)

* 通过网关：DELETE [http://localhost:9090/api/file-service/delete](http://localhost:9090/api/file-service/delete)

达到这个目的的代码如下，在请求处理的时候，使用EdgeInvocation，可以实现请求转发，并开启各种治理功能。下面代码的核心内容是定义转发规则regex。

```
public class ApiDispatcher extends AbstractEdgeDispatcher {
  public static final String MICROSERVICE_NAME = "param0";

  @Override
  public int getOrder() {
    return 10002;
  }

  @Override
  public void init(Router router) {
    String regex = "/api/([^\\/]+)/(.*)";
    router.routeWithRegex(regex).handler(createBodyHandler());
    router.routeWithRegex(regex).failureHandler(this::onFailure).handler(this::onRequest);
  }

  protected void onRequest(RoutingContext context) {
    String microserviceName = extractMicroserviceName(context);
    String path = Utils.findActualPath(context.request().path(), 2);

    requestByFilter(context, microserviceName, path);
  }

  @Nullable
  private String extractMicroserviceName(RoutingContext context) {
    return context.pathParam(MICROSERVICE_NAME);
  }

  protected void requestByFilter(RoutingContext context, String microserviceName, String path) {
    HttpServletRequestEx requestEx = new VertxServerRequestToHttpServletRequest(context);
    HttpServletResponseEx responseEx = new VertxServerResponseToHttpServletResponse(context.response());
    InvocationCreator creator = new EdgeInvocationCreator(context, requestEx, responseEx,
        microserviceName, path) {
      @Override
      protected Invocation createInstance() {
        Invocation invocation = super.createInstance();
        // get session id from header and cookie for debug reasons
        String sessionId = context.request().getHeader("session-id");
        if (sessionId != null) {
          invocation.addContext("session-id", sessionId);
        } else {
          Cookie sessionCookie = context.request().getCookie("session-id");
          if (sessionCookie != null) {
            invocation.addContext("session-id", sessionCookie.getValue());
          }
        }
        return invocation;
      }
    };
    new RestProducerInvocationFlow(creator, requestEx, responseEx)
        .run();
  }
}
```

为了实现gateway-service将请求转发到porter-website，定义了如下规则：

* 直接请求porter-website: GET [http://localhost:9093/index.html](http://localhost:9093/index.html)

* 通过网关：GET [http://localhost:9090/ui/porter-website/index.html](http://localhost:9090/ui/porter-website/index.html)

完成VertxHttpDispatcher开发后，需要通过SPI的方式加载到系统中，需要增加META-INF/services/org.apache.servicecomb.transport.rest.vertx.VertxHttpDispatcher配置文件，并将增加的两个实现写入该配置文件中。

网关服务开发完成后，所有的用户请求都可以通过网关来发送。开发者通过通过设置防火墙等机制，限制用户直接访问内部服务，保证内部服务的安全。
