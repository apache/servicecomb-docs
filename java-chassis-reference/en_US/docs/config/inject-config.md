# Configuration injection
ServiceComb provides the ability to inject configuration attributes into Java object fields and wildcard support.

A Java object can be a Java Bean or a class with a public field.

## Configure injection objects

We first design two Java classes to inject configuration attributes to demonstrate scenarios where annotations are not used and where annotations are used.

```Java
/*
Use ServiceComb annotations
*/
@InjectProperties(prefix = "root") //Specify the prefix of the configuration attribute associated with the model
public class ConfigWithAnnotation {

  /*
  The prefix attribute value "override" here overrides the prefix attribute value "root" labeled in the @InjectProperties annotation of the class definition. The keys attribute can be an array of strings and the lower the subscript of the array element, the higher the priority.

  Configuration attributes are searched by the attribute names in the following order until the configuration attributes that have been configured are found, then the search is stopped:
	1)override.high
  2)override.low
	*/
  @InjectProperty(prefix = "override", keys = {"high", "low"})
  public String strValue;

  //Keys support wildcards and specify wildcards'input objects when configuration attributes are injected.
  @InjectProperty(keys = "${key}.value")
  public int intValue;

	//The wildcard's surrogate object can be a list of strings. Priority follows the strategy that the lower the subscript of array elements, the higher the priority.
	@InjectProperty(keys = "${full-list}")
  public float floatValue;

  //The keys attribute also supports multiple wildcards, with priority as follows: first, the priority of wildcards decreases from left to right, and then, if wildcards are substituted into List, the lower the index of elements in List, the higher the priority strategy.
  @InjectProperty(keys = "${low-list}.a.${high-list}.b")
  public long longValue;

	//Default values can be specified by the defaultValue attribute of the annotation. If the field is not associated with any configuration properties, the default values defined will take effect, otherwise the default values will be overwritten.
  @InjectProperty(defaultValue = "abc")
  public String strDef;

}
```

```Java
/*
not use Service Comb annotations
*/
public class ConfigNoAnnotation {
  /*
  If the @InjectProperties and @InjectProperty annotations are not provided, the field name is used as the configuration property name by default. Note that class names do not function as prefixes.

  Here, the configuration property strValue is bound to the field
	*/
  public String strValue;
}
```

## Execution injection
We can execute injection with the following sample code：

Inject configuration properties into objects without `InjectProperties` and `InjectProperty` annotations:

```Java
ConfigNoAnnotation config = SCBEngine.getInstance().getPriorityPropertyManager().createConfigObject(ConfigNoAnnotation.class);
```

Inject configuration properties into objects annotated with `InjectProperties` and `InjectProperty`:

* Inject the configuration property named `root.k.value` into the intValue field of a ConfigWithAnnotation object
* The `longValue` field of the `ConfigWithAnnotation` object is injected by looking up the configured configuration properties in the following order:
  1.  root.low-1.a.high-1.b
  2.  root.low-1.a.high-2.b
  3.  root.low-2.a.high-1.b
  4.  root.low-2.a.high-2.b
* The `floatValue` field of the `ConfigWithAnnotation` object is injected by looking up the configured configuration properties in the following order:
  1.  root.l1-1
  2.  root.l1-2

```Java
ConfigWithAnnotation config = SCBEngine.getInstance().getPriorityPropertyManager().createConfigObject(ConfigWithAnnotation.class,
        "key", "k",
        "low-list", Arrays.asList("low-1", "low-2"),
        "high-list", Arrays.asList("high-1", "high-2"),
		"full-list", Arrays.asList("l1-1", "l1-2")
		);
```

Finally, whether it is an annotation injection or not, you must explicitly reclaim the configuration injection object.

```Java
priorityPropertyManager.unregisterConfigObject(config)
```

## Reference resources
Refer to the sample code： https://github.com/apache/servicecomb-java-chassis/blob/master/foundations/foundation-config/src/test/java/org/apache/servicecomb/config/inject/TestConfigObjectFactory.java
