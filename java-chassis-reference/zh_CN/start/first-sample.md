# 开发第一个微服务

开发者可以通过两种方式快速构建一个项目：

* 下载samples项目。建议把整个项目都下载下来，按照例子[ SpringMVC ](https://github.com/apache/incubator-servicecomb-java-chassis/tree/master/samples/springmvc-sample)或者 [JAX RS](https://github.com/apache/incubator-servicecomb-java-chassis/tree/master/samples/jaxrs-sample)进行初始化配置。

* 使用archetypes生成项目

开始之前，开发者需要先选择熟悉的开发方式，目前有3种方式可供选择：
* Spring MVC
* JaxRS
* RPC

因为透明RPC作为Producer时，不带任何RESTful语义，此时自动生成的契约全是POST方法，且只有BODY参数，不太符合RESTful的通常规则  
所以建议选择JaxRS或Spring MVC作为Producer开发模式，透明RPC作为Consumer的开发模式。  

他们对应的samples项目分别是：
* [Spring MVC](https://github.com/apache/incubator-servicecomb-java-chassis/tree/master/samples/springmvc-sample)
* [JaxRS](https://github.com/apache/incubator-servicecomb-java-chassis/tree/master/samples/jaxrs-sample)
* [RPC](https://github.com/apache/incubator-servicecomb-java-chassis/tree/master/samples/pojo-sample)
* 或者使用[archetypes](https://github.com/apache/incubator-servicecomb-java-chassis/tree/master/archetypes)
