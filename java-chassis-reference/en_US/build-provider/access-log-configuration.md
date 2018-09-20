## Concepts

ServiceComb provides Vert.x based access log. When developing with REST over Vert.x , access log printing can be enabled through a simple configuration.

## Scenario

The user may need the access log when debugging the application. When using REST over servlet, the web container provides the access log function; for REST over Vert.x, ServiceComb provides a set of access log functionalities.

## Configuration

### Enable Access Log

Add the following configurations in the microservice.yaml file to enable access log:

```yaml
servicecomb:
  accesslog:
    enabled: true  ## Enable access log
```

_**Access log Configuration Items**_

| Configuration Item            | Values                | Default Value        | Description                                        |
| :---------------------------- | :-------------------- | :------------------- | :------------------------------------------------- |
| servicecomb.accesslog.enabled | true/false            | false                | true to enabled access log                         |
| servicecomb.accesslog.pattern | the format of the log | "%h - - %t %r %s %B" | See _**log configuration items**_ for more details |

> _**Note**_
>
> - The 2 items are optional, if not configured, the default value will be applied.

### Log format configuration

The currently available configuration items for log are describe in the following table ***Log configuration items(Apache & W3C)*** and***Log configuration items(ServiceComb)*** 。

_**Log configuration items (Apache & W3C)**_

