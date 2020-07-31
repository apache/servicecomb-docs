# 接口定义和数据类型

不论采用 `JAX-RS`、`Spring MVC`，还是采用 `透明RPC` 开发，都涉及接口的返回值和参数。java-chassis 
采用的是一种平台无关的数据序列化方式，当 `Transport` 为 `REST` 的时候，序列化方式为 `json`，当
`Transport` 为 `Highway` 的时候，序列化方式为 `protobuffer`。 平台无关的数据序列化方式有个基本
特征：作为 `Consumer`， 从序列化的数据中，无法获取任何和 `Consuemr` 开发语言有关的类型信息。 平台无关
特性给接口定义的数据类型提供了更严格的要求，符合这些要求的接口定义，一方面运行更加高效，另外一方面更加方便的
动态调整 `Transport`， 而无需对代码做出修改。 

对于 `REST`， 虽然 `json` 本身不包含特定平台的类型信息，但是 `JAVA` 可以通过在反序列化的时候，指定目标
类型，所以对于 `REST`， 可以更加灵活的使用不同的类型。 

本章节主要介绍为了实现最大的夸平台和高性能，开发者定义接口的最佳实践。同时介绍在使用 `REST` 的情况下，如何
更加灵活的支持不同的类型。 

## 接口定义的最佳实践和类型约束

java-chassis 的所有接口定义，都可以生成符合 `OpenAPI` 的 `swagger` 接口描述，当使用 `Highway` 协议时，
`swagger` 文件还会在内部被转换为等价的 `proto` 文件。 接口定义的最佳实践需要满足 `OpenAPI` 和 `proto`的
数据类型要求。 

* `OpenAPI` 定义了如下一些基本类型：

下面列举一些常见的类型说明，详细参考 [OpenAPI文档][openAPI]。

[OpenAPI]: https://swagger.io/docs/specification/data-models/data-types/

| type | format | java | 说明 |
| :--- | :--- | :--- | :--- |
| string | - | String | |
| string | date | java.util.Date, java.time.LocalDate| 推荐使用 LocalDate|
| string | date-time | java.util.Date, java.time.LocalDateTime| 推荐使用 LocalDateTime|
| number | - | double | |
| number | float | float | |
| number | double | double | |
| integer | - | integer | |
| integer | int32 | int | |
| integer | int64 | long | |
| boolean | - | boolean | |
| array | | ArrayList | 必须指定类型 |
| object | | | 由上面的属性构成的对象类型。包括字典（HashMap），字典的 key 必须为 string |

* `proto` 定义了如下一些基本类型：

下面列举一些常见的类型说明，详细参考 [Proto Buffer类型说明][proto-buffer]。

[proto-buffer]: https://docs.microsoft.com/en-us/dotnet/architecture/grpc-for-wcf-developers/protobuf-data-types

| type | java | 说明 |
| :--- | :--- | :--- |
| double | double | |
| float | float | |
| int32 | int | |
| int64 | long | |
| uint32 | int | |
| uint64 | long | |
| sint32 | int | |
| sint64 | long | |
| fixed32 | int | |
| fixed64 | long | |
| sfixed32 | int | |
| sfixed64 | long | |
| bool | boolean | |
| string | String | |
| bytes | ByteString | |
| map | | 字典类型 |

`OpenAPI` 的 `date` format 在 `proto` 里面采用 `long` 表示。 java-chassis 的开发实践分为 `code first`
和 `contrast first` 两种模式， 如果采用 `contrast first` 模式，先写 `swagger`， 然后通过 `swagger` 生成
代码， 这种方式生成的数据类型都是符合最佳实践的。 如果采用 `code first`， 要考虑哪些类型是最佳实践，可以从思考定义
的 JAVA 类型，对应的 `swagger` 是什么样子的。 当然这样思考，对于不熟悉 `swagger` 或者 `proto` 的开发者
还是显得复杂。 下面从 `code first` 的角度描述使用哪些类型是最佳实践。 

## 从 `code first` 角度理解夸平台数据类型的约束

开发者不能在接口定义的时候使用如下类型：

