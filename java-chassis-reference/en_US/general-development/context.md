# Delivery Messages through Context

ServiceComb provides a Context to delivery data between microservices. Context is a key/value pair and can only use data of type String. Since the Context is serialized into the Json format and passed through the HTTP header, characters other than ASCII are not supported. Other characters require the developer to encode and pass the code. The Context is passed on the request chain in a single request and does not need to be reset. The functions such as trace id of [access log](../build-provider/access-log-configuration.md) are implemented based on this feature.

## Scenario
* In the authentication scenario, after the Edge Service authentication is passed, the session ID, username, and other information need to be passed to the microservice to implement authentication and other logic.
* Grayscale publishing scenarios, need to be combined with custom tags shunt request, tag information needs to be passed to the microservices

## Use Reference

* Get and set the Context in Handler

The Handler contains the Invocation object, which can be called directly in the invocation.addContext and invocation.getContext settings.

* Get Context in the service interface

Inject through the interface
```
public Response cseResponse(InvocationContext c1)
```
or
```
ContextUtils.getInvocationContext()
```

* Set the Context in the Edge Service

By override EdgeInvocation
```
EdgeInvocation edgeInvocation = new EdgeInvocation() {
  protected void createInvocation() {
    super.createInvocation();
    this.invocation.addContext("hello", "world");
  }
};
```
