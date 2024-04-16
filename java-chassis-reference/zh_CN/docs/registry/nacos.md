# 使用 Nacos

可以通过 [Nacos官网](https://github.com/alibaba/nacos) 下载和安装 Nacos。

Nacos的namespace对应于环境Environment， group对应于application， service对应于微服务名称。 

* 表1-1 访问Nacos常用的配置项

| 配置项                                      | 默认值                   | 是否必选 | 含义                     | 
|:-----------------------------------------|:----------------------| :--- |:-----------------------| 
| servicecomb.registry.nacos.enabled       | true                  | 是 | 是否启用。                  |
| servicecomb.registry.nacos.serverAddr    | http://127.0.0.1:8848 | 是 | 服务中心的地址信息，可以配置多个，用逗号分隔。 |
| servicecomb.registry.nacos.metadata      | 空                     | 否 | 配置String的键值对。          |
| servicecomb.registry.nacos.username      | 空                     | 否 | Nacos用户名               |
| servicecomb.registry.nacos.password      | 空                     | 否 | Nacos密码                |
| servicecomb.registry.nacos.accessKey      | 空                     | 否 | Nacos Access Key       |
| servicecomb.registry.nacos.secretKey      | 空                     | 否 | Nacos Secret Key       |
| servicecomb.registry.nacos.clusterName      | DEFAULT                     | 否 | Nacos Cluster Name  |


使用Nacos需要确保下面的软件包引入：

```
  <dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>registry-nacos</artifactId>
  </dependency>
```
