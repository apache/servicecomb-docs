# 配置注入机制

配置注入提供了一种简单的管理大量复杂配置的机制，开发者不需要使用 DynamicPropertyFactory 逐个读取配置项，增加配置监听，
而是定义一个简单的 JAVA Bean， 定义这个 Bean 的属性对应的配置项， 当配置信息变化的时候， Bean 的属性会自动刷新，极大
的简化了用户管理大量复杂配置的复杂度。 

Bean 属性对应的配置项名称支持通配符， 一个属性可以关联若干配置项，可以声明这些配置项的优先级。 Java对象可以是一个
Java Bean，或是一个拥有public字段的类。

## 配置注入对象
我们首先设计两个Java类用于注入配置属性，分别用来演示不使用注解和使用注解的场景。

```Java
/*
使用ServiceComb注解
*/
@InjectProperties(prefix = "root") //指定该model关联的配置属性的前缀
public class ConfigWithAnnotation {

  /*
	此处的prefix属性值"override"会覆盖标注在类定义的@InjectProperties注解的prefix属性值"root"，keys属性可以为一个字符串数组并且数组元素下标越小优先级越高
	这里会按照如下顺序的属性名称查找配置属性，直到找到已被配置的配置属性，则停止查找：
	1)override.high
    2)override.low
	*/
  @InjectProperty(prefix = "override", keys = {"high", "low"})
  public String strValue;

  //keys支持通配符，并在可以在将配置属性注入的时候指定通配符的代入对象。
  @InjectProperty(keys = "${key}.value")
  public int intValue;

	//通配符的代入对象可以是一个字符串List，优先级遵循数组元素下标越小优先级越高策略
	@InjectProperty(keys = "${full-list}")
  public float floatValue;

  //keys属性也支持多个通配符，优先级如下：首先通配符的优先级从左到右递减，然后如果通配符被代入List，遵循List中元素index越小优先级越高策略。
  @InjectProperty(keys = "${low-list}.a.${high-list}.b")
  public long longValue;

	//可以通过注解的defaultValue属性指定默认值。如果字段未关联任何配置属性，定义的默认值会生效，否则默认值会被覆盖
  @InjectProperty(defaultValue = "abc")
  public String strDef;

}
```

```Java
/*
不使用ServiceComb注解
*/
public class ConfigNoAnnotation {
    /*
	如果未提供@InjectProperties和@InjectProperty注解，会默认使用字段名作为配置属性名。注意类名不作为前缀起作用。
	此处将配置属性 strValue 绑定到该字段
	*/
  public String strValue;
}
```

## 执行注入
我们可以通过以下示例代码来执行注入：

将配置属性注入到无`@InjectProperties`和`@InjectProperty`注解的对象上:

```Java
ConfigNoAnnotation config = SCBEngine.getInstance().getPriorityPropertyManager().createConfigObject(ConfigNoAnnotation.class);
```

将配置属性注入到有`@InjectProperties`和`@InjectProperty`注解的对象上：

* 将名称为root.k.value的配置属性注入到一个ConfigWithAnnotation对象的intValue字段

* ConfigWithAnnotation对象的longValue字段按以下顺序查找已配置的配置属性进行注入:
  1.  root.low-1.a.high-1.b
  2.  root.low-1.a.high-2.b
  3.  root.low-2.a.high-1.b
  4.  root.low-2.a.high-2.b

* ConfigWithAnnotation对象的floatValue字段按以下顺序查找已配置的配置属性进行注入:
  1.  root.l1-1
  2.  root.l1-2

```Java
ConfigWithAnnotation config = SCBEngine.getInstance().getPriorityPropertyManager()
  .createConfigObject(ConfigWithAnnotation.class,
        "key", "k",
        "low-list", Arrays.asList("low-1", "low-2"),
        "high-list", Arrays.asList("high-1", "high-2"),
		"full-list", Arrays.asList("l1-1", "l1-2")
		);
```

如果配置实例是临时的，需要显式地回收配置注入对象。 

```Java
priorityPropertyManager.unregisterConfigObject(config)
```

更多关于配置注入的用法，建议下载 java-chassis 的源码， 查看 TestConfigObjectFactory 类里面的示例。