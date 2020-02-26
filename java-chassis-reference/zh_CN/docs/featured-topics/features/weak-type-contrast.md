# 2.0.0 新特性介绍： 弱类型契约

"以契约为中心" 是 Java Chassis 的核心设计理念。  “契约” 扮演着用户与开发者，开发者与开发者之间的沟通桥梁。
举几个简单的例子。

开发者发布了一个微服务A，同时发布了一份契约文件：

```yaml
swagger: '2.0'
info:
  title: rest api
  version: 1.0.0

basePath: /controller
produces:
  - application/json
  
paths:
  /add:
    get:
      operationId: add
      parameters:
        - name: a
          in: query
          required: true
          type: integer
          format: int32
        - name: b
          in: query
          required: true
          type: integer
          format: int32
      responses: 
        "200":
          description: add numer
          schema: 
            type: integer
            format: int32
```

微服务A的用户可以基于这份契约，使用浏览器访问`add`接口，也可以在自己的微服务B中，使用`RestTemplate`
调用`add`接口，用户不需要知道微服务A的实现细节，也不需要依赖任何微服务A提供的接口，微服务B保持完全
与微服务A独立。只要契约不变，微服务B就可以保持不变。

作为微服务A的其他开发者，可以基于契约开发治理功能，不需要知道`add`接口的实现细节。比如可以给`add`
接口增加流量控制 `servicecomb.flowcontrol.Provider.qps.limit.[ServiceA].[Controller].[add]=1000`，
限制其流量为1000 TPS；还可以基于 `add` 接口的参数做灰度发布，在灰度发布代码里面可能会存在下面的代码片段：
`invocation.getSwaggerArgument("a")` 来获取参数值。

"以契约为中心"是保持微服务"独立性"非常重要的手段，“独立开发、独立交付”是微服务被引入，提升软件工程能力
最重要的价值。

本文重点介绍2.0.0版本引入的“弱类型契约”，以及它与之前“强类型契约”之间的差别与联系。

## 弱类型契约 vs 强类型契约

弱类型契约和强类型契约的共同点都是"以契约为中心"，因此弱类型契约并没有改变 Java Chassis 的整体设计理念，
而是在实现层面发生了一些变化，进而影响到部分开发体验。2.0.0之前的版本是强类型契约。产生强类型契约和一些技术背景
有关系，讨论的起点可以从 Java Chassis Highway 的 ProtoBuffer 讲起。 

熟悉 ProtoBuffer 的开发者都知道， ProtoBuffer 主要被用于 gRPC， 其他处理 ProtoBuffer 编解码的库还有 ProtoStuff。
gRPC 需要写 IDL 文件， 然后根据 IDL 生成运行时的代码，在gRPC的运行过程中，处理编解码的类在编译时间就已经确定，无法
更改。ProtoStuff 提供的类库比 gRPC 更加灵活，对于同样的 IDL 文件，可以在运行时指定不同的类进行序列化和反序列化。
无论如何，在一个微服务里面，如果存在一个契约（IDL文件），那么必须在编译时就确定这个契约对应的类是什么。这个类可以
有一个，也可以有多个，但是必须在编译的时候确定类的类型。

