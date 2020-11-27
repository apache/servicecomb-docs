# 配置日志

java chassis 系统内部全部采用 `slf4j` 记录日志。 `slf4j` 是一套日志 API 标准，具体实现可以由 `log4j`, `log4j2`, `logback` 等
提供。 java chassis 默认没有提供实现的依赖， 开发者可以选项依赖适合自己的日志实现， 下面简单的介绍如何引入常见的实现。

* log4j2

使用 log4j2 需要在项目中提供如下依赖。

```xml
    <dependency>
      <groupId>org.apache.logging.log4j</groupId>
      <artifactId>log4j-slf4j-impl</artifactId>
    </dependency>
```

* log4j

使用 log4j 需要在项目中提供如下依赖。

```xml
    <dependency>
      <groupId>log4j</groupId>
      <artifactId>log4j</artifactId>
    </dependency>
    <dependency>
      <groupId>org.slf4j</groupId>
      <artifactId>slf4j-log4j12</artifactId>
    </dependency>
```

* logback

使用 logback 需要在项目中提供如下依赖。

```xml
    <dependency>
      <groupId>ch.qos.logback</groupId>
      <artifactId>logback-classic</artifactId>
    </dependency>
```