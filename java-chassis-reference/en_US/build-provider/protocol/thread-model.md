## Thread Model
### Concepts

This section describes ServiceComb's microservice thread model and the relationship between the I/O and service threads.

### Thread Model

The complete thread model of ServiceComb is shown below:

![](/assets/images/thread-model-en.png)

> 1. When a service thread is called for the first time, it binds to a network thread to avoid thread conflicts caused by switching different network threads.
> 2. After the binding to a network thread, the service thread will also bind to a connection of the network thread, to avoid thread conflicts.

* Multiple network threads (eventloop) can be bound to both client and server. The number of network threads is two times of the CPU cores by default. Multiple connections can be configured for each network thread, and the default connection number is 1. The Rest and Highway network channels are supported. For details about these configurations, see following sections:
   * [REST over Servlet](/users/communicate-protocol#rest-over-servlet)
   * [REST over Vertx](/users/communicate-protocol/#rest-over-vertx)
   * [Highway RPC Protocol](/users/communicate-protocol/#highway-rpc协议)
* You can configure the service thread pool executor for the server,  the configuration can be applied to schemaId: operation.

Add the executors in the microservice.yaml file and configure an independent service thread pool for schemaId: operation:

```yaml
servicecomb: 
  executors: 
    Provider: 
      [schemaId].[operation]
```
