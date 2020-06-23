# 使用 Context 参数

Context 参数指在接口声明中的特殊参数，这些参数信息不会出现在最终的契约信息中，开发者可以使用 Context 参数
获取或者传递与运行时有关的信息。 

* HttpServletRequest

  HttpServletRequest 用于获取和HTTP请求有关的信息，比如 header 等。当 servicecomb 运行于 `Highway`
  协议，或者运行于 `vert.x` 服务器之上的时候，仍然可以使用。 但是需要注意，和 JSP/Servlet 协议标准的实现
  不同， 开发者无法通过 HttpServletRequest 操作流，只能够进行一些简单的获取 header 等操作。比如下面的例子，
  获取 query 参数：

        ```java
          @GetMapping(path = "/reduce")
          @ApiImplicitParams({@ApiImplicitParam(name = "a", dataType = "integer", format = "int32", paramType = "query")})
          public int reduce(HttpServletRequest request, @CookieValue(name = "b") int b) {
            int a = Integer.parseInt(request.getParameter("a"));
            return a - b;
          }
        ```

  特别需要注意，如果请求不是直接到达 provider， 而是经过 servicecomb 的 Edge Service 转发到 provider，
  上面的代码还必须使用 `@ApiImplicitParams` 显示的声明这个接口的实现通过 `HttpServletRequest` 读取了
  query 参数 `a`， 如果不声明， Edge Service 做请求转发的时候，不会转发参数 `a`， 代码中读取的参数值为
  null。

  还需要注意，servicecomb 不支持 `HttpServletResponse` Context 参数。

* InvocationContext

  InvocationContext 是 servicecomb 特有的上下文信息，可以在 `Handler`, `HttpServerFilter` 等
  多种场景使用。 InvocationContext 包含 local 和 context 两种数据， local 数据只在本进程的模块间
  传递， context 数据可以在微服务之间传递。 

        ```java
          @ApiResponse(code = 202, response = User.class, message = "")
          @ResponseHeaders({@ResponseHeader(name = "h1", response = String.class),
              @ResponseHeader(name = "h2", response = String.class)})
          @RequestMapping(path = "/cseResponseCorrect", method = RequestMethod.GET)
          public Response cseResponseCorrect(InvocationContext c1) {
            Response response = Response.createSuccess(Status.ACCEPTED, new User());
            Headers headers = response.getHeaders();
            headers.addHeader("h1", "h1v " + c1.getContext().get(Const.SRC_MICROSERVICE));
        
            InvocationContext c2 = ContextUtils.getInvocationContext();
            headers.addHeader("h2", "h2v " + c2.getContext().get(Const.SRC_MICROSERVICE));
        
            return response;
          }
        ```

  上面的代码显示了 InvocationContext 参数的用法， 这个用法和代码中通过 ContextUtils.getInvocationContext()
  获取是等价的。
  
  InvocationContext 还可以在 consumer 端的 RPC 接口中使用， [使用Context传递控制消息](../general-development/context.md) 描述了更多 InvocationContext 的使用
  场景。
  
* Endpoint

  Endpoint 描述当前请求需要发往的实例地址。 这个 context 参数只能够在 consumer 端的 PRC 接口使用。当
  微服务存在多个实例的时候，可以使用这种方式指定将请求发往哪个实例。 
  
        ```java
        public interface SchemaDiscoveryService {
          String getSchema(Endpoint endpoint, String schemaId);
        }
        
        SchemaDiscoveryService schemaDiscoveryService = Invoker
                  .createProxy(serviceName, SchemaDiscoveryService.SCHEMA_ID,
                      SchemaDiscoveryService.class);
        
        schemaDiscoveryService.getSchema(EndpointUtils.parse(endpoint), schemaId);
        ```
