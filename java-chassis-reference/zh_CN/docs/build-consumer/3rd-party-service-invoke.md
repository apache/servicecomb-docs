# 调用第三方服务

## 概念阐述

ServiceComb允许用户注册第三方REST服务的endpoint、接口契约等信息，使用户可以以调用ServiceComb provider服务相同的方式编写调用第三方服务的代码。
使用该功能调用第三方服务时，发往第三方服务的请求会经过consumer端handler链、HttpClientFilter的处理，
即该功能支持对第三方服务调用的治理功能，并且也支持ServiceComb既有的用户自定义扩展处理机制。

## 示例代码

1. 假设用户在本地开发了一个REST服务作为第三方REST服务，监听端口号为8080，其REST接口如契约所示：

        ```yaml
        ---
        swagger: "2.0"
        info:
        version: "0.0.1"
        title: "3rd party REST service for example"
        basePath: "/rest"
        consumes:
        - "application/json"
        produces:
        - "text/plain"
        paths:
        /{pathVar}:
          get:
            operationId: "testPathVar"
            parameters:
            - name: "pathVar"
              in: "path"
              required: true
              type: "string"
            responses:
              200:
                description: "response of 200, return \"Received, OK. [${pathVar}]\""
                schema:
                  type: "string"
        ```

2. 为调用此服务，需要先根据其REST接口编写一个Java接口类，并打上参数注解。
    Java接口类的编写方式参照使用隐式契约开发SpringMVC和JAX-RS风格的provider方式。
    接口代码示例如下：

        ```java
        @Path("/rest")
        @Api(produces = MediaType.TEXT_PLAIN)
        public interface VertxServerIntf {
        @Path("/{pathVar}")
        @GET
        String testPathVar(@PathParam("pathVar") String pathVar);
        }
        ```

3. 在consumer服务中调用ServiceComb提供的方法将其进行注册：

        ```java
        String endpoint = "rest://127.0.0.1:8080";
        RegistryUtils.getServiceRegistry().registerMicroserviceMappingByEndpoints(
          // 3rd party rest service name, you can specify the name on your need as long as you obey the microservice naming rule
          "thirdPartyService",
          // service version
          "0.0.1",
          // list of endpoints
          Collections.singletonList(endpoint),
          // java interface class to generate swagger schema
          ThirdPartyRestServiceInterface.class
        );
        ```

4. 调用第三方服务，声明和调用方式与调用ServiceComb provider服务相同，此处以RPC调用方式为例。

        ```java
        // declare rpc reference to 3rd party rest service, schemaId is the same as microservice name
        @RpcReference(microserviceName = "thirdPartyService", schemaId = "thirdPartyService")
        ThirdPartyRestServiceInterface thirdPartyRestService;
        
        @RequestMapping(path = "/{pathVar}", method = RequestMethod.GET)
        public String testInvoke(@PathVariable(name = "pathVar") String pathVar) {
        LOGGER.info("testInvoke() is called, pathVar = [{}]", pathVar);
        // invoke 3rd party rest service
        String response = thirdPartyRestService.testPathVar(pathVar);
        LOGGER.info("testInvoke() response = [{}]", response);
        return response;
        }
        ```

5. 使用治理功能。使用治理功能的方法与普通的consumer调用provider场景类似。以限流策略为例，在consumer服务的microservice.yaml文件中进行如下配置:

        ```yaml
        servicecomb:
          flowcontrol:
            Consumer:
              qps:
                enabled: true
                limit:
                  thirdPartyService: 1
        ```
        
    此时即将consumer调用名为`thirdPartyService`的第三方REST服务的QPS设置为1。当consumer调用`thirdPartyService`的流量高于1QPS时，
    将会得到`429 Too Many Requests`的`InvocationException`异常。

> ***注意：***
- endpoint信息是以`rest`开头的，而非`http`，可以参照ServiceComb微服务注册到服务中心的endpoint样式进行编写。
- 当第三方服务有多个实例（地址）时，可以在endpoint list中指定多个地址，ServiceComb支持对多个地址进行负载均衡处理，处理方式和对待ServiceComb
 provider服务相同。
- 当前仅支持一次性注册第三方服务及其实例信息，不支持增加、删除和修改操作。

