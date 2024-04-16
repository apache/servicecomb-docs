# 使用 Apollo

>>> 注意：本实现作为适配 Apollo 的参考，整体逻辑功能和设计规格不完善，不建议在生产环境使用。 如果在生产环境使用，建议基于 Apollo 提供的 SDK 自行扩展实现。

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
