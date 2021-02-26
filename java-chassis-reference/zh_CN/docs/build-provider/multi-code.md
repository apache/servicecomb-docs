# 多个返回值和错误码

使用透明RPC开发服务提供者，开发者很容易理解一个接口只有一个返回值类型。使用REST风格（Spring MVC 或者 JAXRS），很多场景会碰到
多个返回值和错误码的情况。和很多其他开发框架（比如Servlet、Spring MVC等）不一样，Java Chassis要求接口定义的返回值和错误码都
必须显示的声明，即通过代码生成的swagger，必须包含所有的错误码描述和返回值类型描述。 在Java Chassis，无法使用隐藏参数、未声明
的错误码。这样设计的直接好处是接口定义更加明确，不需要额外的文档帮助使用者理解接口的使用方法。 

在前面的开发指导里面，主要介绍了一个返回值和一个错误码的情况（200）。 下面介绍如何使用多个错误码和返回值，同时会介绍如何返回额外的
header参数。 

Java Chassis将错误码进行了分类：2xx错误码认为是一个正常的响应，一个接口只允许存在一个正常响应错误码；
其他错误码认为是一个异常的响应，一个接口可以定义多个异常的响应，并且需要采用InvocationException的方式将异常抛出，每个错误码可以指定
不同的响应类型。 

* 采用`ApiResponse`定义多个返回值和错误码

```java
@Path("/errorCode")
@POST
@ApiResponses({
  @ApiResponse(code = 200, response = MultiResponse200.class, message = ""),
  @ApiResponse(code = 400, response = MultiResponse400.class, message = ""),
  @ApiResponse(code = 500, response = MultiResponse500.class, message = "")})
public MultiResponse200 errorCode(MultiRequest request) {
    if (request.getCode() == 400) {
      MultiResponse400 r = new MultiResponse400();
      r.setCode(400);
      r.setMessage("bad request");
      throw new InvocationException(javax.ws.rs.core.Response.Status.BAD_REQUEST, r);
    } else if (request.getCode() == 500) {
      MultiResponse500 r = new MultiResponse500();
      r.setCode(500);
      r.setMessage("internal error");
      throw new InvocationException(javax.ws.rs.core.Response.Status.INTERNAL_SERVER_ERROR, r);
    } else {
      MultiResponse200 r = new MultiResponse200();
      r.setCode(200);
      r.setMessage("success result");
      return r;
    }
}
```

* 采用 `org.apache.servicecomb.swagger.invocation.Response` 响应类型

采用 `org.apache.servicecomb.swagger.invocation.Response` 响应类型，除了可以定义多个错误码和响应类型，还可以通过
`ResponseHeader` 定义额外的响应头。 

```java
@Path("/errorCode")
@POST
@ApiResponses({
  @ApiResponse(code = 200, response = MultiResponse200.class, message = ""),
  @ApiResponse(code = 400, response = MultiResponse400.class, message = ""),
  @ApiResponse(code = 500, response = MultiResponse500.class, message = "")})
@ResponseHeaders({@ResponseHeader(name = "x-code", response = String.class)})
public Response errorCodeWithHeader(MultiRequest request) {
    Response response = new Response();
    if (request.getCode() == 400) {
      MultiResponse400 r = new MultiResponse400();
      r.setCode(400);
      r.setMessage("bad request");
      response.setStatus(Status.BAD_REQUEST);
      response.setResult(new InvocationException(Status.BAD_REQUEST, r));
      response.setHeader("x-code", "400");
    } else if (request.getCode() == 500) {
      MultiResponse500 r = new MultiResponse500();
      r.setCode(500);
      r.setMessage("internal error");
      response.setStatus(Status.INTERNAL_SERVER_ERROR);
      response.setResult(new InvocationException(Status.INTERNAL_SERVER_ERROR, r));
      response.setHeader("x-code", "500");
    } else {
      MultiResponse200 r = new MultiResponse200();
      r.setCode(200);
      r.setMessage("success result");
      response.setStatus(Status.OK);
      response.setResult(r);
      response.setHeader("x-code", "200");
    }
    return response;
}
```

* 采用 `javax.ws.rs.core.Response` 响应类型

采用 `javax.ws.rs.core.Response` 响应类型，除了可以定义多个错误码和响应类型，还可以通过
`ResponseHeader` 定义额外的响应头。 

```java
@Path("/errorCodeWithHeaderJAXRS")
@POST
@ApiResponses({
  @ApiResponse(code = 200, response = MultiResponse200.class, message = ""),
  @ApiResponse(code = 400, response = MultiResponse400.class, message = ""),
  @ApiResponse(code = 500, response = MultiResponse500.class, message = "")})
public javax.ws.rs.core.Response errorCodeWithHeaderJAXRS(MultiRequest request) {
    javax.ws.rs.core.Response response;
    if (request.getCode() == 400) {
      MultiResponse400 r = new MultiResponse400();
      r.setCode(request.getCode());
      r.setMessage(request.getMessage());
      response = javax.ws.rs.core.Response.status(Status.BAD_REQUEST)
          .entity(new InvocationException(Status.BAD_REQUEST, r))
          .header("x-code", "400")
          .build();
    } else if (request.getCode() == 500) {
      MultiResponse500 r = new MultiResponse500();
      r.setCode(request.getCode());
      r.setMessage(request.getMessage());
      response = javax.ws.rs.core.Response.status(Status.INTERNAL_SERVER_ERROR)
          .entity(new InvocationException(Status.INTERNAL_SERVER_ERROR, r))
          .header("x-code", "500")
          .build();
    } else {
      MultiResponse200 r = new MultiResponse200();
      r.setCode(request.getCode());
      r.setMessage(request.getMessage());
      // If error code is OK family(like 200), we can use the target type.
      response = javax.ws.rs.core.Response.status(Status.OK)
          .entity(r)
          .header("x-code", "200")
          .build();
    }
    return response;
}
```


