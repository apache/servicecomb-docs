# 微服务调用链

微服务架构解决了很多单体应用带来的问题，但同时也需要我们付出额外的代价。由于网络的不稳定性带来的请求处理延迟就是代价之一。

在单体应用中，所有模块都在同一个进程中运行，所以并没有模块间互通的问题。但微服务架构中，服务间通过网络沟通，因此我们不得不处理和网络有关的 问题，例如：延迟、超时、网络分区等。

另外，随着业务的扩展服务增多，我们很难洞察数据如何在蛛网般复杂的服务结构中流转。我们如何才能有效的监控网络延迟并且可视化服务中的数据流转呢？

**分布式调用链追踪**用于有效地监控微服务的网络延时并可视化微服务中的数据流转。

## Zipkin

> [Zipkin](http://zipkin.io/) 是一个分布式调用链追踪系统。 它能帮助用户收集时序数据用以定位微服务中的延迟问题，它同时管理追踪数据的收集 和查询。

Java Chassis 集成了 Zipkin 提供自动调用链追踪能力，如此一来用户只需要专注实现其业务需求。

## 使用步骤:

* 添加依赖

基于 Java Chassis 的微服务只需要添加如下依赖到 pom.xml：

```xml
<dependency>   
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>handler-tracing-zipkin</artifactId>
</dependency>
```

默认情况下，调用链数据会输出到日志文件，也可以将调用链数据上报到 `Zipkin` 服务器。 

```yaml
  servicecomb: 
    tracing:
      enabled: true # 是否启用调用链追踪功能，默认为 true
      reporter:
        log.enabled: true # 是否将调用链日志输出到文件, 默认为 true
        zipkin.enabled: true # 是否将调用链日志输出到Zipkin服务器, 默认为 false
      collector:  # 配置Zipkin服务器 API 版本和地址信息
        apiVersion: v2
        address: http://zipkin.servicecomb.io:9411
        
```

> 注意：使用Java Chassis 3.1.2及其以上版本

## 自定义调用链打点

分布式调用链追踪提供了服务间调用的时序信息，但服务内部的链路调用信息对开发者同样重要，如果能将两者合二为一，就能提供更完整的调用链，更容易定位错误和潜在性能问题。Java Chassis 提供`@Span`注释为需要追踪的方法自定义打点。Java Chassis将自动追踪所有添加`@Span`注释的方法，把每个方法的本地调用信息与服务间调用信息连接起来。

使用自定义打点功能，需要添加依赖：

```xml
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>tracing-zipkin</artifactId>
    </dependency>
```

在应用入口或Spring配置类上添加 `@EnableZipkinTracing` 注释：

```java
@SpringBootApplication
@EnableZipkinTracing
public class ZipkinSpanTestApplication {
  public static void main(String[] args) {
    SpringApplication.run(ZipkinSpanTestApplication.class);
  }
}
```

在需要定制打点的方法上添加 `@Span` 注释：

```java
@Component
public class SlowRepoImpl implements SlowRepo {
  private static final Logger logger = LoggerFactory.getLogger(SlowRepoImpl.class);

  private final Random random = new Random();

  @Span
  @Override
  public String crawl() throws InterruptedException {
    logger.info("in /crawl");
    Thread.sleep(random.nextInt(200));
    return "crawled";
  }
}
```

就这样，通过使用`@Span`注释，我们启动了基于 Zipkin 的自定义打点功能。

自定义打点上报的调用链包含两条数据：

* **span name** 默认为当前注释的方法全名。
* **call.path** 默认为当前注释的方法签名。

例如，上述例子`SlowRepoImp`里上报的数据如下：

| key | value |
| :--- | :--- |
| span name | crawl |
| call.path | public abstract java.lang.String org.apache.servicecomb.tests.tracing.SlowRepo.crawl\(\) throws java.lang.InterruptedException |

如果需要定制上报的数据内容，可以传入自定义的参数：

```java
  public static class CustomSpanTask {
    @Span(spanName = "transaction1", callPath = "startA")
    public String invoke() {
      return "invoke the method";
    }
  }
```
