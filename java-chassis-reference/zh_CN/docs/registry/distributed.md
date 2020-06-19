# 去中心化注册发现

去中心化注册发现指不通过服务中心中间件，实现服务注册发现。去中心化注册发现比较适合于小规模管理面服务的开发，或者
对于弹性扩缩容要求不高的场景。 servicecomb 提供了两种方式满足去中心化的注册发现。这两种方式涉及如下模块：

* 本地注册发现: registry-local，通过本地配置文件注册发现
* 组播注册发现: registry-zeroconfig, 采用组播的方式注册发现
* 实例契约发现: registry-schema-dicovery, 通过给实例发送请求，从实例查询契约

## 本地注册发现 + 实例契约发现

通过组合本地注册发现和实例契约发现能够实现去中心化注册发现。这种场景需要 consumer 配置 provider 的地址信息，
适合 provider 地址固定的场景。 或者在容器部署的场景（比如 Istio）， consumer 可以通过固定的服务名访问 provider,
采用这种注册发现方式能够很好利用容器的发现能力。

通过组合本地注册发现和实例契约发现包含下面几个开发步骤：

* 引入相关依赖

        ```xml
            <dependency>
              <groupId>org.apache.servicecomb</groupId>
              <artifactId>registry-schema-discovery</artifactId>
            </dependency>
        ```

  备注： registry-schema-discovery 依赖于 registry-local
  
* 在 consumer 的 `registry.yaml` 中配置 provider 的微服务和微服务实例信息

```yaml
demo-zeroconfig-schemadiscovery-registry-edge:
  - id: "002"
    version: "0.0.2"
    appid: demo-zeroconfig-schemadiscovery-registry
    schemaIds:
      - ClientServerEndpoint
      - SchemaDiscoveryEndpoint
    instances:
      - endpoints:
          - rest://localhost:8888
```

## 组播注册发现 + 实例契约发现

组播注册发现采用UDP协议发现实例。使用这种方式只需要在项目中配置依赖：

```xml
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>registry-schema-discovery</artifactId>
    </dependency>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>registry-zero-config</artifactId>
    </dependency>
```

可以看出使用这种方式非常简单，也是 zero-config 名称的由来。 

## 注意事项

使用去中心化注册发现，一般会去掉集中注册发现模块的依赖。 如果没去掉依赖，就会存在多种注册发现并存的情况。这种
情况的行为可以参考注册发现概述的内容。
