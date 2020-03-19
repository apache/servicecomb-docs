# 2.0.1 新特性介绍： 在日志中记录trace id

微服务架构下，需要部署大量的微服务实例，调用情况复杂，给问题定位带来了很大的麻烦。 通过调用链系统能够很好的解决日志追踪的问题，
但是对于日常的开发调试，部署调用链仍然显得复杂。 java-chassis 提供了一种简单的机制，允许业务在记录日志的时候，包含trace id。 

## 在日志系统中记录 trace id

java-chassis 使用 MDC 的方式记录 trace id， 可以在 log4j2 或者 logback 中打印 trace id。 java-chassis 记录 trace id 增加
了 Marker ， 开发者可以方便的将这类日志进行分类输出。 

log4j2的配置如下：

```xml
  <Appenders>
    <Console name="Console" target="SYSTEM_OUT">
      <PatternLayout pattern="[%d][%t][%p][%c:%L][%X{SERVICECOMB_TRACE_ID}] %m%n"/>
    </Console>
  </Appenders>
```

结合 Marker， 将日志分类显示：

```xml
  <Appenders>
    <Console name="Console" target="SYSTEM_OUT">
      <MarkerFilter marker="SERVICECOMB_MARKER" onMatch="DENY" onMismatch="ACCEPT"/>
      <PatternLayout pattern="[%d][%t][%p][%c:%L] %m%n"/>
    </Console>
    <Console name="Console-Tracing" target="SYSTEM_OUT">
      <MarkerFilter marker="SERVICECOMB_MARKER" onMismatch="DENY" onMatch="ACCEPT"/>
      <PatternLayout pattern="[%d][%t][%p][%c:%L][%X{SERVICECOMB_TRACE_ID}] %m%n"/>
    </Console>
  </Appenders>
```

logback的配置如下:

```xml
  <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
    <encoder>
      <pattern>%d [%level] [%thread][%X{SERVICECOMB_TRACE_ID}] - %msg (%F:%L\)%n</pattern>
    </encoder>
  </appender>
```

结合 Marker， 可以将日志分类显示:

```xml
  <appender name="STDOUT-TRACING" class="ch.qos.logback.core.ConsoleAppender">
    <!-- If applicable, can use ch.qos.logback.classic.filter.MarkerFilter -->
    <filter class="org.apache.servicecomb.foundation.logback.MarkerFilter">
      <Marker>SERVICECOMB_MARKER</Marker>
      <OnMismatch>DENY</OnMismatch>
      <OnMatch>ACCEPT</OnMatch>
    </filter>

    <encoder>
      <pattern>%d [%level] [%thread][%X{SERVICECOMB_TRACE_ID}] - %msg (%F:%L\)%n</pattern>
    </encoder>
  </appender>
```

## 业务日志包含 trace id

* 记录 access log

java-chassis 只有少量的日志包含 trace id，业务可以方便的在自己记录的日志中包含 trace id。 下面开发一个简单的 Handler， 记录服务端的
access log。 

```java
public class AccessLogHandler implements Handler {
  private static final Logger LOGGER
      = LoggerFactory.getLogger(AccessLogHandler.class);

  @Override
  public void handle(Invocation invocation, AsyncResponse asyncResp) throws Exception {
    invocation.getTraceIdLogger().info(LOGGER, "request for operation {} begin", invocation.getInvocationQualifiedName());
     invocation.next((resp) -> {
       invocation.getTraceIdLogger().info(LOGGER, "request for operation {} end", invocation.getInvocationQualifiedName());
       asyncResp.complete(resp);
     });
  }
} 
```

配置 Handler

```xml
<config>
  <handler id="custom-access-log"
    class="org.apache.servicecomb.demo.prefix.AccessLogHandler"/>
</config>

```

启用 Handler

```yaml
servicecomb:
  handler:
    chain:
      Provider:
        default: custom-access-log
```

* 业务日志

可以在业务实现中记录 trace id

```java
public class RegisterUrlPrefixEndpoint {
  private static final Logger LOGGER
      = LoggerFactory.getLogger(RegisterUrlPrefixEndpoint.class);

  @GetMapping(path = "/getName")
  public String getName(@RequestParam(name = "name") String name) {
    ((Invocation) ContextUtils.getInvocationContext()).getTraceIdLogger().info(LOGGER, "get name invoked.");
    return name;
  }
}
```

增加了 access log 和业务日志后的效果如下：

```text
[5e72e39e55209533-1] - request for operation PRODUCER rest demo-register-url-prefix-server.RegisterUrlPrefixEndpoint.getName begin
[5e72e39e55209533-1] - get name invoked. 
[5e72e39e55209533-1] - request for operation PRODUCER rest demo-register-url-prefix-server.RegisterUrlPrefixEndpoint.getName end
```

