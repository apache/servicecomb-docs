# 开发第一个微服务

开始之前，开发者需要选择熟悉的开发方式，目前有3种方式可供选择：
* Spring MVC
* JaxRS
* POJO

Spring MVC和JaxRS适合REST接口开发。 POJO是通常说的RPC，适合于进行内部接口开发。java-chassis允许在一个微服务里面混合使用上述开发方式，并且可以使用完全一致的方式，比如RestTemplate或者POJO的方式访问不同类型的服务，所以开始之前，可以根据熟悉程度，选择任意一种开发方式即可。java-chassis的开发方式和通信方式是完全解耦的，因此不同的开发方式并没有性能上的差异。

开发者可以通过如下方式快速构建一个项目：

* 下载samples项目。java-chassis提供了大量的示例代码，这些示例代码可以通过[servicecomb-samples](https://github.com/apache/servicecomb-samples)获取。

  * [Spring MVC例子](https://github.com/apache/servicecomb-samples/tree/master/java-chassis-samples/springmvc-sample)
  * [JaxRS例子](https://github.com/apache/servicecomb-samples/tree/master/java-chassis-samples/jaxrs-sample)
  * [POJO例子](https://github.com/apache/servicecomb-samples/tree/master/java-chassis-samples/pojo-sample)

* 使用archetypes生成项目

  archetypes是maven提供的一种机制，对于使用maven的用户，可以在项目里面配置插件，生成项目。java-chassis提供了多个archetypes供开发者使用，详细参考[链接](https://github.com/apache/servicecomb-java-chassis/tree/master/archetypes)

* 使用脚手架生成项目

  脚手架提供了一个图形化向导，通过向导可以快速构建项目，参考[链接](http://start.servicecomb.io/)。