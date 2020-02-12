# Using Edge Service for Edge Services

Edge Service is the JAVA gateway service development framework provided by ServiceComb. As the external interface of the entire microservice system, the Edge Service provides services to end users, accesses RESTful requests, and forwards them to internal microservices. The Edge Service is provided in the form of a development framework. Developers can easily build an Edge Service service and define routing and forwarding rules with a simple configuration. At the same time, Edge Service supports powerful expansion capabilities, and services such as service mapping, request parsing, encryption and decryption, and authentication can be extended.

The Edge Service itself is also a microservice that is subject to all microservice development rules. It can be deployed as a multi-instance, and the front-end uses a load balancing device for load distribution. It can also be deployed as a master and backup, and directly access user requests. Developers can plan according to the logic and service access and networking conditions carried by the Edge Service.

## Developing Edge Service
Developing Edge Service is similar to developing a normal microservice. Developers can import [ServiceComb Edge Service Demo] (https://github.com/apache/incubator-servicecomb-java-chassis/tree/master/demo/demo -edge) Start. Building a project from scratch involves the following steps:

* Configure dependencies

By adding edge-core dependencies to your project, you can start the Edge Service. When the Edge Service requests forwarding, it will go through the processing chain, so it can also join the dependencies of the relevant processing chain modules. The following example adds the load balancing processing chain. This is a must.
```
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>edge-core</artifactId>
</dependency>
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>handler-loadbalance</artifactId>
</dependency>
```

* Define the startup class

Just like developing a normal microservice, you can pull the service by loading Spring.
```
public class EdgeMain {
  public static void main(String[] args) throws Exception {
    Log4jUtils.init();
    BeanUtils.init();
  }
}
```

* Increase the configuration file microservie.yaml
The Edge Service itself is also a microservice that follows the rules of microservice lookup and will register itself. Note that APPLICAIONT_ID is the same as the microservice that needs to be forwarded. In the following configuration, the address that the Edge Service listens to, the processing chain, and so on are specified. The auth processing chain is a custom processing chain in the DEMO project for implementing authentication. At the same time, the auth service itself, without going through this processing chain, is equivalent to not authenticating.
```
APPLICATION_ID: edge
service_description:
  name: edge
  version: 0.0.1
servicecomb:
  service:
    registry:
      address: http://127.0.0.1:30100
  rest:
    address: 127.0.0.1:18080
  handler:
    chain:
      Consumer:
        default: auth,loadbalance
        service:
          auth: loadbalance
```

## work process
The workflow of the Edge Service is as follows, the blue background part is executed in the Eventloop thread, and the yellow background part:
   * If working in reactive mode, execute directly in the Eventloop thread
   * If working in thread pool mode, execute in the thread pool thread
![](../assets/workFlow.png)

## Custom routing rules
The core job of using the Edge Service is to configure routing rules. The rules are different, and the rules are different.
A routing rule consists of a series of AbstractEdgeDispatchers. The Edge Service provides several common Dispatchers that can be enabled through configuration. If these Dispatchers do not meet the needs of the business scenario, they can be customized.

### Using DefaultEdgeDispatcher
DefaultEdgeDispatcher is a very simple and easy to manage Dispatcher. With this Dispatcher, users do not need to manage forwarding rules dynamically. It is very convenient to apply to actual business scenarios. This is also a recommended management mechanism. It contains the following configuration items:
```
servicecomb:
  http:
    dispatcher:
      edge:
        default:
          enabled: true
          prefix: rest
          withVersion: true
          prefixSegmentCount: 1
```

Examples and meanings of these common configuration items are as follows:
* [prefix=rest;withVersion=true;prefixSegmentCount=1] The URL provided by the microservice xService is: /xService/v1/abc, the address accessed by the Edge is /rest/xService/v1/abc, and the request is only forwarded to [1.0 .0-2.0.0) version of the microservice instance.
* [prefix=rest;withVersion=true;prefixSegmentCount=2] The URL provided by the microservice xService is: /v1/abc, the address accessed by the Edge is /rest/xService/v1/abc, and the request is only forwarded to [1.0.0] -2.0.0) version of the microservice instance.
* [prefix=rest;withVersion=true;prefixSegmentCount=3] The URL provided by the microservice xService is: /abc, the address accessed by Edge is /rest/xService/v1/abc, and the request is forwarded only to [1.0.0-2.0] .0) version of the microservice instance.
* [prefix=rest;withVersion=false;prefixSegmentCount=1] The URL provided by the microservice xService is: /xService/v1/abc, the address accessed by the Edge is /rest/xService/v1/abc, and the request may be forwarded to any micro Service instance.
* [prefix=rest;withVersion=false;prefixSegmentCount=2] The URL provided by the microservice xService is: /v1/abc, the address accessed by Edge is /rest/xService/v1/abc, and the request may be forwarded to any microservice. Example.
* [prefix=rest;withVersion=false;prefixSegmentCount=2] The URL provided by the microservice xService is: /abc, the address accessed by the Edge is /rest/xService/abc, and the request may be forwarded to any microservice instance.

