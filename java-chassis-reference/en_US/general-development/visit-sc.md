## Concept Description

The system realizes the discovery between services through the service center. During the service startup process, the service center is registered. When calling other services, the service center will query the instance information of other services, such as the access address, the protocol used, and other parameters. The service center supports the use of PULL and PUSH modes to notify instance changes.



## Configuration instructions



### Table 1-1 Accessing Common Configuration Items in the Configuration Center

| Configuration Item | Reference / Default | Value Range | Required | Meaning |
| :--- | :--- | :--- | :--- | :--- | :--- |
| servicecomb.service.registry.address | http://127.0.0.1:30100 | | Yes | Service center address information, you can configure multiple, separated by commas. | |
| servicecomb.service.registry.instance. Watch | true | | No | Whether to monitor instance changes in PUSH mode. When it is false, it means using PULL mode. | |
| servicecomb.service.registry. Autodiscovery | false | | No | Whether to automatically discover the address of the service center. This configuration is enabled when a partial address needs to be configured, and other addresses are discovered by the configured service center instance. | |
| servicecomb.service.registry.instance.healthCheck.interval | 30 | | No | Heartbeat interval. | |
| servicecomb.service.registry.instance.healthCheck.times | 3 | | No | Number of allowed heartbeat failures. Interval \* times determines when the instance is automatically logged out. If the service center waits for such a long time and does not receive a heartbeat, the instance will be logged off. | |
