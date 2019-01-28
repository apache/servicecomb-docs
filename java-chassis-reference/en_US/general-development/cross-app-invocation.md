# Cross App Invocation
## Concept Description

An application is a layer in the microservice instance isolation hierarchy, and an application contains multiple microservices. By default, only microservice instances of the same application are allowed to call each other.

## Scenario

When a user needs micro-services between different applications to call each other, it is necessary to enable the cross-application calling function.

## Configuration instructions

To enable cross-application calls, you first need to enable cross-application call configuration in the microservice.yaml file on the provider side.
 
_Note_:  
* Need to upgrade the micro service version number to re-register micro service information in the service center
* Even in the development development environment, you need to upgrade the microservice version number, because in the development environment, only the contract changes, will re-register the contract
  
The configuration items are as follows:
```yaml
service_description:
  # other configuration omitted
  properties:
    allowCrossApp: true # enable cross-app invocation
```

When the consumer client specifies the microservice name to call the provider, it needs to add the application ID to which the provider belongs, and the format becomes `[appID]:[microserviceName]`.

## Sample Code

The example assumes that the application to which the provider belongs is helloApp, the name of the microservice is helloProvider, the application to which the consumer belongs is helloApp2, and the name of the microservice is helloConsumer.

- RestTemplate invocation mode

  When the consumer client develops the microservice consumer in the RestTemplate mode, you need to change `[microserviceName]` to `[appID]:[microserviceName]` in the called URL. The code example is as follows:
  ```java
    RestTemplate restTemplate = RestTemplateBuilder.create();

    ResponseEntity<String> responseEntity = restTemplate
        .getForEntity("cse://helloApp:helloProvider/hello/sayHello?name={name}",
            String.class, "ServiceComb");
  ```
- RPC invocation mode
  When the consumer client develops a microservice consumer in RPC mode, the declared service provider proxy is as follows:
  ```java
    @RpcReference(schemaId = "hello", microserviceName = "helloApp:helloProvider")
    private Hello hello;
  ```
  Cross-application invocation is the same way as invocate microservices under the same application:
  
  ```java
    hello.sayHello("ServiceComb");
  ```