The withVersion configuration item provides a client grayscale rule that allows the client to specify which server version to access. The Edge Service also includes the ability to route based on interface compatibility automatically, and requests are forwarded to instances that contain the interface. Assume that a microservice, compatibility plan for all high versions must be compatible with the lower version, deploy the following version of the instance:

* 1.0.0, provides operation1

* 1.1.0, provided operation1, operation2

When Edge Service forwards operation1, it automatically uses the rule of 1.0.0+ to filter the instance.

When Edge Service forwards operation2, it automatically uses the rules of 1.1.0+ to filter instances.

The above process does not require any intervention and is fully automated to avoid forwarding the new version of the operation to the instance of the old version.

### Using URLMappedEdgeDispatcher
URLMappedEdgeDispatcher allows users to configure mappings between URLs and microservices. It is very flexible to define which URLs are forwarded to which microservices. It contains the following configuration items:
```
servicecomb:
  http:
    dispatcher:
      edge:
        url:
          enabled: true
          mappings:
            businessV1:
              prefixSegmentCount: 1
              path: "/url/business/v1/.*"
              microserviceName: business
              versionRule: 1.0.0-2.0.0
            businessV2:
              prefixSegmentCount: 1
              path: "/url/business/v2/.*"
              microserviceName: business
              versionRule: 2.0.0-3.0.0
```

The meaning of the businessV1 configuration item is that the request with the request path of /usr/business/v1/.* is forwarded to the microservice of business and only forwarded to the instance with version number 1.0.0-2.0.0 (excluding 2.0). .0). The URL when forwarding is /business/v1/.*. Path uses the JDK regular expression, and you can view the description of the Pattern class. prefixSegmentCount indicates the number of URL segments of the prefix, and the prefix is not included in the forwarded URL path. Three forms of versionRule can be specified. 2.0.0-3.0.0 indicates the version range, including 2.0.0, but does not contain 3.0.0; 2.0.0+ indicates a version greater than 2.0.0, including 2.0.0; 2.0.0 means forwarding only to 2.0.0 version. 2, 2.0 is equivalent to 2.0.0.

As can be seen from the above configuration, URLMappedEdgeDispatcher also supports client grayscale. Of course, there will be more configuration items than DefaultEdgeDispatcher. The URLMappedEdgeDispatcher supports dynamic configuration modification of the configuration center to adjust routing rules.

### Custom Dispatcher

Customizing the Dispatcher involves two steps:

1. Implement AbstractEdgeDispatcher
2. Release via SPI: add the file META-INF/services/org.apache.servicecomb.transport.rest.vertx.VertxHttpDispatcher and write the implementation class

Detailed code details can be found in the following section "DEMO Functional Description". Developers can also refer to the Code such as DefaultEdgeDispatcher to define their Dispatcher.

### Perform authentication and other business processing

Through the Edge Service workflow, you can see that the Edge Service features can be extended in a variety of ways, including Dispatcher, HttpServerFilter, Handler, HttpClientFilter, and more. More common and straightforward is to extend through Handler. DEMO shows how to implement authentication through Handler extensions. Detailed code details can be found in the following section "DEMO Functional Description".<Paste>

## Deployment example

![](../assets/deployment.png)

## Operating mode

###reactive \(default\)

The Edge Service works by default in the high-performance reactive mode. This mode requires that the business code working in the Edge Service forwarding process cannot have any blocking operations, including:

* Remote synchronization calls, such as an asynchronous query database, synchronous call microservices, or synchronous query remote cache, etc.

* any sleep call

* any wait call

* Oversized loop

The underlying Edge Service is based on netty's vertx. The above constraint is netty's reactive mode constraint.

![](../assets/reactive.png)

### Thread Pool

If the business model cannot meet the reactive requirements, you need to use the thread pool mode.

In this case, you need to configure it in the microservice.yaml of the Edge Service:

```
servicecomb:
  executors:
    default: servicecomb.executor.groupThreadPool
```

Here servicecomb.executor.groupThreadPool is the beanId of the spring bean corresponding to the default thread pool built into ServiceComb; the service can customize its thread pool and declare it as a bean whose beanId can also be configured here.

![](../assets/threadPool.png)

## DEMO Function Description

Please refer to the edge service demo on GitHub:

