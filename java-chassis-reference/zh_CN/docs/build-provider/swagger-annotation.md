# 使用 Swagger 注解

采用 Spring MVC 或者 JAX RS 注解已经能够描述RestFul/RPC运行时需要的契约信息，但是仍然不足以描述所有契约信息，比如描述、扩展等。可以混合使用 Swagger 注解，进一步补充契约信息，使得契约信息更加完整。当 Spring MVC 或者 JAR RS 注解描述的信息与 Swagger 注解描述的信息重复时，以 Swagger 注解描述的信息为准，即 Swagger 注解具有更高的优先级。

关于Swagger注解的含义，可以在 [Swagger注解文档](https://github.com/swagger-api/swagger-core/wiki/Swagger-2.X---Annotations) 中找到官方说明。

## 常用例子

* @OpenAPIDefinition

`@OpenAPIDefinition`可以用来给契约添加Tag或者前缀信息。

```java
@OpenAPIDefinition(servers = {@Server(url = "/SameService1")})
public interface SameService1 {
  @GetMapping(path = "/sayHello")
  String sayHello(@RequestParam("name") String name);
}
```

* @Operation

`@Operation`可以用来定义`operationId`或者给契约增加描述信息。 

```java
@GetMapping(path = "/specialNameModel")
@Operation(summary = "specialNameModel", operationId = "specialNameModel")
public SpecialNameModel specialNameModel(@RequestParam("code") int code, @RequestBody SpecialNameModel model) {
  return model;
}
```

* @Parameter

`@Parameter`可以用来描述 query 或者 header 参数的集合类型，给参数添加注释等。 

```java
@Path("headerListCSV")
@GET
String headerListCSV(@Parameter(name = "headerList", in = ParameterIn.HEADER, 
    style = ParameterStyle.FORM, explode = Explode.FALSE)
          List<String> headerList);
```