强类型契约可以定义为：在一个微服务里面，契约必须存在一个或者多个编译时确定的类型与它对应。在2.0.0版本之前，这个对应
的类型是在契约文件里面指定的，比如`x-java-interface: org.apache.servicecomb.demo.controller.Controller` 。 开发者
可能注意到在消费端代码，可以不依赖任何提供端的类，这是因为消费端的代码会根据契约描述，采用 `javassist` 工具动态生成
一个类型与契约对应，不同版本的契约需要生成不一样的类型，如果灰度环境版本过多，就可能导致内存过大的问题，特别是在边缘
(Edge Service）服务里面。

强类型契约的一个外在体现就是下面的代码：

```java
Person result = restTemplate.postForObject("/getPerson", null, Person.class);
```

可能抛出 `ClassCastException` 异常。 因为 `getPerson` 的返回值的类型在编译时已经确定， 如果返回值 Person 类型
与编译时的类型不一样，就会报告 `ClassCastException` 异常。

了解了强类型契约后，弱类型契约的定义就很明显了： 在一个微服务里面，契约可以存在一个或者多个编译时确定的类型与它对应，
也可以不存在编译时确定的类型与它对应。 引入弱类型契约后，下面的代码：

```java
Person1 result = restTemplate.postForObject("/getPerson", null, Person1.class);
Person2 result = restTemplate.postForObject("/getPerson", null, Person2.class);
```

都不会报告 `ClassCastException` 异常，只需要 `Person1` 和 `Person2` 的定义都能够和契约对应。 由此可以看出，弱类型
契约在使用方式上更加灵活，去掉了动态创建类的过程，降低了内存占用，缩短了微服务启动时间。

## 利用弱类型契约增强写代码的灵活性

弱类型契约不要求提供者与消费者使用一样的类型，在代码书写上提供了很大的方便。比如提供者有如下接口：

```java
@RestSchema(schemaId = "weakSpringmvc")
@RequestMapping(path = "/weakSpringmvc", produces = MediaType.APPLICATION_JSON_VALUE)
public class WeakSpringmvc {
  @GetMapping(path = "/diffNames")
  @ApiOperation(value = "differentName", nickname = "differentName")
  public int diffNames(@RequestParam("x") int a, @RequestParam("y") int b) {
    return a * 2 + b;
  }

  @GetMapping(path = "/genericParams")
  @ApiOperation(value = "genericParams", nickname = "genericParams")
  public List<List<String>> genericParams(@RequestParam("code") int code, @RequestBody List<List<String>> names) {
    return names;
  }

  @GetMapping(path = "/genericParamsModel")
  @ApiOperation(value = "genericParamsModel", nickname = "genericParamsModel")
  public GenericsModel genericParamsModel(@RequestParam("code") int code, @RequestBody GenericsModel model) {
    return model;
  }

  @GetMapping(path = "/specialNameModel")
  @ApiOperation(value = "specialNameModel", nickname = "specialNameModel")
  public SpecialNameModel specialNameModel(@RequestParam("code") int code, @RequestBody SpecialNameModel model) {
    return model;
  }
}
```

而消费者只需要访问其中一个接口diffNames，只需要定义一个非常简单的接口：

```java
interface DiffNames {
  int differentName(int x, int y);
}

@RpcReference(microserviceName = "springmvc", schemaId = "weakSpringmvc")
private DiffNames diffNames;
```

其中接口名称是和契约里面的接口名称一致 `differentName`， 而不是和服务端的代码一致 `diffNames`。 契约包含 `x` 和
`y` 两个参数， 并且契约的参数是顺序无关的， 下面的代码也是可以访问同一个接口的：

```java
interface DiffNames2 {
  int differentName(int y, int x);
}

@RpcReference(microserviceName = "springmvc", schemaId = "weakSpringmvc")
private DiffNames2 diffNames2;
```

需要注意的是，2.0.0 版本要求保留参数名称， 在编译代码的时候，需要加上 -parameters 编译参数。

开发者还可以通过 RestTemplate 调用这个接口：

```java
restTemplate.getForObject("cse://springmvc/weakSpringmvc/diffNames?x=2&y=3", Integer.class)
```

或者采用 `InvokerUtils` 调用： 

```java
Map<String, Object> args = new HashMap<>();
args.put("x", 2);
args.put("y", 3);
InvokerUtils.syncInvoke("springmvc", "weakSpringmvc", "differentName", args);
```

## 弱类型契约的治理功能

弱类型契约在 `Invocation` 里面提供了独立的方法，让开发者开发治理功能更加容易。 

```java
  public Map<String, Object> getInvocationArguments() {
    return this.invocationArguments;
  }

  public Map<String, Object> getSwaggerArguments() {
    return this.swaggerArguments;
  }

  public Object getInvocationArgument(String name) {
    return this.invocationArguments.get(name);
  }

  public Object getSwaggerArgument(String name) {
    return this.swaggerArguments.get(name);
  }
```

`getSwaggerArguments` 始终获取的是和契约对应的参数，如果契约为 `x` 和 `y` 两个 query 参数， 那么得到的参数就是
包含  `x` 和 `y` 的 Map 。 `getInvocationArgument` 获取的是实际类型参数， 在服务提供者，这个参数列表的个数和类型
和实际的 Method 的列表对应， 比如可能包含 `InvocationContext` , `HttpServletRequest` 等注入参数。 还有很多情况，
契约参数和类型参数不对应，比如聚合参数的情况，契约参数是多个 query 参数， 而类型参数是一个 POJO； 再比如 POJO 接口
定义的时候， 类型参数可能是多个， 而契约参数只有一个 body 参数。 在服务消费者，如果用户采用 POJO 方式调用服务提供者，
两个接口的返回的值与服务提供者类似，存在语义差别；如果采用 RestTemplate 或者 InvokerUtils 调用， 那么两个接口返回的
内容一样，都是契约参数。在边缘服务， 两个接口返回的都是契约参数。 这种行为体现了弱类型契约的语义： 是否存在编译时
类型与契约对应。

## 弱类型契约带来的一些变更

总体而言，对于 `REST` 通信模式， 弱类型契约不仅增强了写代码的灵活性， 还完整保留了强类型契约的写代码方式，几乎不
存在用户需要感知的变更。 对于 `HIGHWAY` 通信模式， 由于底层采用 ProtoBuffer 编码， 而 ProtoBuffer 天然就是一种
强类型契约的编解码过程， java-chassis 为了支持弱类型契约， 做了大量努力， 在一些边界条件处理上与弱类型契约存在
变更，两个版本的编解码是不兼容的，需要同时升级提供者和消费者。 在编码方式上，差异主要体现在对于缺省值的处理，对于
`null` 的处理等问题上， 详细参考[1.3.0 升级 2.0.0指导](../upgrading/1_3_0T2_0_0.md) 。

 