## Fault Injection
### Scenario
The user via fault injection on the consumer side to set the delay and error of the request to the specified microservice and its trigger probability.

## Precautions

The delay time for delay injection requests is unified to the millisecond level.

## Configuration instructions

The fault injection configuration is in the microservice.yaml file. The related configuration items are shown in the following table. To enable fault injection in the service consumer, you need to configure the consumer fault injection handler in the processing chain. The configuration example is as follows:

```yaml
servicecomb:
  handler:
    chain:
      Consumer:
        default: loadbalance,fault-injection-consumer
```

Fault injection configuration item description

\[scope\] represents the effective scope of the fault injection. The configurable value includes the global configuration \_global or the service name of the microservice \[ServiceName\].

\[protocol\] represents the communication protocol used, and configurable values ​​include rest or highway.

| Configuration Item | Default Value | Range of Value | Required | Meaning |
| :--- | :--- | :--- | :--- | :--- | :--- |
| servicecomb.governance.Consumer.\[scope\].policy.fault.protocols.\[protocol\].delay.fixedDelay | None | \(0,9223372036854775807\], Long Shaping | No | Consumer Send Delay Injection Request Delay time | current time unit is milliseconds |
| servicecomb.governance.Consumer.\[scope\].policy.fault.protocols.\[protocol\].delay.percent | 100 | \(0,100\], Shaping | No | Trigger Probability of Sending Delay Injection Requests by Consumers | |
| servicecomb.governance.Consumer.\[ServiceName\].schemas.\[schema\].policy.fault.protocols.\[protocol\].delay.fixedDelay | None | \(0,9223372036854775807\], Long Shaping| No | Delay time for delay injection request sent by the consumer to the corresponding schema | Support for schema level configuration |
| servicecomb.governance.Consumer.\[ServiceName\].schemas.\[schema\].policy.fault.protocols.\[protocol\].delay.percent | 100 | \(0,100\],Plastic| No| Consumer Trigger probability of a delayed injection request sent by the end to the corresponding schema | Support for schema level configuration |
| servicecomb.governance.Consumer.\[ServiceName\].schemas.\[schema\].operations.\[operation\].policy.fault.protocols.\[protocol\].delay.fixedDelay | None | \(0 ,9223372036854775807\],long shaping| no|delay time of delay injection request sent by the consumer to the corresponding operation | support operation level configuration |
| servicecomb.governance.Consumer.\[ServiceName\].schemas.\[schema\].operations.\[operation\].policy.fault.protocols.\[protocol\].delay.percent | 100 | \(0,100 \], shaping|no| trigger probability of delay injection request sent by the consumer to the corresponding operation | support operation level configuration |
| servicecomb.governance.Consumer.\[scope\].policy.fault.protocols.\[protocol\].abort.httpStatus | None | \(100,999\], Shaping | No | The http error sent by the Consumer to send an error injection request Code| |
| servicecomb.governance.Consumer.\[scope\].policy.fault.protocols.\[protocol\].abort.percent | 100 | \(0,100\], Shaping | No | Trigger Probability of Sending Error Injection Requests by Consumers | |
| servicecomb.governance.Consumer.\[ServiceName\].schemas.\[schema\].policy.fault.protocols.\[protocol\].abort.httpStatus | None | \(100,999\],Plastic| No| Consumer Http error code sent by the end to the corresponding schema error injection request | Support schema level configuration |
| servicecomb.governance.Consumer.\[ServiceName\].schemas.\[schema\].policy.fault.protocols.\[protocol\].abort.percent | 100 | \(0,100\],Plastic| No| Consumer Trigger probability of error injection request sent by the end to the corresponding schema | Support schema level configuration |
| servicecomb.governance.Consumer.\[ServiceName\].schemas.\[schema\].operations.\[operation\].policy.fault.protocols.\[protocol\].abort.httpStatus | None | \(100,999 \], shaping | No | http error code sent by the consumer to the error injection request of the corresponding operation | Support operation level configuration |
| servicecomb.governance.Consumer.\[ServiceName\].schemas.\[schema\].operations.\[operation\].policy.fault.protocols.\[protocol\].abort.percent | 100 | \(0,100 \], shaping | No | Trigger probability of error injection request sent by the consumer to the corresponding operation | Support operation level configuration |

## Sample Code

```
servicecomb:
  governance:
    Consumer:
      _global:
        policy:
          fault:
            protocols:
              rest:
                delay:
                  fixedDelay: 5000
                  percent: 10
```

```
servicecomb:
  governance:
    Consumer:
      ServerFaultTest:
        schemas:
          schema:
            operations:
              operation:
                policy:
                  fault:
                    protocols:
                      rest:
                        abort:
                          httpStatus: 421
                          percent: 100
```
