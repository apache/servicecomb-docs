# 使用 etcd

## 下载安装

可以通过 [Etcd官网](https://etcd.io/docs/v3.5/install/) 下载和安装 Etcd。

## 开发使用

使用etcd，需要在项目中引入如下依赖：

```xml
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>config-etcd</artifactId>
  <version>x.x.x</version>
</dependency>
```

然后在配置文件 microservice.yaml 中增加如下配置项：

```yaml
servicecomb:
  config:
    etcd:
      connectString: http://127.0.0.1:2379
```

* 配置中心增加配置

etcd 使用下面的配置结构和环境（Environment）、应用（Application）、服务（Service）、版本（Version）、Tag对应， 配置级别优先级从低到高。 

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

配置文件的类型根据KEY的后缀确定。目前会解析 `.yaml`、`.yml`、`.properties`后缀，其他情况钧视为普通的key-value对。

* 配置项参考

| 配置项名                                          | 默认值            | 是否必须 | 含义                                            | 
|-----------------------------------------------|----------------|------|-----------------------------------------------|
| servicecomb.config.etcd.connect-string          | http://127.0.0.1:2379 | 是    | etcd的地址信息，可以配置多个，用逗号分隔。                  |
| servicecomb.config.etcd.authenticationInfo      | 空              | 否    | 当认证方式为 digest 的时候，配置用户名密码信息，比如: user:password |
| servicecomb.config.etcd.instance-tag            | 空              | 否    | 实例的TAG信息，用于TAG级别的配置查询                         |
