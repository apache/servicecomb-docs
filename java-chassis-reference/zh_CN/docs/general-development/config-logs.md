# 配置日志

java chassis 系统内部全部采用 `slf4j` 记录日志。 `slf4j` 是一套日志 API 标准，具体实现可以由 `log4j`, `log4j2`, `logback` 等
提供。 java chassis 默认没有提供实现的依赖， 开发者可以选项依赖适合自己的日志实现， 下面简单的介绍如何引入常见的实现。

* log4j2

使用 log4j2 需要在项目中提供如下依赖。

```xml
<dependencies>
    <dependency>
      <groupId>org.apache.logging.log4j</groupId>
      <artifactId>log4j-slf4j-impl</artifactId>
    </dependency>
    <dependency>
      <groupId>org.apache.logging.log4j</groupId>
      <artifactId>log4j-api</artifactId>
    </dependency>
    <dependency>
      <groupId>org.apache.logging.log4j</groupId>
      <artifactId>log4j-core</artifactId>
    </dependency>
</dependencies>
```

* logback

使用 logback 需要在项目中提供如下依赖。

```xml
<dependencies>
    <dependency>
      <groupId>ch.qos.logback</groupId>
      <artifactId>logback-classic</artifactId>
    </dependency>
</dependencies>
```


微服务架构下，需要部署大量的微服务实例，调用情况复杂，给问题定位带来了很大的麻烦。 通过调用链系统能够很好的解决日志追踪的问题，但是对于日常的开发调试，部署调用链仍然显得复杂。 java-chassis 提供了一种简单的机制，允许业务在记录日志的时候，包含trace id。

## 在日志系统中记录 trace id

可以在 log4j2 或者 logback 中使用 MDC 的方式记录 trace id。

log4j2的配置如下：

```xml
  <Appenders>
    <Console name="Console" target="SYSTEM_OUT">
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
