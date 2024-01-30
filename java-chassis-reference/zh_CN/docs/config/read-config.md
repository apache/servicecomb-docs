# 在程序中读取配置信息

Java Chassis支持使用一致的API获取配置，开发者不需要关注从哪里读取配置项的
值，Java Chassis会自动从各处读取配置，并按照优先级进行合并以保证用户取到的是优先级最高的配置值。读取配置信息支持下面几种不同的方式。 

## 使用 Spring Boot 的配置机制读取配置

Java Chassis的配置信息，可以通过Spring和Spring Boot的配置机制进行读取，比如 `@Value`、`@ConfigurationProperties`、 `Environment` 等。 Java Chassis
将配置层次应用于Spring Environment中，Spring和Spring Boot读取配置的方式，也能够读取到`microservice.yaml`和动态配置的值。

>>> 注意： `@Value`、`@ConfigurationProperties` 两种使用方式，在动态配置变化的时候，值不会变化。 使用 `Environment`, 在动态配置变化的时候，值会实时变化。 

## 使用 `DymamicProperties` 监听配置变化

注入 `DymamicProperties`， 通过其 API 读取配置和监听配置变化。 

```java
@RestSchema(schemaId = "ProviderController")
@RequestMapping(path = "/")
public class ProviderController {
  private DynamicProperties dynamicProperties;

  private String example;

  @Autowired
  public ProviderController(DynamicProperties dynamicProperties) {
    this.dynamicProperties = dynamicProperties;
    this.example = this.dynamicProperties.getStringProperty("basic.example",
            value -> this.example = value, "not set");
  }
}
```

## 使用 Java Chassis 优先级配置

优先级配置提供了一种简单的管理大量复杂配置的机制，开发者定义一个简单的 JAVA Bean， 定义这个 Bean 的属性对应的配置项， 当配置信息变化的时候， Bean 的属性会自动刷新，极大
的简化了用户管理大量复杂配置的复杂度。 

Bean 属性对应的配置项名称支持通配符， 一个属性可以关联若干配置项，可以声明这些配置项的优先级。 Java对象可以是一个 Java Bean，或是一个拥有public字段的类。

* 配置注入对象

  我们首先设计两个Java类用于注入配置属性，分别用来演示不使用注解和使用注解的场景。使用@InjectProperties注解并声明为Bean:

      ```Java
      @Component
      @InjectProperties(prefix = "jaxrstest.jaxrsclient")
      public class Configuration {
        /*
         * 方法的 prefix 属性值 "override" 会覆盖标注在类定义的 @InjectProperties
         * 注解的 prefix 属性值。
         *
         * keys属性可以为一个字符串数组，下标越小优先级越高。
         *
         * 这里会按照如下顺序的属性名称查找配置属性，直到找到已被配置的配置属性，则停止查找：
         * 1) jaxrstest.jaxrsclient.override.high
         * 2) jaxrstest.jaxrsclient.override.low
         *
         * 测试用例：
         * jaxrstest.jaxrsclient.override.high: hello high
         * jaxrstest.jaxrsclient.override.low: hello low
         * 预期：
         * hello high
         */
        @InjectProperty(prefix = "jaxrstest.jaxrsclient.override", keys = {"high", "low"})
        public String strValue;
    
        /**
         * keys支持通配符，并在可以在将配置属性注入的时候指定通配符的代入对象。
         *
         * 测试用例：
         * jaxrstest.jaxrsclient.k.value: 3
         * 预期：
         * 3
         */
        @InjectProperty(keys = "${key}.value")
        public int intValue;
    
        /**
         * 通配符的代入对象可以是一个字符串List，优先级遵循数组元素下标越小优先级越高策略。
         *
         * 测试用例：
         * jaxrstest.jaxrsclient.l1-1: 3.0
         * jaxrstest.jaxrsclient.l1-2: 2.0
         *
         * 预期：
         * 3.0
         */
        @InjectProperty(keys = "${full-list}")
        public float floatValue;
    
        /**
         * keys属性也支持多个通配符，优先级如下：首先通配符的优先级从左到右递减，
         * 然后如果通配符被代入List，遵循List中元素index越小优先级越高策略。
         *
         * 测试用例：
         * jaxrstest.jaxrsclient.low-1.a.high-1.b: 1
         * jaxrstest.jaxrsclient.low-1.a.high-2.b: 2
         * jaxrstest.jaxrsclient.low-2.a.high-1.b: 3
         * jaxrstest.jaxrsclient.low-2.a.high-2.b: 4
         * 预期：
         * 1
         */
        @InjectProperty(keys = "${low-list}.a.${high-list}.b")
        public long longValue;
    
        /**
         * 可以通过注解的defaultValue属性指定默认值。如果字段未关联任何配置属性，
         * 定义的默认值会生效，否则默认值会被覆盖。
         *
         * 测试用例：
         * 预期：
         * abc
         */
        @InjectProperty(defaultValue = "abc")
        public String strDef;
      }
      ```

  Configuration对象的longValue字段按以下顺序查找已配置的属性:

        1.  root.low-1.a.high-1.b
        2.  root.low-1.a.high-2.b
        3.  root.low-2.a.high-1.b
        4.  root.low-2.a.high-2.b

  Configuration对象的floatValue字段按以下顺序查找已配置的属性:

        1.  root.l1-1
        2.  root.l1-2

  不使用注解：

        ```Java
        @Component
        @InjectProperties(prefix = "jaxrstest.jaxrsclient")
        public class ConfigNoAnnotation {
            /*
             * 如果未提供@InjectProperties和@InjectProperty注解，会默认使用字段名作为配置属性名。
             * 注意类名不作为前缀起作用。
             * 此处将配置属性 strValue 绑定到该字段
            */
          public String strValue;
        }
        ```

  ConfigNoAnnotation 对象的 strValue 字段会查找已配置的属性 strValue，没有前缀和优先级。

  更多关于配置注入的用法，建议下载 java-chassis 的源码， 查看 TestConfigObjectFactory 类里面的示例。


