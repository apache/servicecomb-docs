# 华为云CSE1.0配置中心

>>> 注意：CSE1.0配置中心已经逐步下线， 本实现仅供遗留功能使用，新功能不建议使用。

华为云CSE1.0配置中心是华为云CSE产品的一个部件，java-chassis 最早使用它作为配置中心。 对接这个配置中心的代码在 config-cc 模块实现。

可以从 [轻量化微服务引擎](https://cse-bucket.obs.myhwclouds.com/LocalCSE/Local-CSE-1.0.3.zip) 下载本地使用的版本。也可以
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
