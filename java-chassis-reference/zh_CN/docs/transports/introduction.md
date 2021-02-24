# 多协议介绍

Java Chassis提出了一些创新的概念，提供方便、简洁的多协议通信开发。首先是编程模型和通信模型的分离。编程模型指用户写代码的
方式，Java Chassis非常灵活的编程模型: 

* Provider编程模型：JAX-RS、SpringMVC、透明RPC
* Consumer编程模型：透明RPC、RestTemplate、InvokerUtils

开发者可以在项目中自由组合Provider和Consumer的编程模型，即存在 3 * 3 种开发组合，最推荐的开发组合Provider采用JAX-RS，
Consumer采用透明RPC；熟悉Spring的用户组合SpringMVC和透明RPC。 

编程模型和我们通常所说的多协议支持没有关系。 多协议支持一般指的是对象如何编码，比如采用Json还是采用protobuffer；通信协议
采用什么，比如采用HTTP还是采用私有TCP协议。 对象编码方式和通信协议的组合，称为通信模型。 Java Chassis的通信模型可以分成
两类：REST 和 Highway。 

* REST： 对象编码采用Json，支持接口参数与HTTP的Path， Header、Body的映射关系定义。通信协议采用HTTP协议族，比如HTTP、
  HTTPS、HTTP2（H2和H2C）。 
* Highway： 对象编码采用protobuffer。通信协议采用Java Chassis自定义的私有TCP协议。 

Java Chassis的编程模型和通信模型分离，意味着业务代码开发的时候，不需要关注通信模型，可以在不修改业务代码的情况下，
修改通信模型配置，切换为新的通信模型。 
