## Thread Model
### Concept Description

This section describes the thread model for ServiceComb microservices and the relationship between the I/O and service threads.

### Thread Model

The complete thread model of CSE is shown in the following figure.

![](/assets/images/thread-model-en.png)

> 1. When a service thread is called for the first time, it binds to a network thread to avoid thread conflicts caused by switching among different network threads.
> 2. After the service thread bound to a network thread, it will bind to a connection of the network to avoid thread conflicts.

* Multiple network threads (eventloop) can be bound to both the client and the server. The number of network threads is two times the quantity of the CPU cores by default. Multiple connections can be configured for each network thread, and the default number is 1. The Rest and Highway network channels are supported. For details about these configurations, see following sections:
   * [REST over Servlet](/users/communicate-protocol#rest-over-servlet)
   * [REST over Vertx](/users/communicate-protocol/#rest-over-vertx)
   * [Highway RPC Protocol](/users/communicate-protocol/#highway-rpc协议)
* You can configure the service thread pool executor for the client, and the thread granularity can be schemaId: operation.

Add the executors in the microservice.yaml file and configure an independent service thread pool for schemaId: operation:

```yaml
servicecomb: 
  executors: 
    Provider: 
      [schemaId].[operation]
```
