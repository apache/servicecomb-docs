# Parameter Validation
## Scenario
Users can set parameter validation rules in the provider's configuration. The rules will validate input parameters when provider APIs are called, so the parameters can be defined in a specific format.

## Configuration instructions

* Add the pom dependency of swagger-invocation-validator:

  ```xml
  <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>swagger-invocation-validator</artifactId>
  </dependency>
  ```

* Add validator annotations to the code that requires validation by the JSR 349 specification, such as @NotNull, @Min, @Max, etc.

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

Add @Valid in front of the incoming Student object, like the method sayHello\(@Valid Student student\) shown above.

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

* The default parameter validator ParameterValidator has implemented the interface ProducerInvokeExtension to handle the required parameter validation with the JSR 349 specification.

   If any parameter validation fails, the default error is BAD\_REQUEST\(400, "Bad Request"\).

   Return error can be customized with the SPI mechanism.

* Developer can customize the returned error information by implementing the interface ExceptionToProducerResponseConverter, taking the ConstraintViolationExceptionToProducerResponseConverter as an example.

   1. Implement the ExceptionToProducerResponseConverter interface, override the method, the return value of the getOrder method indicates the priority of the validator. The smaller the value, the higher the priority.

     ```java
     public class ConstraintViolationExceptionToProducerResponseConverter
         implements ExceptionToProducerResponseConverter<ConstraintViolationException> {
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

  2. Add a file in the services folder under META-INF, with the implemented interface x.x.x.ExceptionToProducerResponseConverter(with package name\) as the name, and the implementation class x.x.x.ConstraintViolationExceptionToProducerResponseConverter(with package name\) as the content.