* 抽象的数据结构: java.lang.Object, net.sf.json.JsonObject 等。 使用这些类型 java-chassis 启动
  不会报错，功能也是正常的。但不是最佳实践，也会对性能有一定影响。 

* 接口或者抽象类

        ```java
        public interface IPerson {//...}
        public abstract class AbstractPerson  {//...}
        ```

* 上述类型的集合类型或者没有指定具体类型的集合，比如：`List<IPerson>, Map<String, PersonHolder<?>>, List, Map`等。 `List<String>, List<Person>` 这些具体类型是支持的。

* 包含上述类型作为属性的类型

        ```java
        public class GroupOfPerson {IPerson master //...}
        ```

不用担心记不住这些约束，程序会在启动的时候检查不支持的类型，并给与错误提示。

总之，数据结构需要能够使用简单的数据类型进行描述，一目了然就是最好的。这个在不同的语言，不同的协议里面都支持的很
好，长期来看，可以大大减少开发者联调沟通和后期重构的成本。

### 关于数据结构和接口变更

接口名称、参数类型、参数顺序、返回值类型变更都属于接口变更。ServiceComb启动的时候，会根据版本号检测接口变化，
接口变化要求修改版本号。ServiceComb识别接口是否变化是通过代码生成的契约内容，有些不规范的接口定义可能导致在
代码没有变化的情况下，生成的契约不同。比如：

```
public void get(Person p)
class Person {
  private String value;
  private boolean isOk;
  public String getName() {return value}
  public boolean isOk() {return isOK}
}
```

这个接口通过access method定义了"name"和"ok"两个属性，和实际的字段"value"和"isOk"不同。这种情况可能导
致每次启动生成的契约不一样。需要将代码调整为符合JAVA Bean规范的定义。

```
public void get(Person p)
class Person {
  private String name;
  private boolean ok;
  public String getName() {return name}
  public boolean isOk() {return ok}
}
```

或者通过JSON标注，显示的指明字段顺序。比如：

```
public void get(Person p)
@JsonPropertyOrder({"name", "ok"})
class Person {
  private String value;
  private boolean isOk;
  public String getName() {return value}
  public boolean isOk() {return isOK}
}
```

考虑到接口变更的影响，建议在进行对外接口定义的时候，尽可能不要使用第三方软件提供的类作为接口参数，而是使
用自定义的POJO类。一方面升级三方件的时候，可能感知不到接口变化；另外一方面，如果出现问题，无法通过
修改第三方代码进行规避。比如：java.lang.Timestamp, org.joda.time.JodaTime等。

## 协议上的差异

尽管 ServiceComb-Java-Chassis 实现了不同协议之间开发方式的透明，受限于底层协议的限制，不同的协议存在少量差异。

* map，key只支持 string

* highway \(protobuf限制\)  

    1. 不支持在网络上传递null，包括Collection、array中的元素，map的value  
    2. 长度为0的数组、list，不会在网络上传递，接收端解码出来就是默认值

* springmvc  

    1. 不支持 Date 作为 path、query 参数。 因为springmvc 直接将 Date 做 toString 放在path、query中，与
       swagger的标准不匹配。

## 泛型支持

ServiceComb-Java-Chassis 支持REST传输方式下的泛型请求参数和返回值。例如使用一个泛型的数据类型:

```java
public class Generic<T>{
  public T value;
}
```

其中的泛型属性T可以是一个实体类、java.util.Date、枚举，也可以嵌套泛型数据类型。

当用户使用隐式契约功能自动生成微服务契约时，需要在provider接口方法的返回消息中明确指定泛型类型，以保
证 ServiceComb-Java-Chassis 生成的契约中包含足够的接口信息。例如，当provider端接口方法代码为

```java
public Holder<List<Person>> getHolderListArea() {
  Holder<List<Person>> response = new Holder<>();
  // ommited
  return response;
}
```

时， ServiceComb-Java-Chassis 能够识别出泛型返回对象的确切信息，以保证consumer端接收到的应答消息能够被
正确地反序列化。而如果provider端接口方法的代码为

