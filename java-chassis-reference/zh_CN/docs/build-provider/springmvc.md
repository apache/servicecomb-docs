# 用SpringMVC 开发微服务

## 概念阐述

ServiceComb支持SpringMVC注解，允许使用SpringMVC风格开发微服务。建议参照着项目 [SpringMVC](https://github.com/apache/servicecomb-java-chassis/tree/master/samples/springmvc-sample) 进行详细阅读

## 开发示例

### 步骤1 定义服务接口（可选，方便使用RPC方式调用）

定义接口不是必须的，但是 一个好习惯，可以简化客户端使用RPC方式编写代码。

```java
public interface Hello {
    String sayHi(String name);
    String sayHello(Person person);
}
```



### 步骤2 实现服务

使用Spring MVC注解开发业务代码，Hello的服务实现如下。在服务的实现类上打上注解@RestSchema，指定schemaId，schemaId必须保证微服务范围内唯一。

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

### 步骤3 发布服务 （可选，默认会扫描main函数所在的package）

在`resources/META-INF/spring`目录下创建`springmvcprovider.bean.xml`文件，命名规则为`\*.bean.xml`，配置spring进行服务扫描的base-package，文件内容如下：

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

### 步骤4 启动provider 服务

下面的代码使用Log4j作为日志记录器。开发者可以方便使用其他日志框架。

```java
public class SpringmvcProviderMain {

  public static void main(String[] args) throws Exception {
    Log4jUtils.init();
    BeanUtils.init();
  }
}
```

## Query参数聚合为POJO对象

### 使用说明

SpringBoot支持将Java业务接口中的多个query参数聚合为一个POJO类，SpringBoot原生用法示例如下：
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
其中，作为参数的`Person`类是一个标准的JavaBean，包含属性`name`和`age`。当服务接收到的请求时，SpringBoot会将query参数`name`和`age`聚合为Person对象传入业务接口。

ServiceComb的SpringMVC开发模式现在也支持类似的用法，该用法的要求如下：
1. POJO参数上不能有Spring的参数注解，否则ServiceComb不会将其作为聚合的query参数对象处理。
2. 仅支持聚合query参数
3. POJO参数类中的属性名与query参数名需要保持一致
4. POJO参数中不支持复杂的属性，如其他POJO对象、List等。用户可以在这些复杂类型打上`@JsonIgnore`注解来让ServiceComb忽略这些复杂属性。
5. consumer端不支持query参数聚合为POJO对象，调用服务时依然要按照契约发送请求。即provider端被聚合的POJO参数在契约中会被展开成一系列的query参数，consumer端需要在provider接口方法中依次定义这些query参数（RPC开发模式），或在发送请求时填入这些query参数（RestTemplate开发模式）。

### 代码示例

#### Provider端开发服务

- Provider端业务接口代码：
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
- POJO参数对象定义：
```java
  public class Person {
    private String name;
    private int age;
    @JsonIgnore  // 复杂属性需要标记@JsonIgnore，否则启动时会报错
    private List<Person> children;
  }
```
- 接口契约：
```yaml
# 忽略契约的其他部分
basePath: "/hello"
paths:
  /sayHello:
    get:
      operationId: "sayHello"
      parameters:
        # Person类的name属性和age属性作为契约中的query参数
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

#### Consumer端调用服务

- consumer端RPC开发模式：
  - Provider接口定义
  ```java
    public interface HelloServiceIntf {
      String sayHello(String name, int age);
    }
  ```
  - 调用代码
  ```java
    String result = helloService.sayHello("Bob", 22); // result的值为"Hello, your name is Bob, and age is 22"
  ```
- consumer端RestTemplate开发模式：
  ```java
    String result = restTemplate.getForObject(
      "cse://provider-service/hello/sayHello?name=Bob&age=22",
      String.class); // 调用效果与RPC方式相同
  ```

## ServiceComb支持的Spring MVC标签说明

ServiceComb支持使用Spring MVC提供的标签\(org.springframework.web.bind.annotation\)来声明REST接口，但是两者是独立的实现，而且有不一样的设计目标。CSE的目标是提供跨语言、支持多通信协议的框架，因此去掉了Spring MVC中一些对跨语言支持不是很好的特性，也不支持特定运行框架强相关的特性，比如直接访问Servlet协议定义的`HttpServletRequest`。ServiceComb没有实现`@Controller`相关功能, 只实现了`@RestController`，即通过MVC模式进行页面渲染等功能都是不支持的。

下面是一些具体差异。

* 常用标签支持

下面是CSE对于Spring MVC常用标签的支持情况。

### 表1-1 Spring MVC注解情况说明

| 标签名称 | 是否支持 | 说明 |
| :--- | :--- | :--- |
| RequestMapping | 是 | 不允许制定多个Path，一个接口只允许一个Path |
| GetMapping | 是 |  |
| PutMapping | 是 |  |
| PostMapping | 是 |  |
| DeleteMapping | 是 |  |
| PatchMapping | 是 |  |
| RequestParam | 是 |  |
| CookieValue | 是 |  |
| PathVariable | 是 |  |
| RequestHeader | 是 |  |
| RequestBody | 是 | 目前支持application/json，plain/text |
| RequestPart | 是 | 用于文件上传的场景，对应的标签还有Part、MultipartFile |
| ResponseBody | 否 | 返回值缺省都是在body返回 |
| ResponseStatus | 否 | 可以通过ApiResponse指定返回的错误码 |
| RequestAttribute | 否 | Servlet协议相关的标签 |
| SessionAttribute | 否 | Servlet协议相关的标签 |
| MatrixVariable | 否 |  |
| ModelAttribute | 否 |  |
| ControllerAdvice | 否 |  |
| CrossOrigin | 否 |  |
| ExceptionHandler | 否 |  |
| InitBinder | 否 |  |

* 服务声明方式

Spring MVC使用`@RestController`声明服务，而ServiceComb使用`@RestSchema`声明服务，并且需要显式地使用`@RequestMapping`声明服务路径，以区分该服务是采用Spring MVC的标签还是使用JAX RS的标签。

```
@RestSchema(schemaId = "hello")
@RequestMapping(path = "/")
```

Schema是CSE的服务契约，是服务运行时的基础，服务治理、编解码等都基于契约进行。在跨语言的场景，契约也定义了不同语言能够同时理解的部分。

最新版本也支持`@RestController`声明，等价于`@RestSchma(schemaId="服务的class名称")`，建议用户使用`@RestSchema`显式声明schemaId，在管理接口基本的配置项的时候，更加直观。

**注意**：如果不希望Java-Chassis扫描`@RestController`注解作为REST接口类处理，需要增加配置
`servicecomb.provider.rest.scanRestController=false`以关闭此功能。

* 数据类型支持

采用Spring MVC，可以在服务定义中使用多种数据类型，只要这种数据类型能够被json序列化和反序列化。比如：

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

ServiceComb会根据接口定义生成契约，从上面的接口定义，如果不结合实际的实现代码或者额外的开发文档说明，无法直接生成契约。也就是站在浏览器的REST视角，不知道如何在body里面构造消息内容。ServiceComb不建议定义接口的时候使用抽象类型、接口等。

为了支持快速开发，ServiceComb的数据类型限制也在不停的扩充，比如支持HttpServletRequest，Object等。但是实际在使用的时候，他们与WEB服务器的语义是不一样的，比如不能直接操作流。因此建议开发者在ServiceComb的使用场景下，尽可能使用契约能够描述的类型，让代码阅读性更好。

ServiceComb在数据类型的支持方面的更多说明，请参考： [接口定义和数据类型](interface-constraints.md)

* 其他
更多开发过程中碰到的问题，可以参考[案例](https://bbs.huaweicloud.com/blogs/8b8d8584e70d11e8bd5a7ca23e93a891)。开发过程中存在疑问，也可以在这里进行提问。
