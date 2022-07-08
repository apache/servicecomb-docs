# General configuration instructions

## Configuration source hierarchical relationship

ServiceComb provides a hierarchical configuration mechanism. According to the priority, it is divided as below(the former is higher):

* Configuration Center (dynamic configuration)
* Java System Property (-D parameter)
* Environmental variables
* Configuration file

### Configuration file

The configuration file is the microservice.yaml file on classpath by default. When the ServiceComb-Java-Chassis is booting up, the microservice.yaml files are loaded from the jar files and the directories on the hard disks. All of the configuration files are merged into a set of valid configurations. The configuration files on the hard disks has higher priority than those in the jar files. The priority can also be specified by the `servicecomb-config-order` item in the configuration files.

> Tips: Since the microservice.yaml file on the hard disk has a higher priority, the `.` directory can be added into the classpath of the executable jar package, so that a microservice.yaml file can be placed in the directory where the service jar package is located, to overwrite the configuration files in the jar package.

The default name of the configuration files is "microservice.yaml". The additional configuration files can be added by specifying Java System Property, and the name of the configuration files can be changed in this way, too:

|Java System Property Variable Name|Description|
|---|---|
|servicecomb.configurationSource.additionalUrls|List of configuration files, multiple full file names can be specified with the ',' as separator|
|servicecomb.configurationSource.defaultFileName|Default configuration file name|

### Environmental variables

On Linux, the `.` charactor cannot be contained into environment variable name. As a result, some configuration items cannot be specified into environment variables directly. As a solution, the `.` charactor can be replaced by `_`, and the converted configuration item can be specified as environment variable. ServiceComb-Java-Chassis can map those converted configuration items to the original configuration items.

For example, for the configration in microservice.yaml file:
```yaml
servicecomb:
  rest:
    address: 0.0.0.0:8080
```
We can specify `servicecomb_rest_address=0.0.0.0:9090` in the environment variable to overwrite the server port as 9090. This mapping mechanism can also applied to other configuration levels.

###Configuration Center (dynamic configuration)

The default implementation of the dynamic configuration is the config-cc client, which is connected to the configuration center. The configuration items are as follows:

|Variable|Description|
|---|---|
|servicecomb.config.client.refreshMode|Application configuration refresh mode, `0` is config-center active push, `1` is client cycle pull, default is `0`|
|servicecomb.config.client.refreshPort|config-center push configured port|
|servicecomb.config.client.tenantName|Application tenant name|
|servicecomb.config.client.serverUri|config-center access address, the format is `http(s)://{ip}:{port}`, to separate multiple addresses with comma (optional, when cse.config.client.regUri is configured as This configuration item will take effect when empty))|
|servicecomb.config.client.refresh_interval|the configuration refresh interval, the unit is millisecond, default value is 15000|

## Get configuration information in the program

Developers use a consistent API to get the configuration, regardless of the configured storage path:
```java
DynamicDoubleProperty myprop = DynamicPropertyFactory.getInstance().getDoubleProperty("trace.handler.sampler.percent", 0.1);
```
The instance above shows a configuration item whose key is `trace.handler.sampler.percent`, with default value 0.1. Developers can specify the value of this item in the microservice.yaml file, environment variable, Java System Property or Configuration center. **There is no need for the developers to consider where to get the configuration values, Java-Chassis will load the configurations from everywhere, and merge them into one set of configurations according to the priority rule mentioned above.**

For details, please refer to [API DOC] (https://netflix.github.io/archaius/archaius-core-javadoc/com/netflix/config/DynamicPropertyFactory.html)

You can register for a callback to handle configuration changes:
```java
 myprop.addCallback(new Runnable() {
      public void run() {
        // this method is invoked when the value of this configuration item is modified
        System.out.println("trace.handler.sampler.percent is changed!");
      }
  });
```

## Performing configuration item mapping
In some cases, we want to block the configuration of some of the open source components we use and provide our users with their own configuration items. In this case, you can define the mapping through mapping.yaml under the classpath:
```
registry:
  client:
    serviceUrl:
      defaultZone: eureka.client.serviceUrl.defaultZone
```

After the mapping is defined, the framework maps by default when the configuration is loaded, and the configuration items defined by us are mapped to the configuration items that the open source component can recognize.
