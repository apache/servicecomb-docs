# 基于动态配置的流量特征治理

基于动态配置的流量特征治理旨在提供一种通用的，适合不同语言、不同微服务开发框架的治理规则。治理规则规定了微服务治理的过程、治理的策略，
可以使用不同的开发框架、技术实现治理规则约定的治理能力。

开发者可以在 [ServiceComb Java Chassis][java-chassis], [Go Chassis][go-chassis],[Spring Cloud][spring-cloud],
[Dubbo][dubbo] 中使用该功能。

[ServiceComb Java Chassis][java-chassis] 提供了实现 SDK，可以将其用于其他开发框架。SDK 默认采用 [Resilience4j][resilience4j]
实现治理过程。规范没有约束治理过程的实现框架，可以很方便的使用其他的治理框架实现治理过程。 

基于动态配置的流量特征治理详细概念和开发指南请参考[微服务引擎开发指南](https://support.huaweicloud.com/devg-cse/cse_devg_0026.html)