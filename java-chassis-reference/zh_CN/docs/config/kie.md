# 使用 Kie

## 下载安装

  可以通过 [Kie官网](https://kie.readthedocs.io/en/latest/get-started.html) 下载和安装Kie。华为云提供了一个集成注册中心的本地版本，并提供了友好的界面，可以通过 [华为云](https://support.huaweicloud.com/devg-cse/cse_04_0046.html) 下载和使用。

## 开发使用

使用 Kie， 需要引入下面的依赖：

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

* 使用配置中心增加配置

  客户端默认会读取下面几个层次的配置：

    * 应用级配置：Label只包含environment、app，并且与微服务的环境、应用匹配的配置。
    * 服务级配置：Label只包含environment、app、service，并且与微服务的环境、应用、微服务名称匹配的配置。
    * 版本级配置：Label只包含environment、app、service、version，并且与微服务的环境、应用、微服务名称、版本匹配的配置。
    * 自定义配置：Label包含custom-label, 并且与 custom-value匹配的配置。

  上述的配置级别，优先级从低到高。 Kie 的 yaml 和 properties 类型会映射为多个配置项， 其他类型，比如 json, text， 只会映射为一个配置项。开发者需要读取配置项自己解析内容。


* 配置项参考

| 配置项名                                 | 含义                                                        | 缺省值     |
|--------------------------------------|-----------------------------------------------------------|---------|
| servicecomb.kie.serverUri            | servicecomb-kie访问地址，格式为`http(s)://{ip}:{port}`，以`,`分隔多个地址 | 空       |
| servicecomb.kie.enableLongPolling    | Long Polling 模式是否开启                                       | true    |
| servicecomb.kie.pollingWaitTime      | Long Polling 模式下等待时间，单位为秒                                 | 10      |
| servicecomb.kie.firstPullRequired    | 启动的时候第一次查询配置失败，是否终止启动。                                    | true    |
| servicecomb.kie.domainName           | 区域名称                                                      | default |
| servicecomb.kie.refresh_interval     | Pull 模式下刷新配置项的时间间隔，单位为毫秒。                                 | 15000   |
| servicecomb.kie.firstRefreshInterval | Pull 模式下启动过程中首次刷新时间间隔，单位为毫秒。                              | 3000    |
| servicecomb.kie.enableAppConfig      | 是否开启应用配置                                                  | true    |
| servicecomb.kie.enableServiceConfig  | 是否开启服务配置                                                  | true    |
| servicecomb.kie.enableVersionConfig  | 是否开启版本配置                                                  | true    |
| servicecomb.kie.enableVersionConfig  | 是否开启自定义配置                                                 | true    |
| servicecomb.kie.customLabel          | 自定义配置的Label                                               | public  |
| servicecomb.kie.customLabelValue     | 自定义配置的Value                                               | 空       |
