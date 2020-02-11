# Consumer的通用配置项

* 请求超时  
  * 配置项  
    servicecomb.request.timeout  
  * 默认值  
    30000，单位为毫秒    
  * 含义  
    Consumer传输层开始发送时，开始计时，指定时间内未收到应答，则处理为请求超时    
* 指定传输通道  
  * 配置项  
    servicecomb.references.${目标微服务名}.transport  
    servicecomb.references.transport  
    同时支持全局和微服务级的两级控制
  * 默认值  
    无
  * 含义  
    如果目标微服务同时开放多种transport的访问能力时，而Consumer也同时部署了相应的多个transport，但是作为Consumer调用该微服务时，只想使用其中一种transport，则可以通过本配置项指定transport
    如果不配置，则轮流使用多个transport  
* 指定目标实例的版本规则
  * 配置项  
    servicecomb.references.${目标服务名}.version-rule  
    servicecomb.references.version-rule
    同时支持全局和微服务级的两级控制  
  * 默认值  
    latest
  * 含义  
    目标实例的版本规则，支持以下规则：  
    * 最新版本： latest  
    * 大于指定版本，比如：1.0.0+
    * 指定版本范围，比如：1.0.0-2.0.0，表示大于等于版本1.0.0，并且小于版本2.0.0
    * 精确版本，比如：1.0.0
  
