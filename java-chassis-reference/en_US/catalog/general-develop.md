## Access Service Center
The system realizes the discovery between services through the service center. During the service startup process, the service center is registered. When calling other services, the service center will query the instance information of other services, such as the access address, the protocol used, and other parameters. The service center supports the use of PULL and PUSH modes to notify instance changes.

## Application Performance Monitoring
 1. The introduction of Metrics
 2. The summary of statistical items
 3. The usage


## Micro Service Call Chain
The microservices architecture solves the problems of many single applications, but it also requires us to pay extra. Request processing latency due to network instability is one of the costs.

In a single application, all modules run in the same process, so there is no inter-module interworking problem. However, in the micro-service architecture, services communicate through the network, so we have to deal with network-related issues such as delays, timeouts, network partitions, and so on.

In addition, as the business expands its services, it is difficult to see how data flows through a spider-like complex service structure. How can we effectively monitor network latency and visualize data flow in services?

Distributed call chain tracking is used to effectively monitor network latency for microservices and visualize data flow in microservices.

## Custom call chain management
Distributed call chain tracking provides timing information for calls between services, but the link call information inside the service is equally important to the developer. If you can combine the two into one, you can provide a more complete call chain, which is easier to locate. Errors and potential performance issues.
  
## Local development and testing
This section describes how to develop and debug consumer/provider applications locally on the developer side. For development service providers, please refer to the section 3 Development Service Providers. For development service consumers, please refer to 4 Development Service Consumers. Both the service provider and the consumer provider need to connect to the remote service center. For the development and debugging of local microservices, this section describes two ways to set up a local service center for local microservices debugging:


## Http Filter
In some scenarios, the service uses http instead of https as the network transmission channel. In order to prevent the falsification or tampering request, the signature function of the http code stream between the consumer and the producer needs to be provided.

 
## File Upload
File upload, currently supported in vertx rest channel and servlet rest.
File uploads use the standard http form format, which interfaces directly with the browser's upload.

## Download Document
File downloads are currently available in the vertx rest channel and servlet rest.


## Reactive
Comparison and description between simple synchronization mode, nested synchronous call, pure Reactive mechanism, and hybrid Reactive mechanism.


## DNS Custom Configuration
When a user uses a domain name to connect to a Huawei public cloud or a three-party system, you need to use the domain name resolution system. The domain name resolution mechanisms used in different systems and different frameworks may be different. Therefore, it is necessary to provide a unified configuration entry so that development and operation personnel can customize the DNS resolution mechanism without being completely subject to system configuration.

## Proxy settings
As a developer, in a company development environment, it is possible to access the Internet through a corporate agent network. If you must also rely on online resources when debugging services, such as directly connecting to Huawei's shared cloud service center, you must configure the agent.


## Frame report version number
In order to facilitate the management, using ServiceComb for development, the currently used ServiceComb version number will be reported to the service center, and the version number of other frameworks will be reported when other frameworks integrate ServiceComb.

## Cross-application call
An application is a layer in the microservice instance isolation hierarchy, and an application contains multiple microservices. By default, only microservice instances of the same application are allowed to call each other.


## Custom Serialization and Deserialization Methods
Due to the non-security of the HTTP protocol, data transmitted over the network can be easily monitored by various packet capture tools. In practical applications, services have high security requirements for sensitive data transmitted between applications or services. Such data requires special encryption protection (different services have different algorithm requirements), so that even if the content is intercepted, it can protect Sensitive data is not easily obtained.


## Using Context to pass control messages
ServiceComb provides a Context to pass data between microservices. Context is a key/value pair and can only use data of type String. Since the Context is serialized into the json format and passed through the HTTP header, characters other than ASCII are not supported. Other characters require the developer to encode and pass the code. The Context is passed on the request chain in a single request and does not need to be reset. Functions such as the trace id of the access log are implemented based on this feature.


## return value serialization extension
The current REST channel return value supports both application/json and text/plain formats, supports developer extensions and rewrites, service providers provide serialization capabilities through producer declarations, and service consumers specify return value serialization through the request's Accept header. By default, the data in application/json format is returned.


## CORS mechanism
Cross-Origin Resource Sharing (CORS) allows Web servers to perform cross-domain access control, enabling browsers to more securely transfer data across domains.


## Obtaining the fuse and instance isolation alarm event information
When the microservice is running or the instance isolation status changes, you need to listen to related events, get relevant information and process it.
