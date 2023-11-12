# 多协议介绍

Java Chassis提出编程模型和通信模型分离的创新概念，提供方便、简洁的多协议通信开发。编程模型指用户写代码的方式，Java Chassis非常灵活的编程模型: 

* Provider编程模型：JAX-RS、Spring Web MVC、透明RPC
* Consumer编程模型：透明RPC、RestOperations、InvokerUtils

开发者可以在项目中自由组合Provider和Consumer的编程模型，即存在 3 * 3 种开发组合，最推荐的开发组合Provider采用JAX-RS，Consumer采用透明RPC；熟悉Spring Web MVC的用户采用Spring Web MVC和透明RPC。 

编程模型和我们通常所说的多协议支持没有关系。 多协议支持一般指的是对象如何编码，比如采用Json还是采用proto-buffer, 以及通信协议采用什么，比如采用HTTP还是采用私有TCP协议。 对象编码方式和通信协议的组合，称为通信模型。 Java Chassis的通信模型可以分成两类：REST 和 Highway。 

* REST： 支持接口参数与HTTPQuery、Path、Header、Body的映射关系。对象编码支持Jason、proto-buffer、text等，通过Content-Type进行区分。通信协议采用HTTP协议族，比如HTTP、HTTPS、HTTP2（H2和H2C）。 
* Highway： 对象编码支持proto-buffer。通信协议采用Java Chassis自定义的私有TCP协议。 

Java Chassis的编程模型和通信模型分离，意味着业务代码开发的时候，不需要关注通信模型，可以在不修改业务代码的情况下， 修改通信模型配置，切换为新的通信模型。 

## 如何选择协议

在多数场景，建议使用REST协议，编码使用Json。 Java Chassis对REST协议进行了很好的优化，能够满足绝大多数应用场景的需要。REST协议和Json编码具备更好的跨平台特性，能够支持不同系统直接对接，HTTP协议在应对大规模并发场景，提供了非常好的健壮性。在兼容性方面，REST协议和Json编码能够更好的支持业务平滑升级，当业务接口存在变化（接口参数个数、参数顺序、Model增减字段等场景）的大部分常见情况，客户端未升级能够成功调用服务端，这样给服务端和客户端独立升级带来很多方便。

采用proto-buffer编码，序列化更快，数据量更小，能够提供更高的吞吐量。 但是proto-buffer业务接口存在变化的情况，如果客户端未升级，服务端先升级，可能导致客户端调用失败。在客户端使用的接口和服务端不存在编译时依赖的场景下，这种问题会难于发现。

采用Highway协议，在涉及系统集成的时候，会碰到麻烦。

总结起来，多数情况建议使用REST协议。在少量需要高性能、并且功能相对稳定，不怎么变化的场景，使用proto-buffer或者使用Highway协议提升系统吞吐量和降低时延。 
