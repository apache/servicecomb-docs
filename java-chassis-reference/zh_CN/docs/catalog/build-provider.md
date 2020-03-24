## [服务定义](/build-provider/definition/service-definition.html)
• 服务定义信息是微服务的身份标识，它定义了服务从属于哪个应用，以及名字和版本。服务定义信息中也可以有扩展信息，用于定义服务的属性元数据。
 

## [定义服务契约](/build-provider/define-contract.html) 
• 服务契约，指基于OpenAPI规范的微服务接口契约，是服务端与消费端对于接口的定义。java chassis提供了两种方式定义契约：code first和contract first。


## [使用隐式契约](/build-provider/code-first.html)  
• 降级策略是当服务请求异常时，微服务所采用的异常处理策略。


## [使用 Swagger 注解](/build-provider/swagger-annotation.html)
• Swagger提供了一套注解用于描述接口契约，用户使用注解，可以在代码中增加对于契约的描述信息。ServiceComb支持其中的部分注解。


## [用SpringMVC 开发微服务](/build-provider/springmvc.html)
• ServiceComb支持SpringMVC注解，允许使用SpringMVC风格开发微服务。建议参照着项目 SpringMVC进行详细阅读。

## [用JAX-RS开发微服务](/build-provider/jaxrs.html)
• ServiceComb支持开发者使用JAX-RS注解，使用JAX-RS模式开发服务。

## [用透明RPC开发微服务](/build-provider/transparent-rpc.html)
• 透明RPC开发模式是一种基于接口和接口实现的开发模式，服务的开发者不需要使用Spring MVC和JAX-RS注解。

## [接口定义和数据类型](/build-provider/swagger-annotation.html)
• ServiceComb-Java-Chassis建议接口定义遵循一个简单的原则：接口定义即接口使用说明，不用通过查看代码实现，就能识别如何调用这个接口。可以看出，这个原则站在使用者这边，以更容易被使用作为参考。ServiceComb会根据接口定义生成接口契约，符合这个原则的接口，生成的契约也是用户容易阅读的。

## [服务监听地址和发布地址](/build-provider/listen-address-and-publish-address.html)
•在JavaChassis中，服务的监听地址和发布地址是两个独立的概念，可以独立配置：

	监听地址：指微服务实例启动时监听的地址。该配置项决定了可以通过哪些IP访问此服务。
	发布地址：指微服务实例注册到服务中心的地址。其他的微服务实例会通过服务中心获取此实例的信息，根据发布地址访问此服务实例，所以该配置项决定了其他服务实际上会使用哪个IP访问此服务。

## [服务配置](/build-provider/service-configuration.html)

• [负载均衡策略](/build-provider/configuration/lb-strategy.html)  
• [限流策略](/build-provider/configuration/ratelimite-strategy.html)  
• [参数教研](/build-provider/configuration/parameter-validator.html)  

