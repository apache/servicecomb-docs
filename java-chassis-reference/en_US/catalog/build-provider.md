## [Service Definition](/build-provider/definition/service-definition.html)
• Service definition information is the identity of the microservice, which defines which application the service belongs to, as well as the name and version. The service definition information may also have extension information for defining attribute metadata of the service.
 

## [Defining Service Contracts](/build-provider/define-contract.html)
• Service contract, which refers to the micro-service interface contract based on the OpenAPI specification, which is the definition of the interface between the server and the consumer. The java chassis provides two ways to define contracts: code first and contract first.


## [Use implicit contract](/build-provider/code-first.html)
• The downgrade strategy is the exception handling strategy used by the microservice when the service request is abnormal.


## [Using Swagger Annotations](/build-provider/swagger-annotation.html)
• Swagger provides a set of annotations to describe the interface contract. Users can use annotations to add descriptions of contracts to the code. ServiceComb supports some of these annotations.


## [Developing microservices with SpringMVC](/build-provider/springmvc.html)
• ServiceComb supports SpringMVC annotations, allowing the development of microservices using SpringMVC style. It is recommended to read the project in detail with reference to the project SpringMVC.

## [Developing microservices with JAX-RS](/build-provider/jaxrs.html)
• ServiceComb supports developers using JAX-RS annotations to develop services using JAX-RS patterns.

## [Developing microservices with transparent RPC](/build-provider/transparent-rpc.html)
• The transparent RPC development model is a development model based on interfaces and interfaces. Service developers do not need to use Spring MVC and JAX-RS annotations.

## [interface definition and data type](/build-provider/swagger-annotation.html)
• ServiceComb-Java-Chassis suggests that the interface definition follows a simple principle: the interface definition is the interface usage specification, and you can identify how to call this interface without looking at the code implementation. It can be seen that this principle stands on the user side and is easier to use as a reference. ServiceComb will generate interface contracts based on interface definitions, interfaces that conform to this principle, and the generated contracts are also easy for users to read.

## [Service Listening Address and Publishing Address](/build-provider/listen-address-and-publish-address.html)
• In JavaChassis, the listening and publishing addresses of the service are two separate concepts that can be configured independently:

Listening address: refers to the address that the microservice instance listens to when it starts. This configuration item determines which IPs can be accessed by this IP.
Publish address: refers to the address where the microservice instance is registered to the service center. Other microservice instances will obtain information about this instance through the service center and access the service instance based on the publication address, so this configuration item determines which IP other services actually use to access the service.

## [Service Configuration](/build-provider/service-configuration.html)

• [Load Balancing Policy](/build-provider/configuration/lb-strategy.html)
• [Limiting Policy](/build-provider/configuration/ratelimite-strategy.html)
• [Downgrade Strategy](/build-provider/configuration/downgrade-strategy.html)
• [Parameters and Research](/build-provider/configuration/parameter-validator.html)