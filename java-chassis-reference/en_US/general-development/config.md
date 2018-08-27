# Using dynamic configuration

ServiceComb provides a hierarchical configuration mechanism. According to the priority, it is divided into:
* Configuration Center (dynamic configuration)
* Java System Property (-D parameter)
* Environmental variables
* Configuration file, microservice.yaml. The microservice.yaml file is scanned from the classpath and can be allowed to exist in many copies. Specify the priority by servicecomb-config-order.

The configuration file defaults to microservice.yaml under the classpath, but can be passed to other files through environment variables. The environment variables that can be set are:

|Variable|Description|
|---|---|
|servicecomb.configurationSource.additionalUrls|List of configuration files, separated by multiple full file names containing specific locations |
|servicecomb.configurationSource.defaultFileName|Default configuration file name|

The default implementation of the dynamic configuration is the config-cc client, which is connected to the configuration center. The configuration items are as follows:

|Variable|Description|
|---|---|
|servicecomb.config.client.refreshMode|Application configuration refresh mode, 0 is config-center active push, 1 is client cycle pull, default is 0|
|servicecomb.config.client.refreshPort|config-center push configured port|
|servicecomb.config.client.tenantName|Application tenant name|
|servicecomb.config.client.serverUri|config-center access address, http(s)://{ip}:{port}, to separate multiple addresses (optional, when cse.config.client.regUri is configured as This configuration item will take effect when empty))|

## Get configuration information in the program

Developers use a consistent API to get the configuration, regardless of the configured storage path:
```
DynamicDoubleProperty myprop = DynamicPropertyFactory.getInstance().getDoubleProperty("trace.handler.sampler.percent", 0.1);
```

For details, please refer to [API DOC] (https://netflix.github.io/archaius/archaius-core-javadoc/com/netflix/config/DynamicPropertyFactory.html)

## Handling configuration changes
You can register for a callback to handle configuration changes:
```
 myprop.addCallback(new Runnable() {
      public void run() {
          // Handle configuration changes
      }
  });
```

## Performing configuration item mapping
In some cases, we want to block the configuration of some of the open source components we use and provide our users with their own configuration items. In this case, you can define the mapping through config.yaml under the classpath:
```
registry:
  client:
    serviceUrl:
      defaultZone: eureka.client.serviceUrl.defaultZone
```

After the mapping is defined, the framework maps by default when the configuration is loaded, and the configuration items defined by us are mapped to the configuration items that the open source component can recognize.
