# First, the introduction of Metrics

![](/assets/metrics/logicDiagram.png)

1. Based on [netflix spectator](https://github.com/Netflix/spectator)
2. Foundation-metrics loads all MetricsInitializer implementations via the SPI mechanism. Implementers can use the getOrder in the MetricsInitializer to plan the execution order. The smaller the order number, the earlier it will be executed.
3. Metrics-core implements 3 types of MetricsInitializer:
  1. DefaultRegistryInitializer: Instantiate and register spectator-reg-servo, set a smaller order, and ensure that it is executed before the following two types of MetricsInitializer
  2. Meters Initializer: Statistics of data such as TPS, delay, thread pool, jvm resources, etc.
  3. Publisher: Output statistics, built-in log output, and output via RESTful interface
  4. Metrics-prometheus provides the ability to interface with prometheus

# Second, the summary of statistical items
<table border="1" style="font-size: 8px">
  <tr>
    <th>Name</th>
    <th>Tag keys</th>
    <th>Tag values</th>
    <th style="min-width: 450px">meaning</th>
  </tr>
  <tr>
    <td rowspan="11">servicecomb.invocation</td>
    <td>role</td>
    <td>CONSUMER、PRODUCER</td>
    <td>Is the CONSUMER or the statistics of the PRODUCER side?</td>
  </tr>
  <tr>
    <td>operation</td>
    <td>${microserviceName}.${schemaId}.${operationName}</td>
    <td>Method name</td>
  </tr>
  <tr>
    <td>transport</td>
    <td>highway or rest</td>
    <td>On which transmission channel the call occurs</td>
  </tr>
  <tr>
    <td rowspan="3">stage</td>
    <td>total</td>
    <td>Full process statistics</td>
  </tr>
  <tr>
    <td>queue</td>
    <td>It only makes sense to call the statistics queued in the producer thread pool when using the thread pool on the producer side.</td>
  </tr>
  <tr>
    <td>execution</td>
    <td>Statistically representing the execution of business logic only on the producer side</td>
  </tr>
  <tr>
    <td>status</td>
    <td>http status code</td>
    <td></td>
  </tr>
  <tr>
    <td rowspan="4">statistic</td>
    <td>count</td>
    <td>Average number of calls per second, ie TPS<br>count=Number of calls/cycles in the statistical period (seconds)</td>
  </tr>
  <tr>
    <td>totalAmount</td>
    <td> in seconds<br>totalAmount=Total timeout/cycle (in seconds) for calls in the statistical period<br>totalAmount divided by count to get the average delay</td>
  </tr>
  <tr>
    <td>totalOfSquares </td>
    <td>totalOfSquares=sum of squares of each call in the statistical period/cycle (seconds)</td>
  </tr>
  <tr>
    <td>max</td>
    <td>The maximum call time in the statistical period, in seconds</td>
  </tr>
  <tr>
    <td>threadpool.taskCount</td>
    <td rowspan="7">id</td>
    <td rowspan="7">${threadPoolName}</td>
    <td>Average number of tasks submitted per second during the statistical period<br>taskCount=(completed + queue + active)/period (seconds)</td>
  </tr>
  <tr>
    <td>threadpool.completedTaskCount </td>
    <td>The average number of tasks completed per second during the statistical period<br>completedTaskCount=completed/cycle (seconds)</td>
  </tr>
  <tr>
    <td>threadpool.currentThreadsBusy </td>
    <td>The current number of active threads, ie the number of tasks currently being executed</td>
  <tr>
    <td>threadpool.maxThreads </td>
    <td>Maximum number of threads allowed</td>
  </tr>
  <tr>
    <td>threadpool.poolSize </td>
    <td>The current actual number of threads</td>
  </tr>
  <tr>
    <td>threadpool.corePoolSize  </td>
    <td>Minimum number of threads</td>
  </tr>
  <tr>
    <td>threadpool.queueSize </td>
    <td>Number of tasks currently queued</td>
  </tr>
</table>

# Third, how to use.

1.Maven dependence.

```
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>metrics-core</artifactId>
  <version>1.0.0-m2</version>
</dependency>
```

_Note: Please change the version field to the actual version number; if the version number has been declared in the dependencyManagement, then you do not have to write the version number here_

2. Configuration instructions

| Configuration Item | Default | Meaning |
| :--- | :--- | :--- |
| Servicecomb.metrics.window\_time | 60000 | Statistical period, in milliseconds TPS, delay, etc. Periodic data, updated once per cycle, the value obtained in the cycle, actually the value of the previous cycle |
| servicecomb.metrics.publisher.defaultLog.enabled | false | Whether to output the default statistics log |

3. Access via RESTful
As long as the microservices open the rest port, use a browser to access http://ip:port/metrics.
will get json data in the following format:

```
{
"threadpool.taskCount(id=servicecomb.executor.groupThreadPool-group0)":7393.0,
"threadpool.taskCount(id=servicecomb.executor.groupThreadPool-group1)":8997.0,
"threadpool.currentThreadsBusy(id=servicecomb.executor.groupThreadPool-group0)":1.0,
"threadpool.currentThreadsBusy(id=servicecomb.executor.groupThreadPool-group1)":0.0,
"threadpool.poolSize(id=servicecomb.executor.groupThreadPool-group0)":8.0,
"threadpool.poolSize(id=servicecomb.executor.groupThreadPool-group1)":8.0,
"threadpool.completedTaskCount(id=servicecomb.executor.groupThreadPool-group0)":7393.0,
"threadpool.completedTaskCount(id=servicecomb.executor.groupThreadPool-group1)":8997.0,
"threadpool.maxThreads(id=servicecomb.executor.groupThreadPool-group0)":8.0,
"threadpool.maxThreads(id=servicecomb.executor.groupThreadPool-group1)":8.0,
"threadpool.queueSize(id=servicecomb.executor.groupThreadPool-group0)":0.0,
"threadpool.queueSize(id=servicecomb.executor.groupThreadPool-group1)":0.0,
"threadpool.corePoolSize(id=servicecomb.executor.groupThreadPool-group0)":8.0,
"threadpool.corePoolSize(id=servicecomb.executor.groupThreadPool-group1)":8.0,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=total,statistic=count,status=200,transport=rest)":11260.0,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=total,statistic=totalTime,status=200,transport=rest)":0.38689718700000003,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=total,statistic=totalOfSquares,status=200,transport=rest)":1.4702530122919001E-5,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=total,statistic=max,status=200,transport=rest)":2.80428E-4,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=execution,statistic=count,status=200,transport=rest)":11260.0,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=execution,statistic=totalTime,status=200,transport=rest)":0.291562031,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=execution,statistic=totalOfSquares,status=200,transport=rest)":8.357214743065001E-6,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=execution,statistic=max,status=200,transport=rest)":2.20962E-4,
"servicecomb.invocation(operation=perf1.metricsEndpoint.measure,role=PRODUCER,stage=execution,statistic=count,status=200,transport=rest)":4.0,
"servicecomb.invocation(operation=perf1.metricsEndpoint.measure,role=PRODUCER,stage=execution,statistic=totalTime,status=200,transport=rest)":0.008880438000000001,
"servicecomb.invocation(operation=perf1.metricsEndpoint.measure,role=PRODUCER,stage=execution,statistic=totalOfSquares,status=200,transport=rest)":2.0280434311212E-5,
"servicecomb.invocation(operation=perf1.metricsEndpoint.measure,role=PRODUCER,stage=execution,statistic=max,status=200,transport=rest)":0.002701049,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=total,statistic=count,status=200,transport=rest)":11260.0,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=total,statistic=totalTime,status=200,transport=rest)":1.963073303,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=total,statistic=totalOfSquares,status=200,transport=rest)":3.54540250685325E-4,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=total,statistic=max,status=200,transport=rest)":0.001611332,
"servicecomb.invocation(operation=perf1.metricsEndpoint.measure,role=PRODUCER,stage=queue,statistic=count,status=200,transport=rest)":4.0,
"servicecomb.invocation(operation=perf1.metricsEndpoint.measure,role=PRODUCER,stage=queue,statistic=totalTime,status=200,transport=rest)":4.1958E-5,
"servicecomb.invocation(operation=perf1.metricsEndpoint.measure,role=PRODUCER,stage=queue,statistic=totalOfSquares,status=200,transport=rest)":4.52399726E-10,
"servicecomb.invocation(operation=perf1.metricsEndpoint.measure,role=PRODUCER,stage=queue,statistic=max,status=200,transport=rest)":1.2075E-5,
"servicecomb.invocation(operation=perf1.metricsEndpoint.measure,role=PRODUCER,stage=total,statistic=count,status=200,transport=rest)":4.0,
"servicecomb.invocation(operation=perf1.metricsEndpoint.measure,role=PRODUCER,stage=total,statistic=totalTime,status=200,transport=rest)":0.008922396,
"servicecomb.invocation(operation=perf1.metricsEndpoint.measure,role=PRODUCER,stage=total,statistic=totalOfSquares,status=200,transport=rest)":2.0470212584674E-5,
"servicecomb.invocation(operation=perf1.metricsEndpoint.measure,role=PRODUCER,stage=total,statistic=max,status=200,transport=rest)":0.002713123,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=queue,statistic=count,status=200,transport=rest)":11260.0,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=queue,statistic=totalTime,status=200,transport=rest)":0.095335156,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=queue,statistic=totalOfSquares,status=200,transport=rest)":1.0722599763800001E-6,
"servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=queue,statistic=max,status=200,transport=rest)":2.0858600000000003E-4
}
```


# Fourth, business customization

Because ServiceComb has initialized the registry's registry, the business no longer has to create a registry.

Implement the MetricsInitializer interface, define the business-level Meters, or implement a custom Publisher, and then declare your implementation through the SPI mechanism.

1.Meters:
Creating Meters capabilities is provided by spectator, available in the [netflix spectator] (https://github.com/Netflix/spectator) documentation

2.Publisher:
Periodically output scenarios, such as log scenarios, subscribe to org.apache.servicecomb.foundation.metrics.PolledEvent via eventBus, PolledEvent.getMeters() is the statistical result of this cycle.
Non-periodic output scenarios, such as access through the RESTful interface, the statistical results of this cycle can be obtained through globalRegistry.iterator()
