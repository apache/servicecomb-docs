# 通用配置说明

## 配置源层级

ServiceComb提供了分层次的配置机制。按照优先级从高到低，分为：
* 配置中心（动态配置）
* Java System Property（-D参数）
* 环境变量
* 配置文件

### 配置文件

配置文件默认是classpath下的microservice.yaml文件。ServiceComb-Java-Chassis启动时会从classpath的各个jar包、磁盘目录中加载microservice.yaml文件，并将这些文件合并为一份microservice.yaml配置。位于磁盘上的microservice.yaml文件优先级高于jar包中的microservice.yaml文件，用户还可以通过在配置文件中指定`servicecomb-config-order`来指定优先级。

> Tips：由于磁盘上的microservice.yaml文件优先级较高，我们可以在打包时在服务可执行jar包的classpath里加上`.`目录，这样就可以在服务jar包所在的目录里放置一份microservice.yaml来覆盖jar包内的配置文件。

默认的配置文件名为microservice.yaml，但是我们可以通过设置Java System Property来增加其他的配置文件，或修改默认的配置文件名：

|Java System Property变量名|描述|
|---|---|
|servicecomb.configurationSource.additionalUrls|配置文件的列表，以`,`分隔的多个包含具体位置的完整文件名|
|servicecomb.configurationSource.defaultFileName|默认配置文件名|

### 环境变量

Linux的环境变量名不允许带`.`符号，因此某些配置项无法直接配置在环境变量里。可以将配置项key的`.`符号改为下划线`_`，将转换后的配置项配在环境变量里，ServiceComb-Java-Chassis可以自动将环境变量匹配到原配置项上。

例如：对于microservice.yaml中配置的
```yaml
servicecomb:
  rest:
    address: 0.0.0.0:8080
```
可以在环境变量中设置`servicecomb_rest_address=0.0.0.0:9090`来将服务监听的端口覆写为9090。这种下划线转点号的机制也适用于其他的配置层级。

### 配置中心（动态配置）

动态配置的默认实现是config-cc客户端，对接配置中心，配置项如下：

|配置项名|描述|
|---|---|
|servicecomb.config.client.refreshMode|应用配置的刷新方式，`0`为config-center主动push，`1`为client周期pull，默认为`0`|
|servicecomb.config.client.refreshPort|config-center推送配置的端口|
|servicecomb.config.client.tenantName|应用的租户名称|
|servicecomb.config.client.serverUri|config-center访问地址，格式为`http(s)://{ip}:{port}`，以`,`分隔多个地址(可选，当`cse.config.client.regUri`配置为空时该配置项才会生效)|
|servicecomb.config.client.refresh_interval|pull模式下刷新配置项的时间间隔，单位为毫秒，默认值为30000|

## 在程序中读取配置信息

Java-Chassis支持使用一致的API获取配置，不必关注配置的来源位置：
```java
DynamicDoubleProperty myprop = DynamicPropertyFactory.getInstance().getDoubleProperty("trace.handler.sampler.percent", 0.1);
```
以上例子表示声明了一个key为`trace.handler.sampler.percent`的动态配置对象，默认值为`0.1`。用户可以选择在microservice.yaml文件、环境变量、Java System Property或配置中心里配置`trace.handler.sampler.percent`来修改配置项的值。**用户不需要关注从哪里读取配置项的值，Java-Chassis会自动从各处读取配置，并按照上文的优先级顺序进行合并以保证用户取到的是优先级最高的配置值。**

关于配置项API的具体方法可参考[API DOC](https://netflix.github.io/archaius/archaius-core-javadoc/com/netflix/config/DynamicPropertyFactory.html)。

开发者可以注册callback处理配置变更：
```java
 myprop.addCallback(new Runnable() {
      public void run() {
          // 当配置项的值变化时，该回调方法会被调用
          System.out.println("trace.handler.sampler.percent is changed!");
      }
  });
```

## 进行配置项映射
有些情况下，我们要屏蔽我们使用的一些开源组件的配置并给用户提供我们自己的配置项。在这种情况下，可以通过classpath下的mapping.yaml进行映射定义：
```yaml
registry:
  client:
    serviceUrl:
      defaultZone: eureka.client.serviceUrl.defaultZone
```

定义映射后，在配置装载的时候框架会默认进行映射，把我们定义的配置项映射为开源组件可以认的配置项。
