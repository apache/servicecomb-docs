# 与Spring Web MVC开发习惯的差异

Java Chassis支持使用Spring MVC提供的标签 `org.springframework.web.bind.annotation` 来声明REST接口，但是两者是独立的实现，并且有不一样的设计目标。Java Chassis的目标是提供跨语言、支持多通信协议的RESTFul/RPC框架，可以运行于J2EE/JavaEE容器或者普通的HTTP服务器，不依赖于J2EE/JavaEE。而Spring MVC诞生比较早，很多功能都会依赖于J2EE/JavaEE。 Java Chassis整体的应用架构采用后端和前端分离的微服务架构，不会在单独的微服务实现中使用MVC模式。 

相对于Spring MVC， Java Chassis去掉了一些对跨语言支持不是很好的特性，也不支持特定运行框架强相关的特性，比如直接访问 `Servlet` 定义的HttpServletRequest、HttpServletResponse，或者使用HttpAttribute、HttpSession进行会话管理等，也不支持MVC模式一些相关的内容，比如ModelAndView等。

Java Chassis支持的Spring Web MVC标签是Spring Boot的子集， 下面是一些显著的差别。

* 服务声明方式

Spring MVC使用 `@RestController` 声明服务，而Java Chassis使用 `@RestSchema` 声明服务，并且需要显示的使用 `@RequestMapping` 声明服务路径，以区分该服务是采用Spring Web MVC的标签还是使用JAX RS的标签。

```
@RestSchema(schemaId = "hello")
@RequestMapping(path = "/")
```

Schema是java chassis的服务契约，是服务运行时的基础，服务治理、编解码等都基于契约进行。在跨语言的场景，契约也定义了不同语言能够同时理解的部分。

* 数据类型支持

采用Spring Web MVC，可以在服务定义中使用多种数据类型，只要这种数据类型能够被Json序列化和反序列化。比如：

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

这些使用方式，无法确定接口的详细 RestFul 语义和输入输出格式，Java Chassis强调一个核心的原则：接口的输入输出在接口定义的时候就已经确定好，并且可以通过生成的 Open API 来显示的表达。因此不建议在接口声明的时候，采用接口、泛型、抽象类型等。

>>> 说明： 为了支持快速开发，Java Chassis的数据类型限制也在不停的扩充，比如支持HttpServletRequest，但是实际在使用的时候，他们与WEB服务器的语义是不一样的，比如不能直接操作流。因此建议开发者在的使用场景下，尽可能使用契约能够描述的类型，让代码阅读性更好。此外，Spring针对DispatcherServlet做了大量的扩展，这些扩展对于Java Chassis是不适用的。

Java Chassis在Spring Web MVC方面的更多开发支持，可以参考[用SpringMVC 开发微服务](../build-provider/springmvc.md)。



