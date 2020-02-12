# Develop Microservice with SpringMVC  
## Concept Description

ServiceComb supports Spring MVC annotations to define your REST services. The [samples project](https://github.com/apache/servicecomb-java-chassis/tree/master/samples/springmvc-sample) has a lot of working examples.

## Development Example

### Step1 Define the service interface （optional）

Writing a interface for the REST service make it easy to call the service in client in RPC style.

```java
public interface Hello {
    String sayHi(String name);
    String sayHello(Person person);
}
```

### Step2 Implement the services

The annotations of Spring MVC are used to describe the development of service code. The implementation of the Hello service is as follow:

 ```java
@RestSchema(schemaId = "springmvcHello")
@RequestMapping(path = "/springmvchello", produces = MediaType.APPLICATION_JSON)
public class SpringmvcHelloImpl implements Hello {
    @Override
    @RequestMapping(path = "/sayhi", method = RequestMethod.POST)
    public String sayHi(@RequestParam(name = "name") String name) {
        return "Hello " + name;
    }

    @Override
    @RequestMapping(path = "/sayhello", method = RequestMethod.POST)
    public String sayHello(@RequestBody Person person) {
        return "Hello person " + person.getName();
    }
}
```

### Step3 add a component scan （optional）

create `resources/META-INF/spring` folder and add `springmvcprovider.bean.xml`, add component-scan to specify the bean package. This step is optional. The package where main class located is automatically added.

```xml
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans classpath:org/springframework/beans/factory/xml/spring-beans-3.0.xsd
       http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-3.0.xsd">

    <context:component-scan base-package="org.apache.servicecomb.samples.springmvc.povider"/>
</beans>
```

### Step4 Wrtie a main class

This code using log4j as the logger framework. Users can change it to any other favorite logger framework.

```java
public class SpringmvcProviderMain {

  public static void main(String[] args) throws Exception {
    Log4jUtils.init();
    BeanUtils.init();
  }
}
```

## Using POJO as query parameters

### Description

SpringBoot supports to map a bean parameter to HTTP queries.
```java
@RequestMapping("/hello")
public class HelloService {
  @RequestMapping(value = "/sayHello", method = RequestMethod.GET)
  public String sayHello(Person person) {
    System.out.println("sayHello is called, person = [" + person + "]");
    return "Hello, your name is " + person.getName() + ", and age is " + person.getAge();
  }
}
```

ServiceComb supports this usage too, but has following constraints.
1. Must not add any mapping annotations, such as `@QueryParam`
2. Only map to query parameters, headers and forms not supported.
3. Variables name in POJO definition must be the same as query keys.
4. Only primitive and String types supported in POJO, add `@JsonIgnore` to other types to ignore it.
5. In consumer site(e.g RestTemplate), still need to use query parameters, can not use POJO.

### Examples

#### Provider

- service definition
```java
  @RestSchema(schemaId = "helloService")
  @RequestMapping("/hello")
  public class HelloService {
    @RequestMapping(value = "/sayHello", method = RequestMethod.GET)
    public String sayHello(Person person) {
      System.out.println("sayHello is called, person = [" + person + "]");
      return "Hello, your name is " + person.getName() + ", and age is " + person.getAge();
    }
  }
```
- parameters
```java
  public class Person {
    private String name;
    private int age;
    @JsonIgnore  // add @JsonIgnore to unsupported types
    private List<Person> children;
  }
```
- Schemas
```yaml

basePath: "/hello"
paths:
  /sayHello:
    get:
      operationId: "sayHello"
      parameters:
        # name and age is query parameter
      - name: "name"
        in: "query"
        required: false
        type: "string"
      - name: "age"
        in: "query"
        required: false
        type: "integer"
        format: "int32"
      responses:
        200:
          description: "response of 200"
          schema:
            type: "string"
```

#### Consumer

- Call using RPC
  - add an interface
  ```java
    public interface HelloServiceIntf {
      String sayHello(String name, int age);
    }
  ```
  - call the interface
  ```java
    String result = helloService.sayHello("Bob", 22); // result is "Hello, your name is Bob, and age is 22"
  ```
- Call using RestTemplate
  ```java
    String result = restTemplate.getForObject(
      "cse://provider-service/hello/sayHello?name=Bob&age=22",
      String.class);
  ```

## ServiceComb suppoted Spring MVC annotations and differences

ServiceComb supports Spring MVC annotatioins\(org.springframework.web.bind.annotation\) to define REST interfaces, but they are different. ServiceComb do not support `@Controller` frameworks and only support `@RestController` frameworks.

* Differences in supported annotations

### Table 1-1 annotations

| annotation | supported | notes |
| :--- | :--- | :--- |
| RequestMapping | Yes | Can only have one path, multiple path is not supported. |
| GetMapping | Yes |  |
| PutMapping | Yes |  |
| PostMapping | Yes |  |
| DeleteMapping | Yes |  |
| PatchMapping | Yes |  |
| RequestParam | Yes |  |
| CookieValue | Yes |  |
| PathVariable | Yes |  |
| RequestHeader | Yes |  |
| RequestBody | Yes | supports application/json，plain/text |
| RequestPart | Yes | Used in file upload. Using Part、MultipartFile annotations. |
| ResponseBody | No | @Controller framework is not supported |
| ResponseStatus | No | Using ApiResponse to define status code |
| RequestAttribute | No |  |
| SessionAttribute | No |  |
| MatrixVariable | No |  |
| ModelAttribute | No |  |
| ControllerAdvice | No |  |
| CrossOrigin | No |  |
| ExceptionHandler | No |  |
| InitBinder | No |  |

* Define a REST service

Spring MVC using `@RestController` to define a REST service，ServiceComb using `@RestSchema` to define a REST service，and path value in `@RequestMapping` is required.

```java
@RestSchema(schemaId = "hello")
@RequestMapping(path = "/")
```

`@RestController` is also supported and equals to `@RestSchma(schemaId="class name")`. However we suggest using `@RestSchema` to define a schemaId，it's more convenient when used in configurations.  

**Cautions**: If the classes with `@RestController` are not expected to be processed by ServiceComb-Java-Chassis and work as REST services, the config item `servicecomb.provider.rest.scanRestController=false` can be specified to disable the feature mentioned above.

* Supported data types

Spring MVC supports almost all java types in service difinition, e.g.

```
// abstract class
public void postData(@RequestBody Object data)
// interface
public void postData(@RequestBody IPerson interfaceData)
// generic without types
public void postData(@RequestBody Map rawData)
// servlet types
public void postData(HttpServletRequest rquest)
```

ServiceComb need to generate Open API schemas based on definition, and support cross language features, so some of there usage is not supported.

HttpServletRequest，Object is supported in latest version, but they are different. We suggest not using there features if possible.

please refer to [API Constraints](interface-constraints.md) for data type supports.
