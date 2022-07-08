# 通用配置说明

应用程序一般通过配置文件、环境变量等管理配置信息。微服务架构对统一配置提出了更高的要求，很多配置信息需要在不启停服务的
情况下实现动态修改。 java-chassis 对不同的配置源进行了抽象， 开发者可以不关心配置项具体的配置源，采用统一的接口读取配置。

## 配置源层级

ServiceComb提供了分层次的配置机制。按照优先级从高到低，分为：

* 配置中心（动态配置）
* Java System Property（-D参数）
* 环境变量
* 配置文件

### 配置文件

* microservice.yaml

在使用Spring启动Java Chassis的场景下， 配置文件默认是classpath下的microservice.yaml文件。Java Chassis启动时会从classpath的各个jar包、磁盘
目录中加载microservice.yaml文件，并将这些文件合并为一份microservice.yaml配置。位于磁盘上的microservice.yaml
文件优先级高于jar包中的microservice.yaml文件。用户还可以通过在配置文件中指定`servicecomb-config-order`来指定优先级，
如果不同路径下的 microservice.yaml 包含一样的配置项，文件中 `servicecomb-config-order` 值大的配置项会覆盖值小的配置项。

> Tips：由于磁盘上的microservice.yaml文件优先级较高，我们可以在打包时在服务可执行jar包的classpath里加上`.`目录，这样就可以在服务jar包所在的目录里放置一份microservice.yaml来覆盖jar包内的配置文件。

默认的配置文件名为microservice.yaml，但是我们可以通过设置Java System Property来增加其他的配置文件，或修改默认的配置文件名：

|Java System Property变量名|描述|
|---|---|
|servicecomb.configurationSource.additionalUrls|配置文件的列表，以`,`分隔的多个包含具体位置的完整文件名|
|servicecomb.configurationSource.defaultFileName|默认配置文件名|

* application.yaml

在使用Spring Boot启动Java Chassis的场景下，可以使用Spring Boot提供的配置机制。通常会通过application.yaml等文件定义配置。在Spring Boot
场景下，microservice.yaml的配置依然有效，优先级比application.yaml低。

### 环境变量

Linux的环境变量名不允许带`.`符号，因此某些配置项无法直接配置在环境变量里。可以将配置项key的`.`符号改为下划线`_`，将转换后的配置项配在环境变量里，ServiceComb-Java-Chassis可以自动将环境变量匹配到原配置项上。

例如：对于microservice.yaml中配置的
```yaml
servicecomb:
  rest:
    address: 0.0.0.0:8080
```
可以在环境变量中设置`servicecomb_rest_address=0.0.0.0:9090`来将服务监听的端口覆写为9090。这种下划线转点号的机制也适用于其他的配置层级。

### 配置中心（动态配置）

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
|servicecomb.config.client.refresh_interval|pull模式下刷新配置项的时间间隔，单位为毫秒，默认值为15000|
|servicecomb.config.client.fileSource|指定该配置项的内容为yaml文件，多个配置文件可以用`,`分隔|

* 使用 servicecomb-kie

[servicecomb-kie](https://github.com/apache/servicecomb-kie) 是全新设计的配置中心。 从 2.0.0 版本开始， java-chassis 支持使用 servicecomb-kie。 
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
    enableLongPolling: true
    domainName: default
```

servicecomb-kie 的配置项及其含义如下：

|配置项名|描述|
|---|---|
|servicecomb.kie.domainName| 区域名称，默认为default |
|servicecomb.kie.serverUri|servicecomb-kie访问地址，格式为`http(s)://{ip}:{port}`，以`,`分隔多个地址|
|servicecomb.kie.refresh_interval|interval pull模式下刷新配置项的时间间隔，单位为毫秒，默认值为15000|
|servicecomb.kie.firstRefreshInterval|interval pull模式下启动过程中首次刷新时间间隔，单位为毫秒，默认值为3000|
|servicecomb.kie.enableLongPolling|long pulling模式是否开启，默认值为true|

***说明：*** kie 的 yaml 和 properties 类型会映射为多个配置项， 其他类型，比如 json, text， 
只会映射为一个配置项。开发者需要读取配置项自己解析内容。  

* 使用 nacos

[nacos](https://github.com/alibaba/nacos) 是 alibaba 提供的配置中心。 java-chassis 从 2.1.0 版本支持 nacos。 
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
    serverAddr: http://127.0.0.1:8848
    group: jaxrstest
    dataId: jaxrsclient
    namespace: public
    # contentType 可以为 properties, yaml, raw. 
    # raw： 只增加一个配置项 [group].[dataId]=value. nacos 的 JSON/TEXT/HTML等都对应这种类型
    # properties： 增加多个配置项。 配置项前缀为 [group].[dataId]
    # yaml： 增加多个配置项。 配置项前缀为 [group].[dataId]
    contentType: properties 
    # if true [group].[dataId] will added as properties/yaml 
    # items prefix. Will not influence raw.
    addPrefix: true 
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

## 进行配置项映射

配置项映射可以用于给配置项取一个别名，在使用环境变量覆盖业务配置、兼容性场景广泛使用。
进行配置项映射通过classpath下的mapping.yaml定义：

```yaml
PAAS_CSE_SC_ENDPOINT:
  - servicecomb.service.registry.address
```

假设`PAAS_CSE_SC_ENDPOINT`是环境变量，应用程序读取`servicecomb.service.registry.address`的地方，
会取到环境变量`PAAS_CSE_SC_ENDPOINT`的值。
