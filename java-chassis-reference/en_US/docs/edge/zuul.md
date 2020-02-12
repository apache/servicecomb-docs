# Using zuul for edge services

## Concept Description

### API Gateway:

The API Gateway is a server or a unique node that enters the system. The API Gateway encapsulates the architecture of the internal system and provides APIs to individual clients.

### Zuul

Zuul is Netflix's JVM-based router and server-side load balancer, which can be used by Zuul to:

* Certification
* Insight
* pressure test
* Canary Test
* Dynamic routing
* Service migration
* Load shedding
* Safety
* Static phase response processing
* Active / passive traffic management

This section focuses on using Zuul as an API Gateway in SpringBoot applications. For detailed functions of Zuul, please refer to the document [router and filter: Zuul] (https://springcloud.cc/spring-cloud-dalston.html#_router_and_filter_zuul).

## Scene Description

Zuul is the API Gateway, which is to establish a Zuul Proxy application. All the microservice access portals are defined in the Proxy application, and different microservices are distinguished by using different prefixes (stripped\). This section demonstrates Zuul's API Gateway functionality by creating a ZuulProxy SpringBoot application.

## Precautions

The demos such as ZuulProxy and ZuulServer described in this section are based on SpringBoot and ServiceComb frameworks. For details, please refer to [using java chassis in Spring Boot] (../using-java-chassis-in-spring-boot/using-java-chassis-in-spring-boot.md).

## Launching Zuul Proxy

This section describes how to launch a zuul proxy application as an API Gateway. Proceed as follows:

* **Step 1**Add a dependency to the pom file:

```xml
<dependency>
  <groupId>org.springframework.cloud</groupId>
  <artifactId>spring-cloud-starter-zuul</artifactId>
</dependency>
<dependency>
  <groupId>org.springframework.cloud</groupId>
  <artifactId>spring-cloud-starter-ribbon</artifactId>
</dependency><dependency>
  <groupId>org.springframework.cloud</groupId>
  <artifactId>spring-cloud-starter-hystrix</artifactId>
</dependency>
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>spring-boot-starter-discovery</artifactId>
</dependency>
```

* **Step 2**Add annotations to the SpringBoot main class:

```java
@SpringBootApplication
@EnableServiceComb
@EnableZuulProxy//Additional annotations
public class ZuulMain{
    public static void main(String[] args) throws Exception{
        SpringApplication.run(ZuulMain.class, args);
    }
}
```

* **Step 3** Define the routing policy in the application.yml file:

```yaml
server:
  port: 8754 #api gateway service port
zuul:
  routes: #route strategy
    discoveryServer: /myServer/** #route rule
```

The red configuration item indicates that it can be configured according to the actual development environment. For detailed definition rules of the routing policy of zuul.routers, please refer to the official literature: [router and filter: Zuul] (https://springcloud.cc/spring-cloud-dalston.html#_router_and_filter_zuul), which can be more finely Control the route.

* **Step 4** Define microservice properties in microservice.yaml:

```yaml
APPLICATION_ID: discoverytest #service ID
service_description:
  name: discoveryGateway #service name
  version: 0.0.2 #service version number
servicecomb:
  service:
    Registry:
      Address: http://127.0.0.1:30100 #Service registry address
 rest:
   address: 0.0.0.0:8082 # Service port, can not write
```

* **Step 5 **Run ZuulMain Application

## Using Zuul Proxy

Before using the API Gateway made by Zuul, you must first start the microservice provider defined in zuul.routers.

To develop a service provider, please refer to 3 Development Service Provider for the opening process. Pay attention to the following two points in the microservice.yaml file:

* APPLICATION\_ID needs to be consistent in the definition defined in the zuul proxy.

* service\_description.name needs to correspond to zuul.routers.

An example is as follows:

```yaml
APPLICATION_ID: discoverytest # is consistent with zuul proxy
service_description:
  name: discoveryServer #service name, corresponding to zuul.routers
  version: 0.0.2
servicecomb:
  service:
    registry:
      address: http://127.0.0.1:30100 #Service registry address
rest:
  address: 0.0.0.0:8080
```

The API Gateway access is: [http://127.0.0.1:8754] (http://127.0.0.1:8754), all services defined in zuul.routers can be accessed through this access portal, access The rules are as follows:

[http://127.0.0.1:8754/myServer/\*\*\*](http://127.0.0.1:8754/myServer/***)

This means that Http calls [http://127.0.0.1:8754/myServer/\*\*\*] (http://127.0.0.1:8754/myServer/***) and will go to the discoveryServer service (for example: "/myServer/101" jumps to "/101" under the discoveryServer service)

> If there are multiple discoveryServer services in the service center (version is different), zuul uses the Ribbon policy to forward requests.
