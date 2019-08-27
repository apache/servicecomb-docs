## Concept Description

The system realizes the discovery between services through the [service center](https://github.com/apache/servicecomb-service-center) . During the service startup process, the service center is registered. When calling other services, the service center will query the instance information of other services, such as the access address, the protocol used, and other parameters. The service center supports the use of PULL and PUSH modes to notify instance changes.

Developers can configure service center clusters addresses, connection parameters, heartbeat management and so on. 

## Configuration instructions



### Table 1-1 Accessing Common Configuration Items in the Configuration Center

| Configuration Item | Reference / Default | Value Range | Required | Meaning |
| :--- | :--- | :--- | :--- | :--- |
| servicecomb.service.registry.address | http://127.0.0.1:30100 | | Yes | Service center address information, you can configure multiple, separated by commas. | |
| servicecomb.service.registry.instance. Watch | true | | No | Whether to monitor instance changes in PUSH mode. When it is false, it means using PULL mode. | |
| servicecomb.service.registry. Autodiscovery | false | | No | Whether to automatically discover the address of the service center. This configuration is enabled when a partial address needs to be configured, and other addresses are discovered by the configured service center instance. | |
| servicecomb.service.registry.instance.healthCheck.interval | 30 | | No | Heartbeat interval. | |
| servicecomb.service.registry.instance.healthCheck.times | 3 | | No | Number of allowed heartbeat failures. If there is (times + 1) continuous heartbeat failures, this instance will be automatically logged off by service-center, i.e. interval \* (times + 1) determines when the instance is automatically logged off. If the service center waits for such a long time and does not receive a heartbeat, the instance will be logged off. | |
| servicecomb.service.registry.instance.empty.protection | true |  | No | When service center gives empty server list, will not remove local address cache when true. |  |
| servicecomb.service.registry.client.timeout.connection | 30000 |  | Connection timeout in milliseconds |  |  |
| servicecomb.service.registry.client.timeout.request | 30000 |  | Request timeout in milliseconds |  |  |
| servicecomb.service.registry.client.timeout.idle | 60 |  | Connection idle timeout in milliseconds |  |  |
| servicecomb.service.registry.client.timeout.heartbeat | 3000 |  | Heartbeat request timeout in milliseconds |  |  |
| servicecomb.service.registry.client.instances | 1 |  | No | the account of verticle instances that Service Registry Client had been deployed |  |  |
| servicecomb.service.registry.client.eventLoopPoolSize | 4 |  | No | the size of Service Registry client Event Loop pool |  |
| servicecomb.service.registry.client.workerPoolSize | 4 |  | No | the size of Service Registry client worker pool |  |
