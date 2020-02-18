# 负载均衡

当对体质指数计算器进行水平扩展时，需要将请求均衡地分发到多个体质指数计算器上。本指南将展示如何在 *体质指数* 应用中使用 **ServiceComb** 提供的负载均衡能力。

## 前言

在您进一步阅读之前，请确保您已阅读了[体质指数微服务应用开发](quick-start-bmi.md)，并已成功运行体质指数微服务。

## 开启

默认情况下会使用内置的一个简单的负载均衡的实现，不需要额外的配置。

## 验证

对 *体质指数计算器* 微服务进行水平扩展，使其运行实例数为2，即新增一个运行实例：

```bash
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dserver.port=7779 -Dservicecomb.rest.address=0.0.0.0:7779"
```

为了便于区分不同的运行实例，在体质指数计算器的实现中新增了返回实例ID和运行时间的接口，详情可查看[体质指数计算器的完整实现代码](https://github.com/apache/servicecomb-java-chassis/tree/master/samples/bmi/calculator)。而为了避免端口冲突，新的实例在另一个端口上运行。

此时点击 *Submit* 按钮就可以看到如下两个界面中的实例ID交替出现。

![负载均衡效果](load-balance-result.png)
