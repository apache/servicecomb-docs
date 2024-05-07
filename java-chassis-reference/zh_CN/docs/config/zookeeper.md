# 使用 Zookeeper

## 下载安装

可以通过 [ZooKeeper官网](https://zookeeper.apache.org/index.html) 下载和安装 ZooKeeper。

## 开发使用

使用ZooKeeper，需要在项目中引入如下依赖：

```xml
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>config-zookeeper</artifactId>
</dependency>
```

然后在配置文件 microservice.yaml 中增加如下配置项：

```yaml
servicecomb:
  config:
    zk:
      connectString: 127.0.0.1:2181
```

* 配置中心增加配置

ZooKeeper 使用下面的配置结构和环境（Environment）、应用（Application）、服务（Service）、版本（Version）、Tag对应， 配置级别优先级从低到高。 

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
| servicecomb.config.zk.connect-string          | 127.0.0.1:2181 | 是    | ZooKeeper的地址信息，可以配置多个，用逗号分隔。                  |
| servicecomb.config.zk.authenticationSchema    | 空              | 否    | 认证方式，目前只能配置为 digest。                          |
| servicecomb.config.zk.authenticationInfo      | 空              | 否    | 当认证方式为 digest 的时候，配置用户名密码信息，比如: user:password |
| servicecomb.config.zk.connectionTimeoutMillis | 1000           | 否    | 连接超时时间                                        |
| servicecomb.config.zk.sessionTimeoutMillis    | 60000          | 否    | 会话超时时间                                        |
| servicecomb.config.zk.instance-tag            | 空              | 否    | 实例的TAG信息，用于TAG级别的配置查询                         |
