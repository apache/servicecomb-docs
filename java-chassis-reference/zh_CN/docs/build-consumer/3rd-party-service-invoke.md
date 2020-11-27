# 调用第三方服务

## 概念阐述

第三方服务没有在服务中心注册，不存契约信息，Java Chassis 提供一种透明的方式访问第三方服务。 
使用该功能调用第三方服务时，发往第三方服务的请求会经过consumer端handler链、HttpClientFilter的处理，
即该功能支持对第三方服务调用的治理功能，并且也支持ServiceComb既有的用户自定义扩展处理机制。 

另外开发者也可以使用 [本地注册发现](../registry/local-registry.md) 实现第三方调用， 两种方式实现的效果是一致的。 

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

3. 通过实现 `ThirdServiceWithInvokerRegister` 注册第三方服务信息。 可以注册多个 schema。 

        ```java
        @Configuration
        public class ThirdSvc extends ThirdServiceWithInvokerRegister {
          public ThirdSvc() {
            super("3rd-svc");
        
            addSchema("schema-1", VertxServerIntf.class);
          }
        }
        ```

    ***注意：*** java chassis 2.1.3 以上版本才支持 ThirdServiceWithInvokerRegister。 

4. 调用第三方服务，声明和调用方式与调用ServiceComb provider服务相同，此处以RPC调用方式为例。

        ```java
        VertxServerIntf client = BeanUtils.getContext().getBean(VertxServerIntf.class);
        client.testPathVar(pathVar);
        ```

5. 使用治理功能。使用治理功能的方法与普通的consumer调用provider场景类似。以限流策略为例，在consumer
  服务的microservice.yaml文件中进行如下配置:

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

6. 配置第三分服务的实例信息

        3rd-svc:
          urls:
            - http://localhost:8080
