# 用SpringMVC 开发微服务

## 概念阐述

ServiceComb支持SpringMVC注解，允许使用SpringMVC风格开发微服务。建议参照着项目 [SpringMVC](https://github.com/apache/incubator-servicecomb-java-chassis/tree/master/samples/springmvc-sample)进行详细阅读

## 开发示例

### 步骤 1定义服务接口。

根据开发之前定义好的契约，编写Java业务接口，代码如下。定义接口不是必须的，但是 一个好习惯，可以简化客户端使用RPC方式编写代码。

```java
public interface Hello {
    String sayHi(String name);
    String sayHello(Person person);
}
```



### 步骤 2实现服务。

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

### 步骤 3发布服务

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

### 步骤 4启动provider 服务

进行主要相关配置初始化。

```java
public class SpringmvcProviderMain {

  public static void main(String[] args) throws Exception {
    Log4jUtils.init();
    BeanUtils.init();
  }
}
```

## 涉及API

Spring MVC开发模式当前支持org.springframework.web.bind.annotation包下的如下注解，所有注解的使用方法参考[Spring MVC官方文档](https://docs.spring.io/spring/docs/current/spring-framework-reference/html/mvc.html)。

### 表1-1 Spring MVC注解支持汇总

| 注解 | 位置 | 描述 |
| :--- | :--- | :--- |
| RequestMapping | schema/operation | 支持标注path/method/produces三种数据，operation默认继承schema上的produces |
| PathVariable | parameter | 从path中获取参数 |
| RequestParam | parameter | 从query中获取参数 |
| RequestHeader | parameter | 从header中获取参数 |
| RequestBody | parameter | 从body中获取参数，每个operation只能有一个body参数 |

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
