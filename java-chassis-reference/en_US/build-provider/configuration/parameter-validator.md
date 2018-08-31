## Scene Description

The user uses the parameter validation on the provider client, and can set the corresponding parameter input requirements in advance, and perform the effect processing before the interface is actually called to achieve the effect of the control parameter input standard.

## Configuration instructions

* Add the pom dependency of swagger-invocation-validator:

  ```xml
  <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>swagger-invocation-validator</artifactId>
  </dependency>
  ```

* Add validator annotations to the code that requires validation according to the JSR 349 specification, such as @NotNull, @Min, @Max, etc.

## Sample Code

* Interface parameter verification
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

* bean class validation

You need to add @Valid in front of the incoming Student object, as shown in the figure above, sayHello\(@Valid Student student\).

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
## Custom return exception

* The default parameter validation parameter ParameterValidator has implemented the interface ProducerInvokeExtension to handle the required parameter validation in accordance with the JSR 349 specification.

   If any parameter validation fails, the default error is BAD\_REQUEST\(400, "Bad Request"\).

   Return error support for custom extensions, using the SPI mechanism.

* You can customize the returned error information by implementing the interface ExceptionToResponseConverter, taking the ConstraintViolationExceptionToResponseConverter as an example.

   1. Implement the ExceptionToResponseConverter interface, override the method, where the return result of the getOrder method indicates the priority of the validator. The smaller the value, the higher the priority.

     ```java
     public class ConstraintViolationExceptionToResponseConverter
         implements ExceptionToResponseConverter<ConstraintViolationException> {
       @Override
       public Class<ConstraintViolationException> getExceptionClass() {
         return ConstraintViolationException.class;
       }

       @Override
       public Response convert(SwaggerInvocation swaggerInvocation, ConstraintViolationException e) {
         return Response.createFail(new InvocationException(Status.BAD_REQUEST, e.getConstraintViolations().toString()));
       }

       @Override
       public int getOrder() {
         return -100;
       }
     }
     ```

  2. Add a file in the services folder under META-INF, with the implementation interface x.x.x.ExceptionToResponseConverter\ (with package name\) as the name, and the concrete implementation class x.x.x.ConstraintViolationExceptionToResponseConverter\ (with package name\) as the content.


