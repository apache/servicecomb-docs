# 开发界面

在技术选择上，界面完全由html+js+css等静态网页技术构成，不采用动态页面技术。采用静态页面技术构建界面，使得整个微服务系统更加具备弹性，能够非常容易的进行扩容，相关开发成果也能够更好的被其他应用继承。

采用静态页面技术，也使得界面服务部署更加灵活多样：

* 将静态页面部署到nginx，nginx将REST请求转发到gateway-service。
* 将静态页面直接部署到gateway-service。
* 静态页面通过Tomcat、Spring Boot等Web服务器部署，并注册到服务中心，gateway-service将请求转发到对应的应用服务器上。
* 静态页面由第三方开发，第三方直接通过gateway-service访问REST接口。由第三方选择界面的开发技术。

这几种方式都被广泛使用。

## 将静态页面直接部署到gateway-service
在 porter 项目中，采用了将静态页面直接部署到gateway-service的方式，这种方式简洁高效。这种方式的核心代码是StaticWebpageDispatcher。它采用vert.x提供的静态页面功能，直接挂载了静态页面服务。

```
public class StaticWebpageDispatcher implements VertxHttpDispatcher {
  private static final Logger LOGGER = LoggerFactory.getLogger(StaticWebpageDispatcher.class);

  private static final String WEB_ROOT = LegacyPropertyFactory
      .getStringProperty("gateway.webroot", "/var/static");

  @Override
  public int getOrder() {
    return Integer.MAX_VALUE;
  }

  @Override
  public void init(Router router) {
    String regex = "/ui/(.*)";
    StaticHandler webpageHandler = StaticHandler.create(WEB_ROOT);
    LOGGER.info("server static web page for WEB_ROOT={}", WEB_ROOT);
    router.routeWithRegex(regex).failureHandler((context) -> {
      LOGGER.error("", context.failure());
    }).handler(webpageHandler);
  }
}
```