| Item                                          | Apache log format                     | W3C log format | Description                                                  |
| :-------------------------------------------- | :------------------------------------ | :------------- | :----------------------------------------------------------- |
| HTTP method                                   | %m                                    | cs-method      | -                                                            |
| HTTP status                                   | %s                                    | sc-status      | -                                                            |
| Duration in second                            | %T                                    | -              | -                                                            |
| Duration in millisecond                       | %D                                    | -              | -                                                            |
| Remote hostname                               | %h                                    | -              | -                                                            |
| Local hostname                                | %v                                    | -              | -                                                            |
| Local port                                    | %p                                    | -              | -                                                            |
| Size of response                              | %B                                    | -              | Print "0" if body size is 0                                  |
| Size of response                              | %b                                    | -              | Print "-" if body size is 0                                  |
| First line of request                         | %r                                    | -              | Include HTTP Method, Uri and HTTP version                    |
| URI path                                      | %U                                    | cs-uri-stem    | -                                                            |
| Query string                                  | %q                                    | cs-uri-query   | -                                                            |
| URI path and query string                     | -                                     | cs-uri         | -                                                            |
| Request protocol                              | %H                                    | -              | -                                                            |
| Datetime the request is received              | %t                                    | -              | Print time stamp by the default configuration, the format is "EEE, dd MMM yyyy HH:mm:ss zzz", in English and GMT time zone |
| Configurable datetime the request is received | %{PATTERN}t                           | -              | Print time stamp by specified format, in English and GMT time zone |
| Configurable datetime the request is received | %{PATTERN&#124;TIMEZONE&#124;LOCALE}t | -              | Print time stamp by the specified format, language and time zone. The items between vertical bar can be empty(while the \| should not be omitted) |
| Request header                                | %{VARNAME}i                           | -              | Print "-" if the specified request header is not found       |
| Response header                               | %{VARNAME}o                           | -              | Print "-" if the specified response header is not found      |
| Cookie                                        | %{VARNAME}C                           | -              | Print "-" if the specified cookie is not found               |

_**Log configuration items(ServiceComb)**_

| Element            | Placeholder       | Comment                                                      |
| :----------------- | :---------------- | :----------------------------------------------------------- |
| TraceId            | %SCB-traceId      | Print the trace id generated by ServiceComb, if the id is not found, print "-" |
| Invocation Context | %{VARNAME}SCB-ctx | Print the invocation context value whose key is `VARNAME`, if the key is not found, print "-" |

### Output file configuration

The default log framework for Access log is Log4j which provides a default set of configurations for output files. Users can override these configurations in their own log4j.properties file. The configuration items for output files are as follows.

_**Log file configuration items**_

| Item                                 | Default Value    | Description                       | Remarks                                                      |
| :----------------------------------- | :--------------- | :-------------------------------- | :----------------------------------------------------------- |
| paas.logs.accesslog.dir              | ${paas.logs.dir} | The output path of the log file   | The common logs will be outputted to the same path           |
| paas.logs.accesslog.file             | access.log       | Name of the log file              | -                                                            |
| log4j.appender.access.MaxBackupIndex | 10               | Max file numbers for log rotating | -                                                            |
| log4j.appender.access.MaxFileSize    | 20MB             | Max size of log file              | When log file reaches the max size, log rotating is triggered |
| .appender.access.logPermission       | rw-------        | Log file permissions              | -                                                            |

> _**Note**_ 
> Since ServiceComb's log function relies only on the slf4j interface, users can select other log frameworks. For other frameworks, users need to configure the log file output options.

### Switch to logback

> For the project that uses logback, the log framework dependency should be changed from Log4j to logback with some extra configurations to make access log work.

#### 1. Remove Log4j dependencies

Before switching to logback, check the dependencies of the project and remove Log4j related dependencies. Run the maven command `dependency:tree` in the project, find the ServiceComb components that depend on Log4j, and add the following configuration to its `<dependency>`:

```xml
<exclusion>
  <groupId>org.slf4j</groupId>
  <artifactId>slf4j-log4j12</artifactId>
</exclusion>
```

#### 2. Add a logback dependency

Add a dependency for the logback in the pom file:

```xml
<dependency>
  <groupId>org.slf4j</groupId>
  <artifactId>slf4j-api</artifactId>
</dependency>
<dependency>
  <groupId>ch.qos.logback</groupId>
  <artifactId>logback-classic</artifactId>
</dependency>
<dependency>
  <groupId>ch.qos.logback</groupId>
  <artifactId>logback-core</artifactId>
</dependency>
```

#### 3. Configure the logger for the access log component

Since the log component provided by ServiceComb obtains the logger named `accesslog` for log printing, the key to log framework switching is to provide a file called `accesslog` and configure the output file for it. The following is a sample configuration of the access log for logback. It only shows the configurations related to the access log. Other log configurations are omitted:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <!-- Users can customize the appender by their requirement -->
  <appender name="ACCESSLOG" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>./logs/access.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
      <fileNamePattern>./logs/access-%d{yyyy-MM-dd}.log</fileNamePattern>
    </rollingPolicy>
    <!-- Note: the access log content is formatted in code, the pattern should only specify the message without extra format -->
    <encoder>
      <pattern>%msg%n</pattern>
    </encoder>
  </appender>

  <!-- Provide a logger named "accesslog" for log printing -->
  <logger name="accesslog" level="INFO" additivity="false">
    <appender-ref ref="ACCESSLOG" />
  </logger>
</configuration>
```

### Extending Access Log

Users can customize their AccessLogItem by ServiceComb's AccessLogItem extension mechanism.

#### Related classes

1. `AccessLogItem`

```java
  public interface AccessLogItem<T> {
    /**
     * Get specified content from accessLogParam, generate the access log and return
     */
    String getFormattedItem(AccessLogParam<T> accessLogParam);
  }
```

The definition of `AccessLogItem` is as shown above. When request triggers Access Log printing, ServiceComb's Access Log mechanism will traverse a valid `AccessLogItem`, call the `getFormattedItem` method to get the item's Access Log fragment, concatenate all the the fragments into an Access Log, and output it to the log file.

The parameter `AccessLogParam<T>` contains the request start time, the end time, and the request context of type `T`. In the REST over Vert.x communication mode, the type `T` is the `RoutingContext` of Vert.x.

2. `VertxRestAccessLogItemMeta`

```java
  // pattern placeholder prefix
  protected String prefix;
  // pattern placeholder suffix
  protected String suffix;
  // order number of priority
  protected int order;
  // AccessLogItem constructor
  protected AccessLogItemCreator<RoutingContext> accessLogItemCreator;
```

The  `VertxRestAccessLogItemMeta` contains the properties listed above, it specifies how ServiceComb parse the pattern string to get specific AccessLogItem.

- To define a `AccessLogItem` with placeholder `%user-defined`, declare a subclass of `VertxRestAccessLogItemMeta`，set prefix="%user-defined", suffix=null, when `AccessLogPatternParser` parses the "%user-defined", it will fetch the `AccessLogItemCreator` from the meta class and create the corresponding `AccessLogItem`. **Note:** since there is not variable in placeholder "%user-defined", the call to `AccessLogItemCreator` passes the configuration parameter null。

- To get a `AccessLogItem` with placeholder `%{VARNAME}user-defined`, declare a subclass of`VertxRestAccessLogItemMeta`, set prefix="%{", suffix="}user-defined". When `AccessLogPatternParser`parses "%{VARNAME}user-defined", it will extract the "VARNAME" as parameter to call `AccessLogItemCreator`, to create a `AccessLogItem`.

  `VertxRestAccessLogItemMeta` has a subclass`CompositeVertxRestAccessLogItemMeta`. When user needs to define multiple AccessLogItems, multiple `VertxRestAccessLogItemMeta` can be aggregated into `CompositeVertxRestAccessLogItemMeta`. When Parser loads AccessLogItemMeta of type `CompositeVertxRestAccessLogItemMeta`, it calls the meta class's `getAccessLogItemMetas()` method to get a set of AccessLogItemMeta. `VertxRestAccessLogItemMeta` is loaded by the SPI mechanism, and `CompositeVertxRestAccessLogItemMeta` allows user to load multiple meta infos with on one record in the SPI configuration file, which provides great flexibility.

3. `AccessLogItemCreator`

```java
  public interface AccessLogItemCreator<T> {
    // Receive configuration values and return an AccessLogItem. The method receives a null if there is no variables in AccessLogItem placeholder
    AccessLogItem<T> createItem(String config);
  }
```

The user instantiates his AccessLogItem by setting the AccessLogItemCreator in the custom VertxRestAccessLogItemMeta. Since this is a functional interface, when the AccessLogItem is initialized in a simple way, you can directly define the Creator using a Lambda expression to simplify development.

#### Matching rules of AccessLogItemMeta

Once AccessLogItemMeta is loaded into the Parser, it will be sorted once. Parser will match the meta list from front to back when parsing the pattern string. The general matching rules are as follows:
1. Match metas with higher priority.
2. Match the meta with suffix first. When metas with multiple suffixes are matched, ~~take the one with the smallest suffix.~~
3. Match the meta with a longer placeholder, for example, there are two metas, "%abc" and "%a". If  "%abc" is matched, it will return directly.

#### Sample

1. Extend AccessLogItem

 First, the user needs the AccessLogItem interface to implement their own item:

```java
  public class UserDefinedAccessLogItem implements AccessLogItem<RoutingContext> {
    private String config;

    public UserDefinedAccessLogItem(String config) {
      this.config = config;
    }

    @Override
    public String getFormattedItem(AccessLogParam<RoutingContext> accessLogParam) {
      // Here is the user's custom logic, user needs to take relevant data from AccessLogParam or other places, generate and return access log fragments
      return "user-defined-[" + config + "]-[" + accessLogParam.getStartMillisecond() + "]";
    }
  }
```

2. Define AccessLogItem meta class

Inherit the class `VertxRestAccessLogItemMeta` or `CompositeVertxRestAccessLogItemMeta`, define the prefix and suffix of the AccessLogItem:

```java
  public class UserDefinedCompositeExtendedAccessLogItemMeta extends CompositeVertxRestAccessLogItemMeta {
    private static final List<VertxRestAccessLogItemMeta> META_LIST = new ArrayList<>();

    static {
      META_LIST.add(new VertxRestAccessLogItemMeta("%{", "}user-defined", UserDefinedAccessLogItem::new));
    }

    @Override
    public List<VertxRestAccessLogItemMeta> getAccessLogItemMetas() {
      return META_LIST;
    }
  }
```

3. Configure the SPI load file

In the `resources/META-INF/services/` directory, create a file named "org.apache.servicecomb.transport.rest.vertx.accesslog.parser.VertxRestAccessLogItemMeta" and fill in the full class path of the meta class defined in the previous step. Parser will use this file to load the meta class.

4. Configure Access Log pattern

The configuration pattern in the microservice.yaml file is assumed to be "%{test-config}user-defined". The running service triggers the Access Log to print. If the request start time is 1, Access Log will print "user- Defined-[test-config]-[1]".

## Sample code

### Configurations in microservice.yaml

```yaml
## other configurations omitted
servicecomb:
  accesslog:
    enabled: true  ## Enable access log
    pattern: "%h - - %t %r %s %B"  ## Custom log format
```

### Configurations in log4j.properties

```properties
# access log configuration item
paas.logs.accesslog.dir=../logs/
paas.logs.accesslog.file=access.log
# access log File appender
log4j.appender.access.MaxBackupIndex=10
log4j.appender.access.MaxFileSize=20MB
log4j.appender.access.logPermission=rw-------
```