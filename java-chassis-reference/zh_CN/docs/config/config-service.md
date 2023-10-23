# 配置中心参考

配置中心是微服务架构下一个非常重要的中间件，通过配置中心用户可以增加和删除配置信息，配置信息会通过不同的通知机制， 将配置的变化推送到微服务实例。 Java Chassis 允许用户使用不同的配置中心， 并支持多个配置中心共存。

## 使用 Kie

* 下载安装
   
  可以通过 [Kie官网](https://kie.readthedocs.io/en/latest/get-started.html) 下载和安装Kie。华为云提供了一个集成注册中心的本地版本，并提供了友好的界面，可以通过 [华为云](https://support.huaweicloud.com/devg-cse/cse_04_0046.html) 下载和使用。 

  <br/>
* 开发使用

  在 java-chassis 中使用 Kie， 需要引入下面的依赖：

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
    ```

  <br/>
* 使用配置中心增加配置

  客户端默认会读取下面几个层次的配置：

  * 应用级配置：Label只包含environment、app，并且与微服务的环境、应用匹配的配置。
  * 服务级配置：Label只包含environment、app、service，并且与微服务的环境、应用、微服务名称匹配的配置。
  * 版本级配置：Label只包含environment、app、service、version，并且与微服务的环境、应用、微服务名称、版本匹配的配置。
  * 自定义配置：Label包含custom-label, 并且与 custom-value匹配的配置。 

  上述的配置级别，优先级从低到高。 Kie 的 yaml 和 properties 类型会映射为多个配置项， 其他类型，比如 json, text， 只会映射为一个配置项。开发者需要读取配置项自己解析内容。

  <br/>
* 配置项参考

    |配置项名| 含义                      | 缺省值     |
    |------------------------|---------|---|
    |servicecomb.kie.serverUri| servicecomb-kie访问地址，格式为`http(s)://{ip}:{port}`，以`,`分隔多个地址 | 空       |
    |servicecomb.kie.enableLongPolling| Long Polling 模式是否开启                                       | true    |
    |servicecomb.kie.pollingWaitTime| Long Polling 模式下等待时间，单位为秒                                 | 10      |
    |servicecomb.kie.firstPullRequired| 启动的时候第一次查询配置失败，是否终止启动。                                    | true    |
    |servicecomb.kie.domainName| 区域名称                                                      | default |
    |servicecomb.kie.refresh_interval| Pull 模式下刷新配置项的时间间隔，单位为毫秒。                                 | 15000   |
    |servicecomb.kie.firstRefreshInterval| Pull 模式下启动过程中首次刷新时间间隔，单位为毫秒。                              | 3000    |
    |servicecomb.kie.enableAppConfig| 是否开启应用配置  | true    |
    |servicecomb.kie.enableServiceConfig| 是否开启服务配置     | true    |
    |servicecomb.kie.enableVersionConfig| 是否开启版本配置     | true    |
    |servicecomb.kie.enableVersionConfig| 是否开启自定义配置     | true    |
    |servicecomb.kie.customLabel| 自定义配置的Label     | public    |
    |servicecomb.kie.customLabelValue| 自定义配置的Value     | 空    |


## 使用 nacos

* 下载安装

  可以通过 [nacos官网](https://github.com/alibaba/nacos) 下载和安装 Nacos。

  <br/>

* 开发使用
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
    serverAddr: http://127.0.0.1:8848
```
  <br/>

* 使用配置中心增加配置

  Nacos的namespace对应于Java Chassis Environment, group对应于application。 客户端默认会读取下面几个层次的配置：

    * 应用级配置：group为application名称，data-id为application名称，并且类型为yaml的配置。
    * 服务级配置：group为application名称，data-id为微服务名称，并且类型为yaml的配置。
    * 版本级配置：group为application名称，data-id为微服务名称+版本号，并且类型为yaml的配置， 比如: service-0.1
    * Profile级配置：group为application名称，data-id为微服务名称+Profile名称，并且类型为yaml的配置， 比如: service-dev
    * 自定义配置：可以通过配置项定义group、data-id、类型等信息，详情参考配置项。。

  上述的配置级别，优先级从低到高。 

  <br/>

* 配置项参考

  |配置项名| 含义                                              | 缺省值    |
      |-------------------------------------------------|--------|---|
  |servicecomb.nacos.serverAddr| NACOS访问地址，格式为`http(s)://{ip}:{port}`，以`,`分隔多个地址 | 空      |
  |servicecomb.nacos.group| 自定义group                                        | 空      |
  |servicecomb.nacos.dataId| 自定义data-id                                      | 空      |
  |servicecomb.nacos.addPrefix| 是否使用group+data-id作为配置项前缀                        | false  |
  |servicecomb.nacos.contentType| 自定义类型                                           | _yaml_ |
  |servicecomb.nacos.username| 连接Nacos的用户名                                     | 空      |
  |servicecomb.nacos.password| 连接Nacos的密码                                      | 空      |
  |servicecomb.nacos.accessKey| 连接Nacos的Access Key                              | 空      |
  |servicecomb.nacos.secretKey| 连接Nacos的Secret Key                              | 空      |

## 使用 Apollo

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

## 华为云CSE1.0配置中心

华为云CSE1.0配置中心是华为云CSE产品的一个部件，java-chassis 最早使用它作为配置中心。 对接这个配置中心的代码在 config-cc 模块实现。

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
|servicecomb.config.client.refresh_interval|pull模式下刷新配置项的时间间隔，单位为毫秒，默认值为15000|
|servicecomb.config.client.fileSource|指定该配置项的内容为yaml文件，多个配置文件可以用`,`分隔|