[https://github.com/ServiceComb/ServiceComb-Java-Chassis/tree/master/demo/demo-edge](https://github.com/ServiceComb/ServiceComb-Java-Chassis/tree/master/demo/demo-edge)

The demo contains the following projects:

* authentication: microservice: authentication server
* edge-service
* hiboard-business-1.0.0 microservices: business, version 1.0.0, operation add
* hiboard-business-1.1.0 microservices: business, version 1.1.0, operation add/dec
* hiboard-business-2.0.0 microservices: business, version 2.0.0, operation add/dec
* hiboard-consumer as a normal httpclient, not a servicecomb consumer
* hiboard-model non-micro service, just some public models

Access different versions of microservices through edge-service and confirm that the correct instance handles them.

### 1.Register Dispatcher

Implement the interface org.apache.servicecomb.transport.rest.vertx.VertxHttpDispatcher, or inherit from org.apache.servicecomb.edge.core.AbstractEdgeDispatcher to implement your own dispatcher function.

The implementation class is registered to the system through the Java standard SPI mechanism.

Dispatcher needs to implement 2 methods:

* ### getOrder

Dispatcher needs to inject routing rules into vertx, and routing rules have a priority order relationship.

All Dispatchers in the system are sorted according to the return value of getOrder from small to large and initialized in order.

If the GetOrder return values the two Dispatchers are the same, the order of the two is unpredictable.

* ### init

The init method is included in the io.vertx.ext.web.The router in the vertx framework. You need to customize the routing rules through this object.

You can specify the url that meets the requirements, whether you need to process the cookie, whether you need to handle the body, which custom method to use to process the received request, etc.

For more details on routing rules, please refer to the official vertx documentation: [vertx routing mechanism] (http://vertx.io/docs/vertx-web/java/#_routing_by_exact_path)

_prompt:_

_ Multiple Dispatchers can set routing rules to cover the same url. _

_Assuming Dispatcher A and B can both handle the same url, and A has a higher priority, then: _

* _ If A is processed, neither responding nor calling RoutingContext.next\(\), it is a bug, this request is hanged _

* _ If A is processed and then calling RoutingContext.next\(\), the request will be transferred to B.

### 2. Forwarding request

When registering a route, it specifies which method is used to process the request (the following method is used to refer to the method), and the forwarding logic is implemented in the onRequest.

The method prototype is:

```
void onRequest(RoutingContext context)
```

The system encapsulates org.apache.servicecomb.edge.core.EdgeInvocation to implement forwarding. At least the following parameters need to be prepared:

* microserviceName, the business makes its own rules, can be passed in the url, or according to the url search, etc.

* context, that is, the input of onRequest

* path, the url of the forwarding target

* httpServerFilters, the Dispatcher parent class has initialized member variables

```
  EdgeInvocation edgeInvocation = new EdgeInvocation();
  edgeInvocation.init(microserviceName, context, path, httpServerFilters);
  edgeInvocation.edgeInvoke();
```

The edgeInvoke call is internally called and will be forwarded as a ServiceComb standard consumer.

As a standard consumer, it means that the governance capabilities of all ServiceComb standards are valid here.

### 3. Setting compatibility rules

Different services may have different compatibility plans, servicecomb default compatibility rules, and all new versions are required to be compatible with the old version. If this requirement is met, no special settings need to be made.

There is also a typical plan:

* 1.0.0-2.0.0 is internally compatible, url is in the form of /microserviceName/v1/....

* 2.0.0-3.0.0 is internally compatible, url is in the form of /microserviceName/v2/....

   ......

Incompatible between major versions

At this point, the developer needs to set compatibility rules for EdgeInvocation:

```
private CompatiblePathVersionMapper versionMapper = new CompatiblePathVersionMapper();

……

edgeInvocation.setVersionRule(versionMapper.getOrCreate(pathVersion).getVersionRule());
```

The role of versionMapper is to convert a string such as v1 or v2 to a compatibility rule such as 1.0.0-2.0.0 or 2.0.0-3.0.0.

**note:**

Incompatible interfaces can cause many problems. The java chassis requires that the higher version of the service is compatible with the lower version of the service, and only allows the addition of the interface to not allow the interface to be deleted. After adding an interface, you must increase the version number of the microservice. In the development phase, interfaces change frequently, and developers often forget this rule. When this constraint is broken, you need to clean up the service center microservices information and restart the microservices and Edge Service\ (and other services that depend on the microservices). Otherwise, the request forwarding failure may occur.

### 4.Authentication

The Edge Service is the boundary of the system and requires authentication logic for many requests.

Based on the standard ServiceComb mechanism, this function can be implemented by the handler.

The simplest code is as follows:

```
public class AuthHandler implements Handler {
 private Auth auth;

 public AuthHandler() {
 auth = Invoker.createProxy("auth", "auth", Auth.class);
 }
……

 @Override
 public void handle(Invocation invocation, AsyncResponse asyncResp) throws Exception {
 if (!auth.auth("")) {
 asyncResp.consumerFail(new InvocationException(Status.UNAUTHORIZED, (Object) "auth failed"));
 return;
 }

 LOGGER.debug("auth success.");
 invocation.next(asyncResp);
 }
}
```

Auth is the interface provided by the authentication microservice. Invoker.createProxy\("auth", "auth", Auth.class\) is the underlying api of the consumer in the transparent RPC development mode, which is equivalent to @ReferenceRpc, but not Need to rely on the spring bean mechanism.

The business completely defines the Auth interface, but here is just an example.

After the Handler development is complete, configure it into the microservice.yaml of the edge service:

```
servicecomb:
  handler:
    chain:
      Consumer:
        default: auth,……
        service:
          auth: ……
```

In this example, it means that the forwarding request to all microservices must be authenticated, but authentication is not required when calling the authentication microservice.
