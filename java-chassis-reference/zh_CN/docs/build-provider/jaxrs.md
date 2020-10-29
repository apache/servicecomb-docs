# 用 JAX-RS 开发微服务
## 概念阐述

ServiceComb支持开发者使用JAX-RS注解，使用 [JAX-RS][jax-rs-sample] 模式开发服务。

[jax-rs-sample]: https://github.com/apache/servicecomb-samples/tree/master/java-chassis-samples/jaxrs-sample

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

使用JAX-RS注解开发业务代码，Hello的服务实现如下：

```java
@RestSchema(schemaId = "jaxrsHello")
@Path("/jaxrshello")
@Produces(MediaType.APPLICATION_JSON)
public class JaxrsHelloImpl implements Hello {
    @Path("/sayhi")
    @POST
    @Override
    public String sayHi(String name) {
        return "Hello " + name;
    }

    @Path("/sayhello")
    @POST
    @Override
    public String sayHello(Person person) {
        return "Hello person " + person.getName();
    }
    /**
    * 这个方法是实现类特有的,因此对它的远程调用会有所不同.
    * 具体可以参考 jaxrs-consumer
    */
    @Path("/saybye")
    @GET
    public String sayBye() {
       return "Bye !";
    }
}
```

### 步骤 3发布服务。

在resources/META-INF/spring目录下创建jaxrsHello.bean.xml文件，配置spring进行服务扫描的base-package，文件内容如下。（注意修改package名称为正确名称）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns=" http://www.springframework.org/schema/beans " xmlns:xsi=" http://www.w3.org/2001/XMLSchema-instance "
       xmlns:p=" http://www.springframework.org/schema/p " xmlns:util=" http://www.springframework.org/schema/util "
       xmlns:cse=" http://www.huawei.com/schema/paas/cse/rpc "
       xmlns:context=" http://www.springframework.org/schema/context "
       xsi:schemaLocation=" http://www.springframework.org/schema/beans classpath:org/springframework/beans/factory/xml/spring-beans-3.0.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-3.0.xsd http://www.huawei.com/schema/paas/cse/rpc classpath:META-INF/spring/spring-paas-cse-rpc.xsd">

    <context:component-scan base-package="org.apache.servicecomb.samples.jaxrs.provider"/>
</beans>
```

### 步骤 4启动服务。

```
public class JaxrsProviderMain{

  public static void main(String[] args) throws Exception {
    Log4jUtils.init();
    BeanUtils.init();
  }
}
```

## 涉及API

JAX-RS开发模式当前支持如下注解，所有注解的使用方法参考 [JAX-RS官方文档][jax-rs-spec]。

[jax-rs-spec]: https://jax-rs-spec.java.net/nonav/2.0-rev-a/apidocs/index.html

### 表1-1JAX-RS注解支持汇总

| 注解 | 位置 | 描述 |
| :--- | :--- | :--- |
| javax.ws.rs.Path | schema/operation | URL路径 |
| javax.ws.rs.Produces | schema/operation | 方法支持的编解码能力 |
| javax.ws.rs.DELETE | operation | http method |
| javax.ws.rs.GET | operation | http method |
| javax.ws.rs.POST | operation | http method |
| javax.ws.rs.PUT | operation | http method |
| javax.ws.rs.QueryParam | parameter | 从query string中获取参数 |
| javax.ws.rs.PathParam | parameter | 从path中获取参数，必须在path中定义该参数 |
| javax.ws.rs.HeaderParam | parameter | 从header中获取参数 |
| javax.ws.rs.CookieParam | parameter | 从cookie中获取参数 |
| javax.ws.rs.FormParam | parameter | 从form中获取参数 |
| javax.ws.rs.BeanParam | parameter | 用于参数聚合，允许在一个JavaBean的属性上打上参数标记以将多个参数聚合为一个JavaBean |

> **说明:**
>
> * 当方法参数没有注解，且不为`HttpServletRequest`、`InvocationContext`类型参数时，默认为body类型参数，一个方法最多只支持一个body类型参数。

## 使用@BeanParam聚合参数

### 使用说明

用户可以使用@BeanParam注解将多个参数聚合到一个JavaBean中，通过将@QueryParam等参数注解打在此JavaBean的属性或setter方法上来声明参数，从而简化业务接口的参数表。可以参考JAX-RS的官方说明：https://docs.oracle.com/javaee/7/api/javax/ws/rs/BeanParam.html

ServiceComb现在也支持类似的用法，该用法的要求如下：
1. 聚合参数所用的类型必须是标准的JavaBean，即类型的属性与getter、setter方法名称匹配，setter方法的返回类型为`void`
2. 参数注解可以打在JavaBean的属性或setter方法上
3. 允许通过@FormParam将多个上传文件参数聚合到JavaBean中
4. 作为BeanParam的JavaBean内部如果有多余的属性，需要打上`@JsonIgnore`忽略掉
5. body参数无法聚合进BeanParam
6. Consumer端不支持将参数聚合为JavaBean发送，即仍然需要按照接口契约单独填写各个参数

### 代码示例

#### Provider端开发服务

- Provider端业务接口代码：
```java
  @RestSchema(schemaId = "helloService")
  @Path("/hello")
  public class HelloService {
    @Path("/sayHello/{name}")
    @GET
    public String sayHello(@BeanParam Person person) {
      System.out.println("sayHello is called, person = [" + person + "]");
      return "Hello, your name is " + person.getName() + ", and age is " + person.getAge();
    }
  }
```
- BeanParam参数定义：
```java
  public class Person {
    private String name;
    @QueryParam("age")
    private int age;
    @PathParam("name")
    public void setName(String name) {
      this.name = name;
    }
    @JsonIgnore // 忽略复杂属性
    private List<Person> children;

    // 其他方法忽略
  }
```
- 接口契约：
```yaml
# 忽略契约的其他部分
basePath: "/hello"
paths:
  /sayHello/{name}:
    get:
      operationId: "sayHello"
      parameters:
      - name: "name"
        in: "path"
        required: true
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
  "cse://provider-service/hello/sayHello/Bob?age=22",
  String.class); // 调用效果与RPC方式相同
```
