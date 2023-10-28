# 微服务定义

Java Chassis定义了一组基础的概念，这些概念会用于微服务注册发现、服务治理等多种场景。专题文章[微服务实例间多环境隔离](../../general-development/multienvironment.md)介绍了一些常见应用场景。

Java Chassis最核心的几个概念如下。

* 环境名称：用于表示部署环境，不同环境的微服务之间不能进行服务发现。对于不同的注册中心和配置中心，会以对应的概念表示环境。比如Nacos使用 `namespace` 来表示环境。
* 应用名称：用于描述一组可以相互访问的微服务，不同应用名称之间是逻辑隔离的，不能进行服务发现。对于不同的注册中心和配置中心，会以对应的概念表示应用。比如Nacos使用 `group` 来表示应用。 
* 微服务名称：用于标识一个微服务。可以通过微服务名称查询需要访问的目标微服务。
* 微服务版本：表示微服务的版本。当存在微服务属性变化、接口变化的场景，建议修改版本号。
* 微服务描述：简单的微服务描述信息。
* 微服务属性：用于描述微服务的扩展信息。

开发一个微服务，需要在 `application.yaml` 文件中配置微服务的基本信息。

```yaml
servicecomb:
  service:
    application: helloTest
    name: helloServer 
    version: 0.0.1 
    properties: 
      key1: value1
      key2: value2
    description: This is a description about the microservice
```

## 配置项参考

| 配置项 | 默认值 | 是否必选 | 含义                                                                                                                                              |
| :--- | :--- | :--- |:------------------------------------------------------------------------------------------------------------------------------------------------|
| servicecomb.service.environment | - | 否 | 环境名称，比如 development, production 等                                                                                                               |
| servicecomb.service.application | default | 是 | 应用名称                                                                                                                                            |
| servicecomb.service.name | defaultMicroservice | 是 | 微服务名称, 应确保应用内部唯一。微服务名支持数字、大小写字母和"-"、"\_"、"."三个特殊字符，但是不能以特殊字符作为首尾字符，命名规范为：^\[a-zA-Z0-9\]+$&#124;^\[a-zA-Z0-9\]\[a-zA-Z0-9\_-.\]\*\[a-zA-Z0-9\]$。 |
| servicecomb.service.version | 1.0.0.0 | 是 | 微服务版本                                                                                                                                           |
| servicecomb.service.description |  - | 否 | 微服务描述                                                                                                                                           |
| servicecomb.service.properties |  - | 否 | 微服务属性                                                                                                                                           |

> 说明：
>
> * 微服务属性会随服务一同注册到服务中心。如果存在变更，建议同时修改微服务版本号。
> * 虽然微服务名称可以使用 `.` 字符，但是不推荐在命名中使用 `.` 。这是由于yaml格式的配置文件将 `.` 符号用于分割配置项名称，
     如果微服务名称包含了 `.` 可能会导致一些支持微服务、契约级别的配置无法正确被识别。


