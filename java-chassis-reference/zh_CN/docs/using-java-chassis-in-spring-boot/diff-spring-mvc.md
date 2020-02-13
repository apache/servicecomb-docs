# 与原生 Spring MVC 开发习惯的差异

java chassis支持使用Spring MVC提供的标签\(org.springframework.web.bind.annotation\)来声明REST接口，但是两者是独立的实现，而且有不一样的设计目标。java chassis的目标是提供跨语言、支持多通信协议的框架，因此去掉了Spring MVC中一些对跨语言支持不是很好的特性，也不支持特定运行框架强相关的特性，比如直接访问Servlet协议定义的HttpServletRequest。java-chassis支持的Spring MVC标签是spring boot的子集， 下面是一些显著的差别。

* 服务声明方式

Spring MVC使用@RestController声明服务，而java chassis使用@RestSchema声明服务，并且需要显示的使用@RequestMapping声明服务路径，以区分该服务是采用Spring MVC的标签还是使用JAX RS的标签。

```
@RestSchema(schemaId = "hello")
@RequestMapping(path = "/")
```

Schema是java chassis的服务契约，是服务运行时的基础，服务治理、编解码等都基于契约进行。在跨语言的场景，契约也定义了不同语言能够同时理解的部分。

* 数据类型支持

采用Spring MVC，可以在服务定义中使用多种数据类型，只要这种数据类型能够被json序列化和反序列化。比如：

```
// 抽象类型
public void postData(@RequestBody Object data)
// 接口定义
public void postData(@RequestBody IPerson interfaceData)
// 没指定类型的泛型
public void postData(@RequestBody Map rawData)
// 具体协议相关的类型
public void postData(HttpServletRequest rquest)
```

java chassis不支持上诉类型。因为java chassis会根据接口定义生成契约，从上面的接口定义，如果不结合实际的实现代码或者额外的开发文档说明，无法直接生成契约。

为了支持快速开发，java chassis的数据类型限制也在不停的扩充，比如支持HttpServletRequest，但是实际在使用的时候，他们与WEB服务器的语义是不一样的，比如不能直接操作流。因此建议开发者在的使用场景下，尽可能使用契约能够描述的类型，让代码阅读性更好。此外，spring针对DispatcherServlet做了大量的扩展，这些扩展对于java-chassis的RestDispatcher是不适用的。

java chassis 在Spring MVC方面的更多开发支持，可以参考[用SpringMVC 开发微服务](../build-provider/springmvc.md)。



