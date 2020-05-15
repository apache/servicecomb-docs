# 注册发现说明

采用网络接口进行通信，并且支持多实例弹性扩缩容是微服务一个重要的特征。 一个微服务 A 需要和另外一个微服务 B 进行
通信，首先需要知道微服务 B 的网络地址信息， 这个过程一般是通过注册发现实现的。 

最常见的服务发现机制是引入一个中间件服务， 微服务 B 启动的过程中，向中间件服务注册自己的网络地址信息，微服务 A
访问 B 的时候， 首先从中间件服务查询微服务 B 的网络地址信息。

对于规模较小的系统，也可以不使用中间件服务，而是通过配置文件的方式，在微服务 A 中指定微服务 B 的地址。由于这种
静态配置的方式，需要提前知道地址信息，比较适合很小规模的系统。

在局域网环境下，还可以通过广播协议，比如 mDNS 发现其他的服务，这种方式不需要做额外的配置。

## 注册发现信息

* 微服务信息

  servicecomb 的微服务信息在类 `Microservice` 中定义。 它主要包含应用ID (appId)， 微服务名称 (serviceName),
  微服务版本(version)，环境(environment) 等信息， 还包括契约。 契约是 servicecomb 治理管控的基础，注册
  发现的实现，需要包括契约。 

* 实例信息

  servicecomb 的实例信息在类 `MicroserviceInstance` 中定义。 它主要包含网络地址(endpoints) 信息。

不同的注册发现机制，可能注册的信息和发现的信息不包括上述信息的全集，可以通过不同的注册发现机制，提供完整的信息。
比如，可以通过 mDNS 的方式发现网络地址(endpoints)信息， 可以通过配置文件的方式，发现契约信息。

## 使用服务中心 

服务中心(servicecomb-service-center) 提供了完备的注册发现机制， 实现了所有 `Microservice` 和 `MicroserviceInstance` 信息的注册和发现，
是 servicecomb 缺省使用的注册发现机制。 

服务中心支持使用PULL和PUSH两种模式通知实例变化， 开发者可以配置服务中心集群地址、连接参数以及心跳管理等。

* 表1-1 访问服务中心常用的配置项

| 配置项 | 默认值 | 是否必选 | 含义 | 
| :--- | :--- | :--- | :--- | 
| servicecomb.service.registry.</p>address | http://127.0.0.1:30100 | 是 | 服务中心的地址信息，可以配置多个，用逗号分隔。 |
| servicecomb.service.registry.</p>instance.watch | true | 否 | 是否采用PUSH模式监听实例变化。为false的时候表示使用PULL模式。 |
| servicecomb.service.registry.</p>autodiscovery | false | 否 | 是否自动发现服务中心的地址。当需要配置部分地址，其他地址由配置的服务中心实例发现的时候，开启这个配置。 |
| servicecomb.service.registry.</p>instance.healthCheck.interval | 30 | 否 | 心跳间隔。 |
| servicecomb.service.registry.</p>instance.healthCheck.times | 3 | 否 | 允许的心跳失败次数。当连续第times+1次心跳仍然失败时则实例被sc下线。即interval \* (times + 1)决定了实例被自动注销的时间。如果服务中心等待这么长的时间没有收取到心跳，会注销实例。 |
| servicecomb.service.registry.</p>instance.empty.protection | true | 否 | 当从服务中心查询到的地址为空的时候，是否覆盖本地缓存。这个是一种可靠性保护机制，避免实例异常批量下线导致的请求失败。 |

servicecomb 与服务中心采用 HTTP 进行交互， HTTP client 相关配置可以参
考 [Service Center Client 配置项](../config-reference/service-center-client.md)