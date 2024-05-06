## 场景描述

用户在provider端使用参数效验，可以对相应的参数输入要求预先进行设置，在接口实际调用前进行效验处理，达到控制参数输入标准的效果。

## 配置说明

* 添加swagger-invocation-validator的pom依赖：

        ```xml
        <dependency>
          <groupId>org.apache.servicecomb</groupId>
          <artifactId>swagger-invocation-validator</artifactId>
        </dependency>
        ```

* 在需要验证的代码上按照JSR 349规范添加验证器注解，如@NotNull，@Min，@Max等。

## 示例代码

* 接口参数验证

```java
@RestSchema(schemaId = "validator")
@Path("/validator")
@Produces(MediaType.APPLICATION_JSON)
public class Validator {

  @Path("/add")
  @POST
  public int add(@FormParam("a") int a, @Min(20) @FormParam("b") int b) {
    return a + b;
  }

  @Path("/sayhi/{name}")
  @PUT
  public String sayHi(@Length(min = 3) @PathParam("name") String name) {
    ContextUtils.getInvocationContext().setStatus(202);
    return name + " sayhi";
  }

  @Path("/sayhello")
  @POST
  public Student sayHello(@Valid Student student) {
    student.setName("hello " + student.getName());
    student.setAge(student.getAge());
    return student;
  }
}
```

* bean类验证

需要在传入的Student对象前加 `@Valid`，如上图 `sayHello(@Valid Student student)` 方法。

```java
public class Student {
  @NotNull
  private String name;

  @Max(20)
  private int age;

  public void setName(String name) {
    this.name = name;
  }

  public String getName() {
    return this.name;
  }

  public void setAge(int age) {
    this.age = age;
  }

  public int getAge() {
    return age;
  }
}
```

## 自定义返回异常

默认的参数效验器ParameterValidator已经实现了接口ProducerInvokeExtension，按照JSR 349规范处理所需的参数验证。如果任何参数验证失败，缺省错误是 `BAD_REQUEST(400, "Bad Request")` 。 返回错误支持自定义扩展，使用SPI机制。

可以通过实现接口`ExceptionConverter`来自定义返回的错误信息，以`ConstraintViolationExceptionConverter`为例。

1. 实现ExceptionConverter接口，重写方法，其中getOrder方法的返回结果表示该验证器的优先级，值越小优先级越高。

```java
public class ConstraintViolationExceptionConverter implements ExceptionConverter<ConstraintViolationException> {
  public static final int ORDER = Short.MAX_VALUE;

  public static final String KEY_CODE = "servicecomb.filters.validate.code";

  public ConstraintViolationExceptionConverter() {
  }

  @Override
  public int getOrder() {
    return ORDER;
  }

  @Override
  public boolean canConvert(Throwable throwable) {
    return throwable instanceof ConstraintViolationException;
  }

  @Override
  public InvocationException convert(Invocation invocation, ConstraintViolationException throwable,
          StatusType genericStatus) {
    List<ValidateDetail> details = throwable.getConstraintViolations().stream()
            .map(violation -> new ValidateDetail(violation.getPropertyPath().toString(), violation.getMessage()))
            .collect(Collectors.toList());

    CommonExceptionData exceptionData = new CommonExceptionData(SCBEngine.getInstance().getEnvironment().
            getProperty(KEY_CODE, String.class, DEFAULT_VALIDATE), "invalid parameters.");
    exceptionData.putDynamic("validateDetail", details);
    return new InvocationException(BAD_REQUEST, exceptionData);
  }
}
```

2. 在META-INF下的services文件夹增加一个文件 `org.apache.servicecomb.core.exception.ExceptionConverter`，内容为: `org.apache.servicecomb.core.exception.converter.ConstraintViolationExceptionConverter`。




