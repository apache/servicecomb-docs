# 异常处理

ServiceComb异常情况可以分为三类：
* 业务定义异常：这类异常由业务接口定义。用户在获取到服务swagger定义到时候，就能够从定义中看到这类异常对应的错误码，以及返回值类型。
* 处理控制异常：这类异常通常是框架处理流程上的异常。比如流控Handler抛出TOO_MANY_REQUESTS_STATUS异常。

```
CommonExceptionData errorData = new CommonExceptionData("rejected by qps flowcontrol");
asyncResp.producerFail(new InvocationException(QpsConst.TOO_MANY_REQUESTS_STATUS, errorData));
```

* 未知异常：这类异常发生的情况不确定。比如业务代码实现的时候，抛出NullPointerException等未捕获异常、底层的网络连接超时异常等。这类异常会由ServiceComb封装成590或者490错误返回。比如：

```
CommonExceptionData errorData = new CommonExceptionData(cause.getMessage());
asyncResp.producerFail(new InvocationException(590, errorData)

或者
asyncResp.consumerFail(new InvocationException(490, errorData)
```


## 业务定义异常

通常业务在开发服务代码的时候，只有一个返回值，但有些情况，也需要视具体情况返回不同的消息。可以通过@ApiResonse来定义不同错误码对应的返回消息。业务异常具备确定的数据类型，并且会在swagger里面体现，客户端代码在处理异常的时候，能够直接获取到错误类型。比如下面的代码：

```
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

客户端代码可以按照如下方式处理异常。异常的类型是确定的，可以通过cast获取到异常类型。

```
    MultiRequest request = new MultiRequest();

    request.setCode(200);
    ResponseEntity<MultiResponse200> result = template
        .postForEntity(SERVER + "/MultiErrorCodeService/errorCode", request, MultiResponse200.class);
    TestMgr.check(result.getStatusCode(), 200);
    TestMgr.check(result.getBody().getMessage(), "success result");

    request.setCode(400);
    MultiResponse400 t400 = null;
    try {
      template.postForEntity(SERVER + "/MultiErrorCodeService/errorCode", request, MultiResponse400.class);
    } catch (InvocationException e) {
      t400 = (MultiResponse400) e.getErrorData();
    }
    TestMgr.check(t400.getCode(), 400);
    TestMgr.check(t400.getMessage(), "bad request");

    request.setCode(500);
    MultiResponse500 t500 = null;
    try {
      template.postForEntity(SERVER + "/MultiErrorCodeService/errorCode", request, MultiResponse400.class);
    } catch (InvocationException e) {
      t500 = (MultiResponse500) e.getErrorData();
    }
    TestMgr.check(t500.getCode(), 500);
    TestMgr.check(t500.getMessage(), "internal error");
```

## 控制异常

控制异常一般在接口定义里面没有声明。客户端在做异常处理的时候，不知道异常类型。可以采用弱类型的方式处理异常：

```
    JsonObject requestJson = new JsonObject();
    requestJson.put("code", 400);
    requestJson.put("message", "test message");

    try {
      template
          .postForEntity(SERVER + "/MultiErrorCodeService/noClientErrorCode", requestJson, Object.class);
    } catch (InvocationException e) {
      TestMgr.check(e.getStatusCode(), 400);
      mapResult = RestObjectMapperFactory.getRestObjectMapper().convertValue(e.getErrorData(), Map.class);
      TestMgr.check(mapResult.get("message"), "test message");
      TestMgr.check(mapResult.get("code"), 400);
      TestMgr.check(mapResult.get("t400"), 400);
    }
```

上面的代码假设不知道异常类型，通过API将异常类型转换为Map类型，然后从Map里面读取异常类型。在ServiceComb自己抛出的异常类型中，一般控制异常的类型也是固定的，为CommonExceptionData。

## 未知异常

未知异常统一被封装为490， 590错误码，异常消息的类型固定为CommonExceptionData类型。

## 异常转换和定制

有时候，业务需要将所有的未知异常、控制异常进行捕获，转换为对用户友好的消息。或者对控制异常进行捕获，将消息体转换为自定义的JSON格式。这里面有几个参考点。

* 控制消息消息体序列化

控制消息消息体序列化的目的是简化消费者的异常处理逻辑，不用使用弱类型，而是使用确切类型。可以采用注册全局的错误码类型。
业务需要通过SPI实现org.apache.servicecomb.swagger.invocation.response.ResponseMetaMapper接口。接口的核心内容是为每个错误码制定序列化类型：
```
  private final static Map<Integer, ResponseMeta> CODES = new HashMap<>(1);

  static {
    ResponseMeta meta = new ResponseMeta();
    meta.setJavaType(SimpleType.constructUnsafe(IllegalStateErrorData.class));
    CODES.put(500, meta);
  }
  
  @Override
  public Map<Integer, ResponseMeta> getMapper() {
    return CODES;
  }
```

* 异常转换

如果业务不对异常进行转换，ServiceComb会将InvocationException中的data直接序列化到响应消息中。如果不是InvocationException，则转换为490， 590，序列化的消息为CommonExceptionData。业务可以通过SPI实现org.apache.servicecomb.swagger.invocation.exception.ExceptionToResponseConverter对异常进行转换。该接口的核心是需要指定转换的类型，以及转换处理逻辑。

```
public class CustomExceptionToResponseConverter implements ExceptionToResponseConverter<IllegalStateException> {
  @Override
  public Class<IllegalStateException> getExceptionClass() {
    return IllegalStateException.class;
  }

  @Override
  public int getOrder() {
    return 100;
  }

  @Override
  public Response convert(SwaggerInvocation swaggerInvocation, IllegalStateException e) {
    IllegalStateErrorData data = new IllegalStateErrorData();
    data.setId(500);
    data.setMessage(e.getMessage());
    data.setState(e.getMessage());
    InvocationException state = new InvocationException(Status.INTERNAL_SERVER_ERROR, data);
    return Response.failResp(state);
  }
}

```
