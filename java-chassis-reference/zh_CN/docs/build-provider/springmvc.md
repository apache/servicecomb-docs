# 用 Spring MVC 开发微服务

Spring MVC 是 spring-web 项目定义的一套注解，开发者可以使用这套注解定义 REST 接口。 servicecomb 也
支持使用这套标签定义 REST 接口。需要注意的是，servicecomb 只是使用这些注解，而注解的实现是项目自行开发的，
实现的功能集合是 Spring MVC 注解的子集。可以阅读文章后面的内容了解具体的标签集合和使用约束。

[SpringMVC Sample][spring-mvc-sample] 提供了一些基础的代码示例，可以下载使用。

[spring-mvc-sample]: https://github.com/apache/servicecomb-samples/tree/master/java-chassis-samples/springmvc-sample

## 开发步骤

下面简单介绍使用 Spring MVC 开发 REST 服务的一些简单步骤。

* 定义服务接口（可选）

  定义接口是一个好习惯， 它不是必须的。

        ```java
        public interface Hello {
            String sayHi(String name);
            String sayHello(Person person);
        }
        ```

* 实现服务接口

  在服务的实现类上打上注解 `@RestSchema`，指定 `schemaId`。 注意 `schemaId` 需要保证微服务范围内唯一。

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

* 发布服务 （可选，默认会扫描 main 函数所在的 package ）

  在`resources/META-INF/spring`目录下创建`springmvcprovider.bean.xml`文件，
  命名规则为`\*.bean.xml`，配置spring进行服务扫描的base-package，文件内容如下：

        ```xml
        <?xml version="1.0" encoding="UTF-8"?>
        
        <beans xmlns="http://www.springframework.org/schema/beans"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xmlns:cse="http://www.huawei.com/schema/paas/cse/rpc"
          xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
                http://www.huawei.com/schema/paas/cse/rpc classpath:META-INF/spring/spring-paas-cse-rpc.xsd">
        
            <context:component-scan base-package="org.apache.servicecomb.samples.springmvc.povider"/>
        </beans>
        ```

* 启动 provider 服务

  servicecomb 依赖于 Spring, 只需要将 Spring 框架启动起来即可。

        ```java
        public class SpringmvcProviderMain {
        
          public static void main(String[] args) throws Exception {
            BeanUtils.init();
          }
        }
        ```

## ServiceComb支持的 Spring MVC 注解说明

servicecomb 支持使用 Spring MVC 提供的注解 `org.springframework.web.bind.annotation` 来声
明REST接口，但是两者是独立的实现，而且有不一样的设计目标。servicecomb 的目标是提供跨语言、支持多通信协议的
框架，因此去掉了Spring MVC中一些对跨语言支持不是很好的特性，也不支持特定运行框架强相关的特性，比
如直接访问Servlet协议定义的`HttpServletRequest`。servicecomb 没有实现`@Controller`相关功
能, 只实现了`@RestController`，即通过MVC模式进行页面渲染等功能都是不支持的。

下面是一些具体差异。

* 常用标签支持

  下面是CSE对于Spring MVC常用标签的支持情况。

  ***表1-1 Spring MVC注解情况说明***

| 标签名称 | 是否支持 | 说明 |
| :--- | :--- | :--- |
| RequestMapping | 是 | 不允许制定多个Path，一个接口只允许一个Path，必须显示的声明 method 属性，只能定义唯一一个 method |
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

  Spring MVC使用`@RestController`声明服务，而ServiceComb使用`@RestSchema`声明服务，并且需
  要显式地使用`@RequestMapping`声明服务路径，以区分该服务是采用Spring MVC的标签还是使用JAX RS的标签。

        ```
        @RestSchema(schemaId = "springmvcHello")
        @RequestMapping(path = "/springmvchello", produces = MediaType.APPLICATION_JSON)
        public class SpringmvcHelloImpl implements Hello {
          ......
        }
        ```

  servicecomb 也支持 `@RestController` 声明，等价于 `@RestSchma(schemaId="服务的class名称")`，这个
  功能可以简化用户将老的应用改造为 servicecomb 。 建议用户使用`@RestSchema`显式声明schemaId，在管理
  接口基本的配置项的时候，更加直观。

  **注意**：如果不希望Java-Chassis扫描`@RestController`注解作为REST接口类处理，需要增加配置
  `servicecomb.provider.rest.scanRestController=false` 以关闭此功能。

* 数据类型支持

  Spring 技术实现的 Spring MVC，可以在服务定义中使用多种数据类型，只要这种数据类型能够被json序列化和
  反序列化。比如：

        ```
        // 抽象类型
        public void postData(@RequestBody Object data)
        // 接口定义
        public void postData(@RequestBody IPerson interfaceData)
        // 没指定类型的泛型
        public void postData(@RequestBody Map rawData)
        ```
  
  Spring 技术早期都是基于 JSP/Servlet 协议标准的，还可以使用相关的 context 参数，比如：
  
        ```
        // 具体协议相关的类型
        public void postData(HttpServletRequest rquest, HttpServletResponse response)
        ```  
   
  servicecomb 对于数据类型存在一定的限制，不允许使用接口、抽象类等数据类型定义参数，虽然 servicecomb
  支持使用 Object 这个特殊的类型来处理类型无法确定的情况，但是建议尽可能少使用，使用 Object 作为类型，
  运行时的类型不确定，可能给客户端代码的书写带来一定麻烦。

  servicecomb 也支持一些 context 参数， 参考[使用 Context 参数](context-param.md) 。但是由于 servicecomb 默认的运行环境并不是 JSP/Servlet 协议
  环境，因此不能直接使用 `HttpServletRequest` 和 `HttpServletResponse`。 

  ServiceComb在数据类型的支持方面的更多说明，请参考： [接口定义和数据类型](interface-constraints.md)

