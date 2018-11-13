# Handle exceptions

ServiceComb has three categories of exceptions：
* User Defined Exceptions：Exceptions defined in API. These exceptions are generated to swagger.

* Control Messages Exceptions：Most of them are thrown by handlers. e.g. Flow control throws TOO_MANY_REQUESTS_STATUS.

  ```java
  CommonExceptionData errorData = new CommonExceptionData("rejected by qps flowcontrol");
  asyncResp.producerFail(new InvocationException(QpsConst.TOO_MANY_REQUESTS_STATUS, errorData));
  ```

* Unknown Exceptions：Unkown exceptions may throw by service implementation like NullPointerException or network SocketException. These exceptions will be caught by ServiceComb and return 490, 590 like error code. e.g.

  ```java
  CommonExceptionData errorData = new CommonExceptionData(cause.getMessage());
  asyncResp.producerFail(new InvocationException(590, errorData)
  ```
  or
  ```java
  asyncResp.consumerFail(new InvocationException(490, errorData)
  ```


## User Defined Exceptions

Users can use @ApiResonse to define different types of exceptions. e.g.

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

and client code know exception type.

```java
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

## Control Messages Exceptions

Control message exceptions not defined in swagger and the type is unknown for serializers. Client code use raw type to process it.

```java
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

The above code assume the type of exception data is unknown and convert it to map. Usually, ServiceComb throws its control messages exception with CommonExceptionData.

## Unknown Exceptions

Unknown exceptions are wrapped to 490 and 590 error code, and type is CommonExceptionData.

## Customize exceptions type

We can define actual types for error code and convert one type of exception to another.

* define actual types for error code

  Define actual types for error code can make consumer code easier, and do not to use raw types. Users can implement a SPI interface org.apache.servicecomb.swagger.invocation.response.ResponseMetaMapper to specify the target exception type for specific error code.
  ```java
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

* convert one type of exception to another

  ServiceComb will serialize `InvocationException` data to response, and when the exception type is not `InvocationException`, a wrapped InvocationException with error code 490, 590 is created. Implement SPI interface `org.apache.servicecomb.swagger.invocation.exception.ExceptionToProducerResponseConverter` can convert one type of exception to another. Here is the description about `ExceptionToProducerResponseConverter`:
  - the method `getExceptionClass()` indicates which type of exception this converter handles. The converter whose `getExceptionClass()` method returns `null` will be taken as default converter.
  - in the method `Response convert(SwaggerInvocation swaggerInvocation, T e)`, the exception is processed and `Response` is returned. The returned `Response` determines the status code, resposne body of the HTTP response.
  - the method `getOrder()` determines the priority of a converter. The less the returned value is, the higher the priority is. If the converter does not implement this method, the default return value is `0`. For a certain type of exception, only the converter with the highest priority will take effect.
  - When an exception comes, the converters will be selected according to its type. If no converter is selected, then the type of its parent class is used to select the converter. Such process will continue until the `Throwable` type is used to select converter. If there is still no converter for this exception, the default converter will be selected to process this type of exception.

  ```java
  public class CustomExceptionToProducerResponseConverter implements ExceptionToProducerResponseConverter<IllegalStateException> {
    @Override
    public Class<IllegalStateException> getExceptionClass() {
      // The return value indicates that this converter handles IllegalStateException
      return IllegalStateException.class;
    }

    @Override
    public int getOrder() {
      // The less the returned value is, the higher the priority is
      return 100;
    }

    @Override
    public Response convert(SwaggerInvocation swaggerInvocation, IllegalStateException e) {
      // Here the exception is processed
      IllegalStateErrorData data = new IllegalStateErrorData();
      data.setId(500);
      data.setMessage(e.getMessage());
      data.setState(e.getMessage());
      InvocationException state = new InvocationException(Status.INTERNAL_SERVER_ERROR, data);
      return Response.failResp(state);
    }
  }
  ```
