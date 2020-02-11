## [负载均衡策略](/build-provider/configuration/lb-strategy.html)
• ServiceComb提供了基于Ribbon的负载均衡方案，用户可以通过配置文件配置负载均衡策略，当前支持随机、顺序、基于响应时间的权值等多种负载均衡路由策略## [Service Center](https://github.com/apache/incubator-servicecomb-saga){:target="_blank"}  

## [限流策略](/build-provider/configuration/ratelimite-strategy.html) 
• 用户在provider端使用限流策略，可以限制指定微服务向其发送请求的频率，达到限制每秒钟最大请求数量的效果。  


## [降级策略](/build-provider/configuration/parameter-validator.html)  
• 降级策略是当服务请求异常时，微服务所采用的异常处理策略。


## [参数效验](/build-provider/configuration/parameter-validator.html)
• 用户在provider端使用参数效验，可以对相应的参数输入要求预先进行设置，在接口实际调用前进行效验处理，达到控制参数输入标准的效果。
