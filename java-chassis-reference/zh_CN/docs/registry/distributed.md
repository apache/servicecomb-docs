# 轻量化配置中心 zero-config

zero-config是Java Chassis提供的轻量化服务中心，以支持在小规模的应用场景下，不必专门部署独立的服务中心。

zero-config支持多种工作模式：

* local
  单机模式，没有实例动态发现能力，所有的服务调用，都使用[调用第三方服务](../build-consumer/3rd-party-service-invoke.md)机制处理。
  
* multicast
  使用UDP多播发送微服务注册信息，适用于所有微服务实例都在同一个子网内的场景，每个微服务实例都相当于是一个服务中心实例。

使用 zero-config， 需要在项目中引入如下依赖：

```xml
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>registry-zero-config</artifactId>
</dependency>
```

## zero-config 相关配置

配置前缀： `servicecomb.service.zero-config`

| 配置项 | 默认值 | 含义 |
| :--- | :--- | :--- |
| enabled | true    | 是否使用zero-config服务中心功能 |
| mode    | multicast| 工作模式，内置multicast和local模式 |
| heartbeat.interval | 30s | 发送注册/心跳消息的间隔 |
| heartbeat.lost-times | 3 | 心跳丢失超过指定的次数，则删除相应的实例 |
| pull-interval | 3s | consumer流程更新目标实例的间隔 |
| multicast.address | 0.0.0.0:6666 | UDP的本地bind地址， 对于不允许bind 0.0.0.0的场景，需要修改本配置项。注意： 相应的网卡要打开UDP multicast功能 |
| multicast.group | 225.6.7.8| UDP multicast多播group地址，根据标准，合法地址范围为(224.0.0.0, 239.255.255.255]。开发阶段，为避免不同开发人员之间产生环境互相干扰， 可以各自设置不同的group地址|

示例：

```
servicecomb:
  service:
    zero-config:
      enable: true
      mode: multicast
      heartbeat:
        interval: 30s
        lost-times: 3
      pull-interval: 3s
      multicast:
        address: 0.0.0.0:6666
        group: 225.6.7.8
```