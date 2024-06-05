# 使用 Edge Service 做网关

Edge Service 是 Java Chassis 提供的网关服务开发框架。Edge Service作为整个微服务系统对外的接口，向最终用户提供服务，接入REST请求，转发给内部微服务，Edge Service支持REST请求和Highway请求的转发。Edge Service以开发框架的形式提供，开发者可以非常简单的搭建一个Edge Service服务，通过简单的配置就可以定义路由转发规则。同时Edge Service支持强大的扩展能力，服务映射、请求解析、加密解密、鉴权等逻辑都可以通过扩展实现。

Edge Service 本身也是一个微服务，需遵守所有微服务开发的规则。其本身可以部署为多实例，前端使用负载均衡装置进行负载分发；也可以部署为主备，直接接入用户请求。开发者可以根据Edge Service承载的逻辑和业务访问量、组网情况来规划。

## 开发 Edge Service 服务

开发 Edge Service 和开发一个普通的微服务步骤差不多，开发者可以从导入[Edge Service Samples](https://github.com/apache/servicecomb-samples/tree/master/basic/gateway) 入手。从头搭建项目包含如下几个步骤：

* 配置依赖关系

在项目中加入edge-core的依赖，就可以启动Edge Service的功能。

```
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>java-chassis-spring-boot-starter-standalone</artifactId>
    </dependency>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>edge-core</artifactId>
    </dependency>
```

* 定义启动类

和开发普通微服务一样，可以通过 `@SpringBootApplication` 的方式将服务拉起来。

```
@SpringBootApplication
public class GatewayApplication {
  public static void main(String[] args) throws Exception {
    try {
      new SpringApplicationBuilder()
          .web(WebApplicationType.NONE)
          .sources(GatewayApplication.class)
          .run(args);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
```

* 增加配置文件 application.yml

Edge Service本身也是一个微服务，遵循微服务查找的规则，自己也会进行注册。注意 `application` 与需要转发的微服务相同。在下面的配置中，指定了Edge Service监听的地址，处理链等信息。其中auth处理链是DEMO项目中自定义的处理链，用于实现认证。同时auth服务本身，不经过这个处理链，相当于不鉴权。

```
servicecomb:
  service:
    application: basic-application
    name: gateway
    version: 0.0.1

  rest:
    address: 0.0.0.0:9090?sslEnabled=false
```

## 定制路由规则
使用Edge Service的核心工作是配置路由规则。场景不同，规则也不同。
路由规则由一系列AbstractEdgeDispatcher组成。Edge Service提供了几个常见的Dispatcher，通过配置即可启用，如果这些Dispatcher不满足业务场景需要，还可以自定义。

### 使用 DefaultEdgeDispatcher

DefaultEdgeDispatcher是一个非常简单、容易管理的Dispatcher，使用这个Dispatcher，用户不用动态管理转发规则，应用于实际的业务场景非常方便，不足之处是用户实际请求必须使用微服务名作为URL前缀的一部分。它包含如下几个配置项：

```
servicecomb:
  http:
    dispatcher:
      edge:
        default:
          enabled: true
          prefix: rest
          prefixSegmentCount: 1
```

常见的这些配置项的示例及含义如下:

  * [prefix=rest;prefixSegmentCount=1]微服务xService提供的URL为: /xService/abc，通过Edge访问的地址为/rest/xService/abc。
  * [prefix=rest;prefixSegmentCount=2]微服务xService提供的URL为: /abc，通过Edge访问的地址为/rest/xService/abc。

### 使用 URLMappedEdgeDispatcher

URLMappedEdgeDispatcher 允许用户配置URL和微服务的映射关系。使用它可以非常灵活的定义哪些URL转发到哪些微服务。它包含如下几个配置项：

```yaml
servicecomb:
  http:
    dispatcher:
      edge:
        url:
          enabled: true
          ## 默认值，一般不需要配置
          pattern: "/api/(.*)"
          mappings:
            resource-server:
              prefixSegmentCount: 2
              path: "/api/resource/.*"
              microserviceName: resource-server
            authentication-server:
              prefixSegmentCount: 2
              path: "/api/authentication/.*"
              microserviceName: authentication-server
            admin-service:
              prefixSegmentCount: 2
              path: "/api/admin/.*"
              microserviceName: admin-service
```

`path` 定义了前端请求匹配的URL，`prefixSegmentCount`定义了往后台微服务转发的时候，需要截取的URL前缀数量，`microserviceName` 定义了目标微服务。 上述例子中，如果请求路径为 `/api/admin/hello/world`, 那么请求会转发到`admin-service`，转发路径为`/hello/world`。

### 使用 CommonHttpEdgeDispatcher

CommonHttpEdgeDispatcher 能够将请求转发到监听 HTTP 或者 HTTP 2 协议的 Provider， 对于 Provider 的开发框架没有限制，也不要求 Provider 注册契约信息。 通常应用于第三方微服务也注册到了注册中心，但是是使用的非Java Chassis开发的微服务，比如使用Spring Boot或者Spring Cloud开发的微服务或者静态页面服务。 

```yaml
servicecomb:
  http:
    dispatcher:
      edge:
        http:
          enabled: true
          pattern: "/ui/(.*)"
          mappings:
            admin-website:
              prefixSegmentCount: 0
              path: "/ui/admin/.*"
              microserviceName: admin-website
```

CommonHttpEdgeDispatcher 配置项的含义和 URLMappedEdgeDispatcher 一样。

## 定制公共转发 Header

Edge Service 在转发请求的时候, 会默认过滤掉 `公共请求头` 。 也就是除了 **Provider** 端显示 声明需要的 `HEADER` 外， 其他的 header 在转发的时候都会丢失。用户可以通过配置相关参数保留 公共请求头。

```yaml
servicecomb:
  edge:
    filter:
      addHeader:
        # 要保留的公共请求头，以逗号隔开
        allowedHeaders: external_1,external_2
```

如果对接了配置中心， 可以在配置中心动态修改`servicecomb.edge.filter.addHeader.allowedHeaders` ， 配置动态生效。

> 注意：本节内容适用于3.1.2及其以上版本

## 工作模式

Edge Service默认工作于高性能的reactive模式:

![](../assets/reactive.png)

此模式要求工作于Edge Service转发流程中的业务代码不能有任何的阻塞操作，包括不限于：

  * 远程同步调用，比如同步查询数据库、同步调用微服务，或是同步查询远程缓存等等

  * 任何的sleep调用

  * 任何的wait调用

  * 超大的循环

Edge Service的底层是基于netty的vertx，以上约束即是netty的reactive模式约束。


## 扩展Edge Service的功能

Edge Service和普通的微服务一样，通过 `EdgeFilter` 来扩展其处理功能。 流量特征治理等功能在Edge Service也是开箱即用的。 通过扩展 `EdgeFilter`， 还可以实现认证鉴权等功能。 