```java
public Holder getHolderListArea() {
  Holder<List<Person>> response = new Holder<>();
  // ommited
  return response;
}
```

时，由于契约中缺少List元素的类型信息，就会出现consumer端无法正确反序列化应答的情况，比如consumer接收
到的参数类型可能会变为`Holder<List<Map<String,String>>>`，`Person`对象退化为Map类型。

> ***说明:***   
> 虽然 ServiceComb-Java-Chassis 支持REST泛型参数，但是我们更加推荐用户使用实体类作为参数，以获得
> 更加明确的接口语义。

## 其他常见问题

* 使用 RestTemplate 传递 raw json

假设服务端定义了接口

```
Person test(Person input)
```

用户期望使用RestTemplate自行拼接json字符串，然后进行传递:
```
      String personStr = JsonUtils.writeValueAsString(input);
      result = template.postForObject(cseUrlPrefix + "sayhello", personStr, Person.class);
```

ServiceComb不推荐开发者这样使用，里面的处理逻辑存在大量歧义。如果必须使用，需要满足几个约束：Person
必须包含带String类型的构造函数；provider/consumer都必须存在这个Person类型。

## `REST` 通信类型扩展

默认情况下， 如果在接口中使用 `interface` 或者 `abstract class` 作为参数或者返回值， java-chassis
启动会报告错误。 java-chassis 提供了类型扩展机制， 使得程序中可以支持各种类型。 

***注意: *** 使用扩展机制的接口，只能够在 `REST` 通信模式下使用。

以支持 `spring-data` 的 `Page` 接口作为返回值为例， 首先需要通过 `SPI` 的机制实现 `jackson` 的类型扩展：

```java
public class SpringDataModule extends SimpleModule implements SPIOrder {
  private static final long serialVersionUID = 1L;

  @JsonDeserialize(as = PageImpl.class)
  @JsonPropertyOrder(alphabetic = true)
  public static class PageMixin<T> {
    @JsonCreator
    public PageMixin(@JsonProperty(value = "content") List<T> content,
        @JsonProperty("pageable") Pageable pageable,
        @JsonProperty("total") long total) {
    }
  }

  @JsonDeserialize(as = PageRequest.class)
  @JsonPropertyOrder(alphabetic = true)
  public static class PageableMixin {
    @JsonCreator
    public PageableMixin(@JsonProperty(value = "pageNumber") int page,
        @JsonProperty("pageSize") int size, @JsonProperty(value = "sort") Sort sort) {
    }
  }

  @JsonPropertyOrder(alphabetic = true)
  @JsonDeserialize(as = Sort.class)
  public static class SortMixin {
    // Notice:
    // spring data model changed from version to version
    // for the tested version, sort is not consistency in serialization and deserialization
    @JsonCreator
    public SortMixin(String... properties) {
    }
  }

  public SpringDataModule() {
    super("springData");

    setMixInAnnotation(Page.class, PageMixin.class);
    setMixInAnnotation(Pageable.class, PageableMixin.class);
    setMixInAnnotation(Sort.class, SortMixin.class);

    setMixInAnnotation(PageImpl.class, PageMixin.class);
    setMixInAnnotation(PageRequest.class, PageableMixin.class);
  }

  @Override
  public Object getTypeId() {
    return getModuleName();
  }

  @Override
  public int getOrder() {
    return Short.MAX_VALUE;
  }
}
``` 

再实现 `SPI` 告诉 java-chassis 跳过类型检查：

```java
public class SpringDataConcreteTypeRegister implements ConcreteTypeRegister {
  @Override
  public void register(Set<Type> types) {
    types.add(Page.class);
    types.add(Pageable.class);
  }
}
```

经过这两个步骤（步骤中没描述开发SPI 需要增加 services 文件的内容）， 就能够实现任意类型的支持。 需要注意，这些扩展，必须
同时包含在 `Consumer`, `Provider`, `edge service` 中，因为这种处理方式是依赖于平台类型的非夸平台特性。 

上述例子的详细代码可以参考 java-chassis 的源代码， generator-spring-data 模块。 

