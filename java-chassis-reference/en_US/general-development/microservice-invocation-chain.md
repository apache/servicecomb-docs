## Concept Description

The microservices architecture solves the problems of many single applications, but it also requires us to pay extra. Request processing latency due to network instability is one of the costs.

In a single application, all modules run in the same process, so there is no inter-module interworking problem. However, in the micro-service architecture, services communicate through the network, so we have to deal with network-related issues such as delays, timeouts, network partitions, and so on.

Also, as the business expands its services, it is difficult to see how data flows through a spider-like complex service structure. How can we effectively monitor network latency and visualize data flow in services?

**Distributed Call Chain Tracking** is used to monitor network latency for microservices effectively and visualize data flow in microservices.

## Zipkin

> [Zipkin] (http://zipkin.io/) is a distributed call chain tracking system. It helps users collect time series data to locate latency issues in microservices, and it also manages the collection and query of trace data. Zipkin's design is based on Google [Dapper paper] (http://research.google.com/pubs/pub36356.html).

ServiceComb integrates Zipkin to provide automatic call chain tracking capabilities so that users only need to focus on their business needs.

## Steps for usage:

### Adding dependencies

Microservices based on ServiceComb Java Chassis only need to add the following dependency to pom.xml:

```xml
<dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>handler-tracing-zipkin</artifactId>
</dependency>
```

If the microservice is based on Spring Cloud + Zuul's API gateway, such as the manager service in the workshop demo, we also need to add the following additional dependencies:

```xml
<dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>spring-cloud-zuul-zipkin</artifactId>
</dependency>
```

### Configuring Tracking Processing and Data Collection {#Configuration Tracking Processing and Data Collection}

Set the tracking processor and data collection service address in the microservice.yaml file

```yaml
  servicecomb:
    handler:
      chain:
        Consumer:
          default: tracing-consumer
        Provider:
          default: tracing-provider
  servicecomb:
    tracing:
      collector:
        address: http://zipkin.servicecomb.io:9411
```

In this way, with the addition of two configuration items and no changes to one line of code, we started the distributed call chain tracking function based on Zipkin and Java chassis.

**Note **If other dependencies in the project also introduce a zipkin (such as Spring Cloud), which may cause the zipkin version to be inconsistent and run incorrectly, you need to declare the zipkin version in the project pom.
