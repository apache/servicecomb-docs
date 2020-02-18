# 分布式调用链追踪

分布式调用链追踪用于有效地监控微服务的网络延时并可视化微服务中的数据流转。本指南将展示如何在 *体质指数* 应用中使用 **ServiceComb** 提供的分布式调用链追踪能力。

## 前言

在您进一步阅读之前，请确保您已阅读了[体质指数微服务应用开发](quick-start-bmi.md)，并已成功运行体质指数微服务。

## 启用

* 在 *体质指数计算器* 的 `pom.xml` 文件中添加依赖项：

```xml
   <dependency>
     <groupId>org.apache.servicecomb</groupId>
     <artifactId>handler-tracing-zipkin</artifactId>
   </dependency>
```

* 在 *体质指数计算器* 的 `application.yml` 文件中添加分布式追踪的处理链：

```yaml
servicecomb:
 handler:
   chain:
     Provider:
       default: tracing-provider
```

* 在 *体质指数界面* 的 `pom.xml` 文件中添加依赖项：

```xml
   <dependency>
     <groupId>org.apache.servicecomb</groupId>
     <artifactId>handler-tracing-zipkin</artifactId>
   </dependency>
```

体质指数应用中已配置好了上述配置项，您只需执行以下几步即可：

* 使用 Docker 运行 *Zipkin* 分布式追踪服务：

```bash
docker run -d -p 9411:9411 openzipkin/zipkin
```

* 重启 *体质指数计算器* 微服务：

```bash
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dservicecomb.handler.chain.Provider.default=tracing-provider"
```
   
* 重启 *体质指数界面* 微服务：

```bash
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dservicecomb.handler.chain.Consumer.default=loadbalance,tracing-consumer"
```

## 验证

* 访问 <a>http://localhost:8889</a> ，在身高和体重栏处输入正数，并点击 *Submit* 按钮。

* 访问 <a>http://localhost:9411</a> ，查看分布式调用追踪情况，可得下方界面。

![分布式追踪效果](distributed-tracing-result.png)

