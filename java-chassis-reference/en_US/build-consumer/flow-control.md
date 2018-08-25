## Flow Control Policy
### Scenario

You can limit the frequency of request send to specific microservice when flow control was enables in consumer service. 

### Precaution

See detail info at [Service Configurations](/users/service-configurations/#限流策略)。

### Configuration

Flow control policy configuration is in microservice.yaml file. You need to configure consumer handler in chain of service. See example blow:

```yaml
servicecomb:
  handler:
    chain:
      Consumer:
        default: qps-flowcontrol-consumer
```

Configuration items of QPS:

| Configuration Item                       | Default Value         | Value Range             | Mandatory | Description                              | Remark                                   |
| :--------------------------------------- | :-------------------- | :---------------------- | :-------- | :--------------------------------------- | :--------------------------------------- |
| servicecomb.flowcontrol.Consumer.qps.enabled     | true                  | Boolean                 | No        | Specifies whether consumers flowcontrol enables. | -                                        |
| servicecomb.flowcontrol.Consumer.qps.limit.[ServiceName].[Schema].[operation] | 2147483647  (max int) | (0,2147483647], Integer | No        | Specifies number of requests per second. | Support three level configurations: microservice、schema、operation. |