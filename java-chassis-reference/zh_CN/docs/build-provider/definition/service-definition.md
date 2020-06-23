# 微服务定义

servicecomb 微服务定义包括两个基础模型 `Microservice` 和 `MicroserviceInstance`。 这些信息定义了
微服务标识，从属于哪个应用，以及名字和版本。

* 微服务信息

  servicecomb 的微服务信息在类 `Microservice` 中定义。 它主要包含应用 ID (appId)， 微服务名称 (serviceName),
  微服务版本(version)，环境(environment) 等信息。 

* 实例信息

  servicecomb 的实例信息在类 `MicroserviceInstance` 中定义。 它主要包含网络地址(endpoints) 信息。

# 场景描述

开发一个微服务，需要在 `microservice.yaml` 文件中配置微服务的基本信息。 如果使用 spring boot，也可以在
`application.yml` 文件中配置微服务的基本信息。 

`microservice.yaml` 文件在项目中的存放路径为 `src\main\resources\microservice.yaml`。

表1-1配置项说明

| 配置项 | 默认值 | 取值范围 | 是否必选 | 含义 | 注意 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| APPLICATION\_ID | - | - | 是 | 应用名 | - |
| service\_description.name | - | - | 是 | 微服务名 | 应确保app内部唯一。微服务名支持数字、大小写字母和"-"、"\_"、"."三个特殊字符，但是不能以特殊字符作为首尾字符，命名规范为：^\[a-zA-Z0-9\]+$&#124;^\[a-zA-Z0-9\]\[a-zA-Z0-9\_-.\]\*\[a-zA-Z0-9\]$。 |
| service\_description.version | - | - | 是 | 微服务版本号 | - |
| service\_description.description | - | - | 否 | 微服务描述 |  |
| service\_description.properties | - | - | 否 | 微服务元数据配置（通过microservice.yaml文件进行配置） | - |
| service\_description.propertyExtendedClass | - | - | 否 | 微服务元数据配置（通过实现接口PropertyExtended进行配置） | 接口返回的配置会覆盖配置文件中key相同的配置。 |
| instance\_description.properties | - | - | 否 | 服务实例元数据配置（通过microservice.yaml文件进行配置） |  |
| instance\_description.propertyExtendedClass | - | - | 否 | 微服务元数据配置（通过实现接口PropertyExtended进行配置） | 同service\_description.propertyExtendedClass |

> 说明：
>
> * 服务的元数据会随服务一同注册到服务中心，如需修改，则要连同服务version一起变更。若想保持服务version不变，则需要通过服务管理中心统一变更元数据。
> * 虽然微服务名、契约名中可以使用"."字符，但是不推荐在命名中使用"."。这是由于ServiceComb使用的配置文件是yaml格式的，"."符号用于分割配置项名称，如果微服务名、契约名中也包含了"."可能会导致一些支持微服务、契约级别的配置无法正确被识别。

下面是一个微服务信息的配置示例：

```yaml
APPLICATION_ID: helloTest # 应用名
service_description: # 服务描述
  name: helloServer # 微服务名称
  version: 0.0.1 # 服务版本号
  properties: # 元数据
    key1: value1
    key2: value2
  description: This is a description about the microservice # 微服务描述
  propertyExtentedClass: org.apache.servicecomb.serviceregistry.MicroServicePropertyExtendedStub
instance_description: #实例描述
  properties: #元数据
    key3: value3
  propertyExtentedClass: org.apache.servicecomb.serviceregistry.MicroServicePropertyExtendedStub
```

