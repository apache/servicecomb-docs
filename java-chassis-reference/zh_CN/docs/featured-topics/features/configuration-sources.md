# 2.0.0 新特性介绍： 多配置中心支持

很多热心的开发者给 2.0.0 贡献了很多新的特性， @GuoYL123 贡献了 servicecomb-kie 的支持， @160731liupf 贡献了 nacos
的支持， 本文介绍开发者如何在自己的项目中使用这些配置中心。

## Java Chassis 配置源介绍和使用指南

配置中心是微服务架构下一个非常重要的中间件，通过配置中心用户可以增加和删除配置信息，配置信息会通过不同的通知机制（通常包括
PULL 和 PUSH）， 将配置的变化推送到微服务实例。 java-chassis 允许用户使用不同的配置中心， 目前支持用户使用如下几种配置中心：

* 华为云配置中心

华为云配置中心是华为云CSE产品的一个部件，java-chassis 最早使用它作为配置中心。 对接这个配置中心的代码在 config-cc 模块实现。
可以从[轻量化微服务引擎](https://cse-bucket.obs.myhwclouds.com/LocalCSE/Local-CSE-1.0.3.zip)下载本地使用的版本。也可以
直接访问华为云 [ServiceStage](https://console.huaweicloud.com/servicestage) 产品，使用在线的版本。

使用华为云配置中心，需要在项目中引入如下依赖：

```xml
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>config-cc</artifactId>
</dependency>
```

然后在配置文件 microservice.yaml 中增加如下配置项：

```yaml
servicecomb:
  config:
    client:
      serverUri: http://127.0.0.1:30113
      refreshMode: 0
      refresh_interval: 5000
      refreshPort: 30114
```

华为云配置中心的其他配置项含义如下：

|配置项名|描述|
|---|---|
|servicecomb.config.client.refreshMode|应用配置的刷新方式，`0`为config-center主动push，`1`为client周期pull，默认为`0`|
|servicecomb.config.client.refreshPort|config-center推送配置的端口|
|servicecomb.config.client.tenantName|应用的租户名称|
|servicecomb.config.client.serverUri|config-center访问地址，格式为`http(s)://{ip}:{port}`，以`,`分隔多个地址|
|servicecomb.config.client.refresh_interval|pull模式下刷新配置项的时间间隔，单位为毫秒，默认值为30000|

* 使用 servicecomb-kie

[servicecomb-kie](https://github.com/apache/servicecomb-kie) 是全新设计的配置中心。 
从 2.0.0 版本开始， java-chassis 支持使用 servicecomb-kie。 
从 2.0.1 版本开始， java-chassis 默认使用long polling 拉取 servicecomb-kie 配置，来节省间隔轮询带来的网络消耗。 
servicecomb-kie 的安装指导可以参考官网文档。 在 java-chassis 中使用 servicecomb-kie， 需要引入下面的依赖：

```xml
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>config-kie</artifactId>
</dependency>
```

然后在配置文件 microservice.yaml 中增加如下配置项：

```yaml
servicecomb:
  kie:
    serverUri: http://127.0.0.1:30110
    refresh_interval: 5000
    firstRefreshInterval: 5000
    domainName: default
```

servicecomb-kie 的配置项及其含义如下：

|配置项名|描述|
|---|---|
|servicecomb.kie.domainName| 区域名称，默认为default |
|servicecomb.kie.serverUri|servicecomb-kie访问地址，格式为`http(s)://{ip}:{port}`，以`,`分隔多个地址|
|servicecomb.kie.refresh_interval|pull模式下刷新配置项的时间间隔，单位为毫秒，默认值为3000|
|servicecomb.kie.firstRefreshInterval|pull模式下启动过程中首次刷新时间间隔，单位为毫秒，默认值为3000|

* 使用 nacos

[nacos](https://github.com/alibaba/nacos) 是 alibaba 提供的配置中心。 java-chassis 从 2.0.0 版本支持 nacos。 
nacos的下载安装请参考官网介绍。 

使用nacos，需要在项目中引入如下依赖：

```xml
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>config-nacos</artifactId>
</dependency>
```

然后在配置文件 microservice.yaml 中增加如下配置项：

```yaml
servicecomb:
  nacos:
    serverUri: http://127.0.0.1:8848
    group: DEFAULT_GROUP
    dataId: example
```

* 使用 Apollo

[Apollo](https://github.com/ctripcorp/apollo) 是携程框架部门研发的分布式配置中心。 Apollo的下载安装请参考官网介绍。 

```xml
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>config-apollo</artifactId>
</dependency>
```

然后在配置文件 microservice.yaml 中增加如下配置项：

```yaml
apollo:
  config:
    serverUri: http://127.0.0.1:8070
    serviceName: apollo-test
    env: DEV
    clusters: test-cluster
    namespace: application
    token: xxx
    refreshInterval: 30
    firstRefreshInterval: 0
```

## 参与配置源的开发和贡献

2.0.0 版本提供了4种配置源的支持， 如果采用 Spring Boot 运行模式， 由于 Java Chassis 继承和适配了 Spring Boot 的
配置源，  因此 Spring Boot 采用的配置源也可以平滑的被 Java Chassis 应用程序使用。 比如 Java Chassis 在 Spring Boot
集成模式下使用 application.yml 作为配置文件， 可以使用 git 作为动态配置源。 

因此， Java Chassis 已经支持大部分开发者能够使用的配置源。 然而，目前的支持仍然是不够的， 每一个不同的配置中心
都提供了非常独特的功能， Java Chassis 只是集成了它们极少的核心功能， 维护一个配置中心的支持，需要长期大量的应用
验证，才能够把功能做的稳定和强大。 因此，配置中心的支持还需要开发者帮助持续的贡献代码。

Java Chassis 的配置扩展是基于 [archaius](https://github.com/Netflix/archaius)， 开发者只需要实现 `ConfigCenterConfigurationSource`,
即可以接入其他配置中心。 Java Chassis 的源码目录 config-cc， config-apollo, config-kie, config-nacos 分别实现了
这个接口。 

* [nacos 支持PR](https://github.com/apache/servicecomb-java-chassis/pull/1405)
* [servicecomb-kie 支持PR](https://github.com/apache/servicecomb-java-chassis/pull/1518)
* [Java Chassis 通用配置说明](http://localhost:8000/config/general-config/)