* 其他

  更多开发过程中碰到的问题，可以参考[案例](https://bbs.huaweicloud.com/blogs/8b8d8584e70d11e8bd5a7ca23e93a891)。开发过程中存在疑问，也可以在这里进行提问。


## 在响应中包含  HTTP header

可以有多种方式在响应中包含 HTTP header， 下面代码展示了使用 ResponseEntity 包含 HTTP header。 需要注意
使用 @ResponseHeaders 声明返回的 header 信息。 包含了 @ResponseHeaders 以后， 接口生成的契约中，也可以
看到对应的 header 参数。

```java
  @ResponseHeaders({@ResponseHeader(name = "h1", response = String.class),
      @ResponseHeader(name = "h2", response = String.class)})
  @RequestMapping(path = "/responseEntity", method = RequestMethod.POST)
  public ResponseEntity<Date> responseEntity(InvocationContext c1, 
        @RequestAttribute("date") Date date) {
    HttpHeaders headers = new HttpHeaders();
    headers.add("h1", "h1v " + c1.getContext().get(Const.SRC_MICROSERVICE));

    InvocationContext c2 = ContextUtils.getInvocationContext();
    headers.add("h2", "h2v " + c2.getContext().get(Const.SRC_MICROSERVICE));

    return new ResponseEntity<>(date, headers, HttpStatus.ACCEPTED);
  }
```

也可以使用 Response 对象返回 HTTP header，示例代码如下：

```java
  @ApiResponse(code = 202, response = User.class, message = "")
  @ResponseHeaders({@ResponseHeader(name = "h1", response = String.class),
      @ResponseHeader(name = "h2", response = String.class)})
  @RequestMapping(path = "/cseResponse", method = RequestMethod.GET)
  public Response cseResponse(InvocationContext c1) {
    Response response = Response.createSuccess(Status.ACCEPTED, new User());
    Headers headers = response.getHeaders();
    headers.addHeader("h1", "h1v " + c1.getContext().get(Const.SRC_MICROSERVICE));

    InvocationContext c2 = ContextUtils.getInvocationContext();
    headers.addHeader("h2", "h2v " + c2.getContext().get(Const.SRC_MICROSERVICE));

    return response;
  }
```

这个示例代码还通过 @ApiResponse 指定了返回 202 错误码及其类型， 这个响应值会在契约体现。

***注意***: HIGHWAY 协议不支持指定返回错误码和类型。需要同时使用 HIGHWAY 和 REST 访问的接口，
请勿使用。  

## 指定 String 类型 body 编码方式

使用 REST 通信的服务， 一般采用 json 进行编解码。 String 类型的数据， 编码为 json 的时候，存在
双引号。 比如 `abc` 编码以后为 `"abc"` 。 但是 Spring 自身的实现， 将 String 类型的数据，编码
为不带双引号。 为了保持 Spring 原始实现的方式兼容， servicecomb 提供了 `RawJsonRequestBody` 接收
不带双引号的参数。 

```java
  @ResponseBody
  public String testRawJsonAnnotation(@RawJsonRequestBody String jsonInput) {
    return jsonInput;
  }
```

或者使用 MediaType.TEXT_PLAIN_VALUE, 不使用 MediaType.APPLICATION_JSON_VALUE

```java
  @RequestMapping(path = "/textPlain", method = RequestMethod.POST, 
      consumes = MediaType.TEXT_PLAIN_VALUE)
  public String textPlain(@RequestBody String body) {
    return body;
  }
```

如果响应不期望带双引号，可以使用 `produces = MediaType.TEXT_PLAIN_VALUE`

```java
 @RequestMapping(path = "/sayhi/compressed/{name}/v2", 
    method = RequestMethod.GET, produces = MediaType.TEXT_PLAIN_VALUE)
  public String sayHiForCompressed(@PathVariable(name = "name") String name) {
     return name;
  }
```

## Query参数聚合为POJO对象

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

consumer端RPC开发模式：

* Provider接口定义
    
```java
public interface HelloServiceIntf {
  String sayHello(String name, int age);
}
```

* 调用代码

```java
String result = helloService.sayHello("Bob", 22); // result的值为"Hello, your name is Bob, and age is 22"
```

* consumer端RestTemplate开发模式：

```java
String result = restTemplate.getForObject(
  "cse://provider-service/hello/sayHello?name=Bob&age=22",
  String.class); // 调用效果与RPC方式相同
```

