# 3.x.x 版本介绍

相对于2.x.x版本，3.x.x版本在业务连续性、开发易用性、性能可靠性等方面做了大量工作。主要包括：

* 支持 JDK 17 和 Spring Boot 3。 3.x.x完全使用JDK 17进行编译，并根据JDK 17的新特性，重构了部分代码，调整了配套的三方软件选型，使得代码更加简洁，运行更加高效。3.x.x在底层依赖上面，彻底拥抱 Spring Boot 3，并依赖于Spring Boot特性，重构了处理链（Filter）、注册（Registration）、发现(Discovery)、配置（DynamicPropertiesSource)、负载均衡（DiscoveryTree、DiscoveryFilter)等核心组件，以支持更加丰富应用开发生态，简化扩展实现的难度。
* 支持OpenAPI 3.0.x。 3.x.x更新升级了OpenAPI 3.0.x，并在此基础上，提供了 Content-Type 为 application/protobuf， application/text等支持。这样可以在HTTP/HTTP2等协议基础之上，提供更多的序列化协议支持，以提升序列化的性能。 
* 使用新的处理链机制（Filter）取代旧的处理链机制(Handler)，以提供更好的异步处理支持。统一了Handler/HttServerFilter/HttpClientFilter等机制，都使用Filter来表达。 将Handler的配置文件编排，修改为Spring Boot的依赖注入，简化用户开发和使用Filter。 
* 简化了注册发现（Discovery、Registration）接口，使得开发者能够更加简单的适配不同的注册中心，提供了本地注册（Local）、广播（zero-config）、ServiceComb 注册中心（SC)、Nacos注册中心等默认实现。 
* 提供了全新的实例管理和负载均衡机制，以保证注册中心网络分区故障等场景下的可靠性。该机制能够在注册中心不同的故障场景下保障微服务自身运行的可靠性，降低了注册中心可靠性对于应用本身运行可靠性的影响，为选择不同的注册中心实现提供了更多的可能性。 
* 简化了配置（DynamicPropertiesSource)接口，更好的支持Spring Boot的Environment和PropertySource等机制。做到和Spring Boot配置机制完全融合。同时保留了DynamicProperties、PriorityPropertyManager等配置机制，弥补Spring Boot配置使用在变更事件监听、优先级配置等方面的不足。 提供了ServiceComb配置中心（Kie)、nacos配置中心、Apollo配置中心等默认实现。
* 移除了影响业务连续性的组件，并提供了替代方案。包括Hystrix、Archaius、Commons Configuration、Log4j等模块。 

