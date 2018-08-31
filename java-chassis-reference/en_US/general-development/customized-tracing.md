## Concept Description

Distributed call chain tracking provides timing information for calls between services, but the link call information inside the service is equally important to the developer. If you can combine the two into one, you can provide a more complete call chain, which is easier to locate. Errors and potential performance issues.

## Prerequisites

* Using the custom dot function requires first configuring and enabling the Java Chassis microservice call chain.

## Precautions

* The custom dot function using the `@Span` annotation only supports method calls that are requesting the same thread as the Java Chassis call.
* The method to add the `@Span` annotation must be a Spring-managed bean, otherwise you need to press the [Methods mentioned] (https://stackoverflow.com/questions/41383941/load-time-weaving-for-non-spring -beans-in-a-spring-application) configuration.

## Custom call chain management

This feature integrates Zipkin and provides the `@Span` annotation for custom tracking of methods that need to be tracked. Java Chassis will automatically track all methods that add `@Span` annotations, linking the local call information of each method to the call information between services.

## Steps for usage:

### Adding dependencies

Microservices based on ServiceComb Java Chassis only need to add the following dependency to pom.xml:

```xml
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>tracing-zipkin</artifactId>
    </dependency>
```

### Enable custom management function {#Configure tracking processing and data collection}

Add the `@EnableZipkinTracing` annotation to the application portal or Spring configuration class:

```java
@SpringBootApplication
@EnableZipkinTracing
public class ZipkinSpanTestApplication {
  public static void main(String[] args) {
    SpringApplication.run(ZipkinSpanTestApplication.class);
  }
}
```

### Customized management

Add the `@Span` annotation to the method that requires custom management:

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

In this way, by using the `@Span` annotation, we started the Zipkin-based custom management function.

## Customized reported data

The call chain that is escalated by custom management contains two pieces of data:

* **span name** defaults to the full name of the method currently being annotated.
* **call.path** defaults to the method signature of the current annotation.

For example, the data reported in the above example `SlowRepoImp` is as follows:

| key | value |
| :--- | :--- |
| span name | crawl |
| call.path | public abstract java.lang.String org.apache.servicecomb.tests.tracing.SlowRepo.crawl\(\) throws java.lang.InterruptedException |

If you need to customize the reported data content, you can pass in the custom parameters:

```java
  public static class CustomSpanTask {
    @Span(spanName = "transaction1", callPath = "startA")
    public String invoke() {
      return "invoke the method";
    }
  }
```
