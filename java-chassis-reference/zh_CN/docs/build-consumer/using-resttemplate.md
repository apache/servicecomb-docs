# Restful风格 - 使用 RestOperations

## 概念阐述

RestOperations是Spring提供的RESTful访问接口，ServiceComb提供该接口的实现类用于服务的调用。

## 场景描述

用户使用ServiceComb提供的RestOperations实例，可以使用自定义的URL进行服务调用，而不用关心服务的具体地址。

## 示例代码

RestOperations实例通过调用`RestTemplateBuilder.create()`方法获取，再使用该实例通过自定义的URL进行服务调用，代码如下：

* Spring MVC 客户端示例代码：

```java
public class SpringmvcConsumerExample {
    private static RestOperations restTemplate = RestTemplateBuilder.create();

    public static void test() throws Exception {
        Person person = new Person();
        person.setName("ServiceComb/Java Chassis");
        String sayHiResult = restTemplate
                .postForObject("servicecomb://springmvc/springmvchello/sayhi?name=Java Chassis", null, String.class);
        String sayHelloResult = restTemplate
                .postForObject("servicecomb://springmvc/springmvchello/sayhello", person, String.class);
        System.out.println("RestTemplate consumer sayhi services: " + sayHiResult);
        System.out.println("RestTemplate consumer sayhello services: " + sayHelloResult);
    }
}
```

* JAX RS 客户端示例代码：

```java
public class JaxrsConsumerMain {
    public static void test() throws Exception {
        //其他都类似spring MVC示例的客户端代码，注意如果服务端只接收 GET 请求，要使用方法 getForObject()
        RestTemplate restTemplate = RestTemplateBuilder.create();
        String result = restTemplate.getForObject("servicecomb://jaxrs/jaxrshello/saybye", String.class);
    }
}
```

> 说明：
>
> * URL格式为：`servicecomb://microserviceName/path?querystring`。以[用SpringMVC开发微服务](../build-provider/springmvc.md)中定义的服务提供者为例，其微服务名称是`springmvc`，basePath是`/springmvchello`，那么URL中的microserviceName=`springmvc`，请求sayhi时的path=`springmvchello/sayhi`，所以示例代码中请求sayhi的URL是`servicecomb://springmvc/springmvchello/sayhi?name=Java Chassis`。具体代码示例如下 ：


```java
@RestSchema(schemaId = "springmvcHello")
@RequestMapping(path = "/springmvchello", produces = MediaType.APPLICATION_JSON)
//这里 path = “/springmvchello” 中的 springmvchello 就是 上述的basePath
public class SpringmvcHelloImpl implements Hello {
    @Override
    @RequestMapping(path = "/sayhi", method = RequestMethod.POST)
    public String sayHi(@RequestParam(name = "name") String name) {
        return "Hello " + name;
    }

    @Override
    @RequestMapping(path = "/sayhello", method = RequestMethod.POST)
    public String sayHello(@RequestBody Person person) {
        return "Hello person " + person.getName();
    }
}
```
