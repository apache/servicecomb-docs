# 2.0.2 新特性介绍： Edge Service 通用的 HTTP 转发器 CommonHttpEdgeDispatcher

Edge Service 提供了非常丰富的 HTTP 转发器，并支持自定义扩展。在 2.0.2 版本之前，缺省提供的转发器都是针对
使用 java-chassis 开发的微服务设计的，这些转发器除了能够转发请求到不同的 transport ， 还能够支持 consumer
端服务治理， 和普通的 consumer 调用类似。 在实际业务中，可能存在不同开发框架并存的情况，也可能包含遗留应用
系统，或者需要将请求转发到其他第三方系统的场景。 2.0.2 提供了一个新的转发器 CommonHttpEdgeDispatcher 支持这些场景。 

CommonHttpEdgeDispatcher 要求目标微服务注册到服务中心，能够被自动发现。新的转发器可以管理实例状态，提供负载均衡策略配置，
提供实例隔离等基本治理功能。 

CommonHttpEdgeDispatcher 能够将请求转发到监听 HTTP 或者 HTTP 2 协议的 Provider， 对于 Provider 的开发框架没有限制，也不
要求 Provider 注册契约信息。 

## 使用 CommonHttpEdgeDispatcher

在 Edge Service 启用 CommonHttpEdgeDispatcher 非常简单， 只需要在 `microservice.yaml` 中增加下面的配置。 

```yaml
servicecomb:
  http:
    dispatcher:
        http:
          enabled: true
          mappings:
            businessV2:
              prefixSegmentCount: 1
              path: "/http/business/v2/.*"
              microserviceName: business
              versionRule: 2.0.0
            businessV1:
              prefixSegmentCount: 1
              path: "/http/business/v1/add.*"
              microserviceName: business
              versionRule: 1.0.0-1.2.0
            businessV1_1:
              prefixSegmentCount: 1
              path: "/http/business/v1/dec.*"
              microserviceName: business
              versionRule: 1.1.0
```

通用的 HTTP 转发器的配置项和 `URLMappedEdgeDispatcher` 非常类似。 可以配置一系列的 mappings 定义 URL 与
微服务之间的转发关系。 上述配置定义了 3 个 mappings， 第 1 个将 URL 满足 `/http/business/v2/.*` 的请求
转发到 business 服务 2.0.0 版本实例， 后端服务实际的 URL 为 `/business/v2/.*` 。 第 2 个演示了灰度转发，
将请求转发到 1.0.0 以上（含）， 1.2.0 以下（不含） 的版本。 

## CommonHttpEdgeDispatcher 的治理

CommonHttpEdgeDispatcher 集成了 loadbalance 模块提供的治理能力， 在 [负载均衡](../../references-handlers/loadbalance.md) 里面的治理
能力都可以使用，除了 `设置重试策略` 。 这个转发器通常被用于转发 UI 请求到后端的静态页面服务，以及遗留的使用 spring
boot 开发的微服务， 或者采用 spring-cloud-huawei 接入服务中心的 spring cloud 微服务应用。 



