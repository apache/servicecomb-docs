# Develop the first microservice
Developers can quickly build a project in two ways:

* Download the samples project. It is recommended to download the entire project, according to the example [SpringMVC] (https://github.com/apache/incubator-servicecomb-java-chassis/tree/master/samples/springmvc-sample) or [JAX RS] (https: //github.com/apache/incubator-servicecomb-java-chassis/tree/master/samples/jaxrs-sample) Initialize the configuration.

* Generate projects using archetypes

Before you start, developers need to choose a familiar development method. There are currently 3 ways to choose:
* Spring MVC
* JaxRS
* RPC

Because transparent RPC acts as a Producer without any RESTful semantics, the automatically generated contracts are all POST methods, and only the BODY parameters are not in line with the usual rules of RESTful.  
Therefore, it is recommended to choose JaxRS or Spring MVC as the Producer development mode, and transparent RPC as the developer development mode.

Their corresponding samples project are:
* [Spring MVC](https://github.com/apache/incubator-servicecomb-java-chassis/tree/master/samples/springmvc-sample)
* [JaxRS](https://github.com/apache/incubator-servicecomb-java-chassis/tree/master/samples/jaxrs-sample)
* [RPC](https://github.com/apache/incubator-servicecomb-java-chassis/tree/master/samples/pojo-sample)
* Or use [archetypes](https://github.com/apache/incubator-servicecomb-java-chassis/tree/master/archetypes)