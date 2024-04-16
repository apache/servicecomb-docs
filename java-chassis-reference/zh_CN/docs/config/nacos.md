# 使用 Nacos

## 下载安装

可以通过 [Nacos官网](https://github.com/alibaba/nacos) 下载和安装 Nacos。

## 开发使用

使用Nacos，需要在项目中引入如下依赖：

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

* 配置中心增加配置

  Nacos的namespace对应于Java Chassis Environment, group对应于application。 客户端默认会读取下面几个层次的配置：

    * 应用级配置：group为application名称，data-id为application名称，并且类型为yaml的配置。
    * 服务级配置：group为application名称，data-id为微服务名称，并且类型为yaml的配置。
    * 版本级配置：group为application名称，data-id为微服务名称+版本号，并且类型为yaml的配置， 比如: service-0.1
    * Profile级配置：group为application名称，data-id为微服务名称+Profile名称，并且类型为yaml的配置， 比如: service-dev
    * 自定义配置：可以通过配置项定义group、data-id、类型等信息，详情参考配置项。。

  上述的配置级别，优先级从低到高。

* 配置项参考

| 配置项名                          | 含义                                              | 缺省值    |
|-------------------------------|-------------------------------------------------|--------|
| servicecomb.nacos.serverAddr  | NACOS访问地址，格式为`http(s)://{ip}:{port}`，以`,`分隔多个地址 | 空      |
| servicecomb.nacos.group       | 自定义group                                        | 空      |
| servicecomb.nacos.dataId      | 自定义data-id                                      | 空      |
| servicecomb.nacos.addPrefix   | 是否使用group+data-id作为配置项前缀                        | false  |
| servicecomb.nacos.contentType | 自定义类型                                           | _yaml_ |
| servicecomb.nacos.username    | 连接Nacos的用户名                                     | 空      |
| servicecomb.nacos.password    | 连接Nacos的密码                                      | 空      |
| servicecomb.nacos.accessKey   | 连接Nacos的Access Key                              | 空      |
| servicecomb.nacos.secretKey   | 连接Nacos的Secret Key                              | 空      |
