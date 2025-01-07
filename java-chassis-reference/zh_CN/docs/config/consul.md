# 使用 consul

可以通过 [Consul官网](https://developer.hashicorp.com/consul/install?product_intent=consul) 下载和安装 Consul。


## 开发使用
使用Consul需要确保下面的软件包引入：

```xml
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>config-consul</artifactId>
  <version>x.x.x</version>
</dependency>
```

然后在配置文件 applcation.yml 中增加如下配置项：
```yaml
servicecomb:
  config:
    consul:
      enabled: true
      host: localhost
      port: 8500
      acl-token: ''
      watch-seconds: 8
```
* 配置项说明

| 配置项                                             | 默认值         | 是否必选 | 含义                            |
|:--------------------------------------------------|:---------------|:-----|:-----------------------------------|
| servicecomb.config.consul.enabled                 | true           | 是   | 是否启用consul。                   |
| servicecomb.config.consul.host                    | localhost      | 是   | consul的ip                        |
| servicecomb.config.consul.port                    | 8500           | 是   | consul的端口
| servicecomb.config.consul.acl-token               | null           | 否   | 当服务端启用ACL认证后,必须设置该值   |
| servicecomb.config.consul.watch-seconds           | 8              | 是   | 监听配置更新检查频率,在1-9之间，单位秒 |

* 说明
ACL的开启参考注册中心Consul的ACL开启步骤

* 配置中心增加配置

consul 使用下面的配置结构和环境（Environment）、应用（Application）、服务（Service）、版本（Version）、Tag对应， 配置级别优先级从低到高。

```yaml
servicecomb:
  config:
    environment:
      ${environment}:
        exampleText: exampleTextValue
        exampleYaml.yaml: exampleYamlValue
        exampleYaml.yml: exampleYamlValue
        exampleProperties.properties: examplePropertiesValue
    application:
      ${environment}:
        ${application}:
          exampleText: exampleTextValue
          exampleYaml.yaml: exampleYamlValue
          exampleYaml.yml: exampleYamlValue
          exampleProperties.properties: examplePropertiesValue
    service:
      ${environment}:
        ${application}:
          ${service}:
            exampleText: exampleTextValue
            exampleYaml.yaml: exampleYamlValue
            exampleYaml.yml: exampleYamlValue
            exampleProperties.properties: examplePropertiesValue
    version:
      ${environment}:
        ${application}:
          ${service}:
            ${version}:
              exampleText: exampleTextValue
              exampleYaml.yaml: exampleYamlValue
              exampleYaml.yml: exampleYamlValue
              exampleProperties.properties: examplePropertiesValue
    tag:
      ${environment}:
        ${application}:
          ${service}:
            ${version}:
              ${tag}:
                exampleText: exampleTextValue
                exampleYaml.yaml: exampleYamlValue
                exampleYaml.yml: exampleYamlValue
                exampleProperties.properties: examplePropertiesValue
```