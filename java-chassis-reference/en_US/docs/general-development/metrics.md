# First, the introduction of Metrics

![](../assets/metrics/logicDiagram.png)

1. Based on [netflix spectator](https://github.com/Netflix/spectator)
2. Foundation-metrics loads all MetricsInitializer implementations via the SPI mechanism. Implementers can use the getOrder in the MetricsInitializer to plan the execution order. The smaller the order number, the earlier it will be executed.
3. Metrics-core implements 3 types of MetricsInitializer:
  1. DefaultRegistryInitializer: Instantiate and register spectator-reg-servo, set a smaller order, and ensure that it is executed before the following two types of MetricsInitializer
  2. Meters Initializer: Statistics of data such as TPS, delay, thread pool, jvm resources, etc.
  3. Publisher: Output statistics, built-in log output, and output via RESTful interface
  4. Metrics-prometheus provides the ability to interface with prometheus

# Second, how to use.

### 1.Maven dependence.

```
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>metrics-core</artifactId>
</dependency>
```
If integrate with prometheus, also need to add dependencies.
```
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>metrics-prometheus</artifactId>
</dependency>
```

_Note: Please change the version field to the actual version number; if the version number has been declared in the dependencyManagement, then you do not have to write the version number here_

### 2. Configuration instructions

<div class="metrics-cfg"></div>

| Configuration Item | Default | Meaning |
| :--- | :--- | :--- |
| servicecomb.metrics.window_time | 60000 | Statistical period, in milliseconds<br>TPS, delay, etc. Periodic data, updated once per cycle, the value obtained in the cycle, actually the value of the previous cycle |
| servicecomb.metrics<br>.invocation.latencyDistribution |       | The latency distribution time period definition in milliseconds<br>for example:0,1,10,100,1000<br>indicates that the following latency scopes are defined: [0, 1),[1, 10),[10, 100),[100, 1000),[1000, ) |
| servicecomb.metrics<br>.Consumer.invocation.slow.enabled | false | Whether to enable slow call detection on the Consumer side<br>Level 4 priority definitions can be supported by adding the suffix .${service}.${schema}.${operation} |
| servicecomb.metrics<br>.Consumer.invocation.slow.msTime | 1000 | If the latency exceeds the configured value, the log will be output immediately, and the time consumption information of the stage called this time will be recorded.<br>Level 4 priority definitions can be supported by adding the suffix .${service}.${schema}.${operation} |
| servicecomb.metrics<br>.Provider.invocation.slow.enabled | false | Whether to enable slow call detection on the Provider side<br>Level 4 priority definitions can be supported by adding the suffix .${service}.${schema}.${operation} |
| servicecomb.metrics<br>.Provider.invocation.slow.msTime | 1000 | If the latency exceeds the configured value, the log will be output immediately, and the time consumption information of the stage called this time will be recorded.<br>Level 4 priority definitions can be supported by adding the suffix .${service}.${schema}.${operation} |
| servicecomb.metrics<br>.prometheus.address | 0.0.0.0:9696 | prometheus listen address |
| servicecomb.metrics.publisher.defaultLog<br>.enabled | false | Whether to output the default statistics log |
| servicecomb.metrics.publisher.defaultLog<br>.endpoints.client.detail.enabled | false | Whether to output each client endpoint statistics log, because it is related to the target ip:port number, there may be a lot of data, so the default is not output|
  
### 3. Slow call detection
  After slow call detection is enabled, if there is a slow call, the corresponding log will be output immediately:
```
2019-04-02 23:01:09,103\[WARN]\[pool-7-thread-74]\[5ca37935c00ff2c7-350076] - slow(40 ms) invocation, CONSUMER highway perf1.impl.syncQuery
  http method: GET
  url        : /v1/syncQuery/{id}/
  server     : highway://192.168.0.152:7070?login=true
  status code: 200
  total      : 50.760 ms
    prepare                : 0.0 ms
    handlers request       : 0.0 ms
    client filters request : 0.0 ms
    send request           : 0.5 ms
    get connection         : 0.0 ms
    write to buf           : 0.5 ms
    wait response          : 50.727 ms
    wake consumer          : 0.23 ms
    client filters response: 0.2 ms
    handlers response      : 0.0 ms (SlowInvocationLogger.java:121)
```
  Where 5ca37935c00ff2c7-350076 is the structure of ${traceId}-${invocationId}, referenced by %marker in the output format of log4j2 or logback
  
### 4. Access via RESTful
As long as the microservices open the rest port, use a browser to access http://ip:port/metrics.
will get json data in the following format:

```
{
  "servicecomb.vertx.endpoints(address=192.168.0.124:7070,statistic=connectCount,type=client)": 0.0,
  "servicecomb.vertx.endpoints(address=192.168.0.124:7070,statistic=disconnectCount,type=client)": 0.0,
  "servicecomb.vertx.endpoints(address=192.168.0.124:7070,statistic=connections,type=client)": 1.0,
  "servicecomb.vertx.endpoints(address=192.168.0.124:7070,statistic=bytesRead,type=client)": 508011.0,
  "servicecomb.vertx.endpoints(address=192.168.0.124:7070,statistic=bytesWritten,type=client)": 542163.0,
  "servicecomb.vertx.endpoints(address=192.168.0.124:7070,statistic=queueCount,type=client)": 0.0,

  "servicecomb.vertx.endpoints(address=0.0.0.0:7070,statistic=connectCount,type=server)": 0.0,
  "servicecomb.vertx.endpoints(address=0.0.0.0:7070,statistic=disconnectCount,type=server)": 0.0,
  "servicecomb.vertx.endpoints(address=0.0.0.0:7070,statistic=connections,type=server)": 1.0,
  "servicecomb.vertx.endpoints(address=0.0.0.0:7070,statistic=bytesRead,type=server)": 542163.0,
  "servicecomb.vertx.endpoints(address=0.0.0.0:7070,statistic=bytesWritten,type=server)": 508011.0,
  "servicecomb.vertx.endpoints(address=0.0.0.0:7070,statistic=rejectByConnectionLimit,type=server)": 0.0,
  "servicecomb.vertx.endpoints(address=localhost:8080,statistic=connectCount,type=server)": 0.0,
  "servicecomb.vertx.endpoints(address=localhost:8080,statistic=disconnectCount,type=server)": 0.0,
  "servicecomb.vertx.endpoints(address=localhost:8080,statistic=connections,type=server)": 0.0,
  "servicecomb.vertx.endpoints(address=localhost:8080,statistic=bytesRead,type=server)": 0.0,
  "servicecomb.vertx.endpoints(address=localhost:8080,statistic=bytesWritten,type=server)": 0.0,
  "servicecomb.vertx.endpoints(address=localhost:8080,statistic=rejectByConnectionLimit,type=server)": 0.0,

  "threadpool.completedTaskCount(id=cse.executor.groupThreadPool-group0)": 4320.0,
  "threadpool.rejectedCount(id=cse.executor.groupThreadPool-group0)": 0.0,
  "threadpool.taskCount(id=cse.executor.groupThreadPool-group0)": 4320.0,
  "threadpool.currentThreadsBusy(id=cse.executor.groupThreadPool-group0)": 0.0,
  "threadpool.poolSize(id=cse.executor.groupThreadPool-group0)": 4.0,
  "threadpool.maxThreads(id=cse.executor.groupThreadPool-group0)": 10.0,
  "threadpool.queueSize(id=cse.executor.groupThreadPool-group0)": 0.0,
  "threadpool.corePoolSize(id=cse.executor.groupThreadPool-group0)": 4.0,

  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,scope=[0,1),status=200,transport=highway,type=latencyDistribution)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,scope=[1,3),status=200,transport=highway,type=latencyDistribution)": 0.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,scope=[3,10),status=200,transport=highway,type=latencyDistribution)": 0.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,scope=[10,100),status=200,transport=highway,type=latencyDistribution)": 0.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,scope=[100,),status=200,transport=highway,type=latencyDistribution)": 0.0,

  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,scope=[0,1),status=200,transport=highway,type=latencyDistribution)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,scope=[1,3),status=200,transport=highway,type=latencyDistribution)": 0.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,scope=[3,10),status=200,transport=highway,type=latencyDistribution)": 0.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,scope=[10,100),status=200,transport=highway,type=latencyDistribution)": 0.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,scope=[100,),status=200,transport=highway,type=latencyDistribution)": 0.0,
  
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=total,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=total,statistic=totalTime,status=200,transport=highway,type=stage)": 0.25269420000000004,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=total,statistic=max,status=200,transport=highway,type=stage)": 2.7110000000000003E-4,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=handlers_request,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=handlers_request,statistic=totalTime,status=200,transport=highway,type=stage)": 0.0079627,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=handlers_request,statistic=max,status=200,transport=highway,type=stage)": 1.74E-5,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=handlers_response,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=handlers_response,statistic=totalTime,status=200,transport=highway,type=stage)": 0.0060666,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=handlers_response,statistic=max,status=200,transport=highway,type=stage)": 1.08E-5,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=prepare,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=prepare,statistic=totalTime,status=200,transport=highway,type=stage)": 0.016679600000000003,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=prepare,statistic=max,status=200,transport=highway,type=stage)": 2.68E-5,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=queue,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=queue,statistic=totalTime,status=200,transport=highway,type=stage)": 0.08155480000000001,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=queue,statistic=max,status=200,transport=highway,type=stage)": 2.1470000000000001E-4,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=execution,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=execution,statistic=totalTime,status=200,transport=highway,type=stage)": 0.0098285,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=execution,statistic=max,status=200,transport=highway,type=stage)": 4.3100000000000004E-5,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=server_filters_request,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=server_filters_request,statistic=totalTime,status=200,transport=highway,type=stage)": 0.0170669,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=server_filters_request,statistic=max,status=200,transport=highway,type=stage)": 3.6400000000000004E-5,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=server_filters_response,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=server_filters_response,statistic=totalTime,status=200,transport=highway,type=stage)": 0.0196985,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=server_filters_response,statistic=max,status=200,transport=highway,type=stage)": 4.8100000000000004E-5,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=producer_send_response,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=producer_send_response,statistic=totalTime,status=200,transport=highway,type=stage)": 0.0880885,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=PRODUCER,stage=producer_send_response,statistic=max,status=200,transport=highway,type=stage)": 1.049E-4,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=total,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=total,statistic=totalTime,status=200,transport=highway,type=stage)": 0.9796976000000001,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=total,statistic=max,status=200,transport=highway,type=stage)": 6.720000000000001E-4,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=handlers_request,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=handlers_request,statistic=totalTime,status=200,transport=highway,type=stage)": 0.012601500000000002,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=handlers_request,statistic=max,status=200,transport=highway,type=stage)": 3.5000000000000004E-5,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=handlers_response,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=handlers_response,statistic=totalTime,status=200,transport=highway,type=stage)": 0.0066785,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=handlers_response,statistic=max,status=200,transport=highway,type=stage)": 3.21E-5,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=prepare,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=prepare,statistic=totalTime,status=200,transport=highway,type=stage)": 0.010363800000000001,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=prepare,statistic=max,status=200,transport=highway,type=stage)": 2.85E-5,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=client_filters_request,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=client_filters_request,statistic=totalTime,status=200,transport=highway,type=stage)": 0.0060282,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=client_filters_request,statistic=max,status=200,transport=highway,type=stage)": 9.2E-6,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=consumer_send_request,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=consumer_send_request,statistic=totalTime,status=200,transport=highway,type=stage)": 0.099984,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=consumer_send_request,statistic=max,status=200,transport=highway,type=stage)": 1.1740000000000001E-4,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=consumer_get_connection,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=consumer_get_connection,statistic=totalTime,status=200,transport=highway,type=stage)": 0.006916800000000001,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=consumer_get_connection,statistic=max,status=200,transport=highway,type=stage)": 5.83E-5,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=consumer_write_to_buf,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=consumer_write_to_buf,statistic=totalTime,status=200,transport=highway,type=stage)": 0.0930672,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=consumer_write_to_buf,statistic=max,status=200,transport=highway,type=stage)": 1.1580000000000001E-4,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=consumer_wait_response,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=consumer_wait_response,statistic=totalTime,status=200,transport=highway,type=stage)": 0.7654931,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=consumer_wait_response,statistic=max,status=200,transport=highway,type=stage)": 5.547E-4,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=consumer_wake_consumer,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=consumer_wake_consumer,statistic=totalTime,status=200,transport=highway,type=stage)": 0.0502085,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=consumer_wake_consumer,statistic=max,status=200,transport=highway,type=stage)": 3.7370000000000003E-4,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=client_filters_response,statistic=count,status=200,transport=highway,type=stage)": 4269.0,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=client_filters_response,statistic=totalTime,status=200,transport=highway,type=stage)": 0.0227188,
  "servicecomb.invocation(operation=perf1.impl.syncQuery,role=CONSUMER,stage=client_filters_response,statistic=max,status=200,transport=highway,type=stage)": 4.0E-5
}
```

# Third, the summary of statistical items
### 1. CPU
<table class="metrics-table">
  <tr>
    <th>Name</th>
    <th>Tag keys</th>
    <th>Tag values</th>
    <th>Description</th>
  </tr>
  <tr>
    <td rowspan="2">os</td>
    <td rowspan="2">type</td>
    <td>cpu</td>
    <td>System CPU usage in the current period, Solaris mode</td>
  </tr>
  <tr>
    <td>processCpu</td>
    <td>Microservice process CPU usage in the current period, IRIX mode<br>
        processCpu divided by cpu is equal to the number of system CPUs</td>
  </tr>
</table>

### 2. NET
<table class="metrics-table">
  <tr>
    <th>Name</th>
    <th>Tag keys</th>
    <th>Tag values</th>
    <th>Description</th>
  </tr>
  <tr>
    <td rowspan="6">os</td>
    <td>type</td>
    <td>net</td>
    <td></td>
  </tr>
  <tr>
    <td rowspan="4">statistic</td>
    <td>send</td>
    <td>Average number of bytes sent per second during the current period (Bps)</td>
  </tr>
  <tr>
    <td>receive</td>
    <td>Average number of bytes received per second during the current period (Bps)</td>
  </tr>
  <tr>
    <td>sendPackets</td>
    <td>Average number of packets sent per second (pps) during the current period</td>
  </tr>
  <tr>
    <td>receivePackets</td>
    <td>Average number of packets received per second (pps) during the current period</td>
  </tr>
  <tr>
    <td>interface</td>
    <td></td>
    <td>net dev name</td>
  </tr>
</table>

### 3. vertx client endpoints  
<table class="metrics-table">
  <tr>
    <th>Name</th>
    <th>Tag keys</th>
    <th>Tag values</th>
    <th>Description</th>
  </tr>
  <tr>
    <td rowspan="8">servicecomb<br>.vertx<br>.endpoints</td>
    <td>type</td>
    <td>client</td>
    <td></td>
  </tr>
  <tr>
    <td>address</td>
    <td>${ip}:${port}</td>
    <td>server ip:port</td>
  </tr>
  <tr>
    <td rowspan="6">statistic</td>
    <td>connectCount</td>
    <td>Number of connections have been initiated in the current period</td>
  </tr>
  <tr>
    <td>disconnectCount</td>
    <td>Number of disconnections in the current period</td>
  </tr>
  <tr>
    <td>queueCount</td>
    <td>The number of requests in the http connection pool that are waiting to get a connection</td>
  </tr>
  <tr>
    <td>connections</td>
    <td>Current connection number</td>
  </tr>
  <tr>
    <td>bytesRead</td>
    <td>Average number of bytes received per second during the current period (Bps)<br>
        Business layer statistics, relative to the data obtained from the network card, the data here does not include the size of the header<br>
        For http messages, does not include http header size</td>
  </tr>
  <tr>
    <td>bytesWritten</td>
    <td>Average number of bytes sent per second during the current period (Bps)<br>
        Business layer statistics, relative to the data obtained from the network card, the data here does not include the size of the header<br>
        For http messages, does not include http header size</td>
  </tr>
</table>

### 4. vertx server endpoints  
<table class="metrics-table">
  <tr>
    <th>Name</th>
    <th>Tag keys</th>
    <th>Tag values</th>
    <th>Description</th>
  </tr>
  <tr>
    <td rowspan="8">servicecomb<br>.vertx<br>.endpoints</td>
    <td>type</td>
    <td>server</td>
    <td></td>
  </tr>
  <tr>
    <td>address</td>
    <td>${ip}:${port}</td>
    <td>listen ip:port</td>
  </tr>
  <tr>
    <td rowspan="6">statistic</td>
    <td>connectCount</td>
    <td>Number of connections are connected in the current period</td>
  </tr>
  <tr>
    <td>disconnectCount</td>
    <td>Number of disconnections in the current period</td>
  </tr>
  <tr>
    <td>rejectByConnectionLimit</td>
    <td>Number of active disconnections due to exceeding the number of connections in the current period</td>
  </tr>
  <tr>
    <td>connections</td>
    <td>Current connection number</td>
  </tr>
  <tr>
    <td>bytesRead</td>
    <td>Average number of bytes sent per second during the current period (Bps)<br>
        Business layer statistics, relative to the data obtained from the network card, the data here does not include the size of the header<br>
        For http messages, does not include http header size</td>
  </tr>
  <tr>
    <td>bytesWritten</td>
    <td>Average number of bytes received per second during the current period (Bps)<br>
        Business layer statistics, relative to the data obtained from the network card, the data here does not include the size of the header<br>
        For http messages, does not include http header size</td>
  </tr>
</table>

### 5. Invocation latency distribution
<table class="metrics-table">
  <tr>
    <th>Name</th>
    <th>Tag keys</th>
    <th>Tag values</th>
    <th>Description</th>
  </tr>
  <tr>
    <td rowspan="11">servicecomb<br>.invocation</td>
    <td>role</td>
    <td>CONSUMER、PRODUCER、EDGE</td>
    <td>Is the CONSUMER, PRODUCER or EDGE side statistics</td>
  </tr>
  <tr>
    <td>operation</td>
    <td>${microserviceName}<br>.${schemaId}<br>.${operationName}</td>
    <td>Method name called</td>
  </tr>
  <tr>
    <td>transport</td>
    <td>highway or rest</td>
    <td>On which transmission channel the call is made</td>
  </tr>
  <tr>
    <td>status</td>
    <td>http status code</td>
    <td></td>
  </tr>
  <tr>
    <td>type</td>
    <td>latencyDistribution</td>
    <td>invocation latency distribution</td>
  </tr>
  <tr>
    <td>scope</td>
    <td>[${min}, ${max})</td>
    <td>The call count in the current period that latency is greater than or equal to min, less than max<br>
        [${min},) means max is infinite</td>
  </tr>
</table>

### 6. invocation consumer stage latency 
<table class="metrics-table">
  <tr>
    <th>Name</th>
    <th>Tag keys</th>
    <th>Tag values</th>
    <th>Description</th>
  </tr>
  <tr>
    <td rowspan="19">servicecomb<br>.invocation</td>
    <td>role</td>
    <td>CONSUMER</td>
    <td>Statistics on the CONSUMER side</td>
  </tr>
  <tr>
    <td>operation</td>
    <td>${microserviceName}<br>.${schemaId}<br>.${operationName}</td>
    <td>Method name called</td>
  </tr>
  <tr>
    <td>transport</td>
    <td>highway or rest</td>
    <td>On which transmission channel the call is made</td>
  </tr>
  <tr>
    <td>status</td>
    <td>http status code</td>
    <td></td>
  </tr>
  <tr>
    <td>type</td>
    <td>stage</td>
    <td>stage latency</td>
  </tr>
  <tr>
    <td rowspan="11">stage</td>
    <td>total</td>
    <td>The whole process</td>
  </tr>
  <tr>
    <td>prepare</td>
    <td></td>
  </tr>
  <tr>
    <td>handlers_request</td>
    <td>Handler chain request process</td>
  </tr>
  <tr>
    <td>client_filters_request</td>
    <td>Http client filter chain request process<br>
        Only the rest transport has this stage.</td>
  </tr>
  <tr>
    <td>consumer_send_request</td>
    <td>Send request stage, including consumer_get_connection and consumer_write_to_buf</td>
  </tr>
  <tr>
    <td>consumer_get_connection</td>
    <td>Get a connection from the connection pool</td>
  </tr>
  <tr>
    <td>consumer_write_to_buf</td>
    <td>Write data to the network buffer</td>
  </tr>
  <tr>
    <td>consumer_wait_response</td>
    <td>Waiting for the server to answer</td>
  </tr>
  <tr>
    <td>consumer_wake_consumer</td>
    <td>In the synchronization process, after receiving the response, it takes time from waking up the waiting thread to waiting for the thread to start processing the response.</td>
  </tr>
  <tr>
    <td>client_filters_response</td>
    <td>Http client filter chain response process</td>
  </tr>
  <tr>
    <td>handlers_response</td>
    <td>Handler chain response process</td>
  </tr>
  <tr>
    <td rowspan="3">statistic</td>
    <td>count</td>
    <td>Average number of calls per second (TPS)<br>
        Count=Number of calls/period in the statistical period (seconds)</td>
  </tr>
  <tr>
    <td>totalTime</td>
    <td>In seconds<br>
        totalTime=The total duration of the call in the current period (seconds)<br>
        totalTime divided by count to get the average latency</td>
  </tr>
  <tr>
    <td>max</td>
    <td>In seconds<br>
        Maximum latency in the current period</td>
  </tr>
</table>

### 7. invocation producer stage latency
<table class="metrics-table">
  <tr>
    <th>Name</th>
    <th>Tag keys</th>
    <th>Tag values</th>
    <th>Description</th>
  </tr>
  <tr>
    <td rowspan="17">servicecomb<br>.invocation</td>
    <td>role</td>
    <td>PRODUCER</td>
    <td>Statistics on the PRODUCER side</td>
  </tr>
  <tr>
    <td>operation</td>
    <td>${microserviceName}<br>.${schemaId}<br>.${operationName}</td>
    <td>Method name called</td>
  </tr>
  <tr>
    <td>transport</td>
    <td>highway or rest</td>
    <td>On which transmission channel the call is made</td>
  </tr>
  <tr>
    <td>status</td>
    <td>http status code</td>
    <td></td>
  </tr>
  <tr>
    <td>type</td>
    <td>stage</td>
    <td>stage latency</td>
  </tr>
  <tr>
    <td rowspan="9">stage</td>
    <td>total</td>
    <td>The whole process</td>
  </tr>
  <tr>
    <td>prepare</td>
    <td></td>
  </tr>
  <tr>
    <td>queue</td>
    <td>Meaning only when using a thread pool<br>
        Indicates the length of time the call is queued in the thread pool</td>
  </tr>
  <tr>
    <td>server_filters_request</td>
    <td>Http server filter chain request process<br>
        Only the rest transport has this stage.</td>
  </tr>
  <tr>
    <td>handlers_request</td>
    <td>Handler chain request process</td>
  </tr>
  <tr>
    <td>execution</td>
    <td>Business method</td>
  </tr>
  <tr>
    <td>handlers_response</td>
    <td>Handler chain response process</td>
  </tr>
  <tr>
    <td>server_filters_response</td>
    <td>Http server filter chain response process</td>
  </tr>
  <tr>
    <td>producer_send_response</td>
    <td>Send a response</td>
  </tr>
  <tr>
    <td rowspan="3">statistic</td>
    <td>count</td>
    <td>Average number of calls per second (TPS)<br>
        Count=Number of calls/period in the statistical period (seconds)</td>
  </tr>
  <tr>
    <td>totalTime</td>
    <td>In seconds<br>
        totalTime=The total duration of the call in the current period (seconds)<br>
        AverageTime divided by count to get the average latency</td>
  </tr>
  <tr>
    <td>max</td>
    <td>In seconds<br>
        Maximum latency in the current period</td>
  </tr>
</table>

### 8. invocation edge stage latency 
<table class="metrics-table">
  <tr>
    <th>Name</th>
    <th>Tag keys</th>
    <th>Tag values</th>
    <th>Description</th>
  </tr>
  <tr>
    <td rowspan="23">servicecomb<br>.invocation</td>
    <td>role</td>
    <td>EDGE</td>
    <td>EDGE statistics</td>
  </tr>
  <tr>
    <td>operation</td>
    <td>${microserviceName}<br>.${schemaId}<br>.${operationName}</td>
    <td>Method name called</td>
  </tr>
  <tr>
    <td>transport</td>
    <td>highway or rest</td>
    <td>On which transmission channel the call is made</td>
  </tr>
  <tr>
    <td>status</td>
    <td>http status code</td>
    <td></td>
  </tr>
  <tr>
    <td>type</td>
    <td>stage</td>
    <td>stage latency</td>
  </tr>
  <tr>
    <td rowspan="15">stage</td>
    <td>total</td>
    <td>The whole process</td>
  </tr>
  <tr>
    <td>prepare</td>
    <td></td>
  </tr>
  <tr>
    <td>queue</td>
    <td>Meaning only when using a thread pool<br>
        Indicates the length of time the call is queued in the thread pool</td>
  </tr>
  <tr>
    <td>server_filters_request</td>
    <td>Http server filter chain request process</td>
  </tr>
  <tr>
    <td>handlers_request</td>
    <td>Handler chain request process</td>
  </tr>
  <tr>
    <td>client_filters_request</td>
    <td>Http client filter chain request process</td>
  </tr>
  <tr>
    <td>consumer_send_request</td>
    <td>Send request stage, including consumer_get_connection and consumer_write_to_buf</td>
  </tr>
  <tr>
    <td>consumer_get_connection</td>
    <td>Get a connection from the connection pool</td>
  </tr>
  <tr>
    <td>consumer_write_to_buf</td>
    <td>Write data to the network buffer</td>
  </tr>
  <tr>
    <td>consumer_wait_response</td>
    <td>Waiting for the server to answer</td>
  </tr>
  <tr>
    <td>consumer_wake_consumer</td>
    <td>In the synchronization process, after receiving the response, it takes time from waking up the waiting thread to waiting for the thread to start processing the response.</td>
  </tr>
  <tr>
    <td>client_filters_response</td>
    <td>Http client filter chain response process</td>
  </tr>
  <tr>
    <td>handlers_response</td>
    <td>Handler chain response process</td>
  </tr>
  <tr>
    <td>server_filters_response</td>
    <td>Http server filter chain response process</td>
  </tr>
  <tr>
    <td>producer_send_response</td>
    <td>Send a response</td>
  </tr>
  <tr>
    <td rowspan="3">statistic</td>
    <td>count</td>
    <td>Average number of calls per second (TPS)<br>
        Count=Number of calls/period in the statistical period (seconds)</td>
  </tr>
  <tr>
    <td>totalTime</td>
    <td>In seconds<br>
        totalTime=The total duration of the call in the current period (seconds)<br>
        AverageTime divided by count to get the average latency</td>
  </tr>
  <tr>
    <td>max</td>
    <td>In seconds<br>
        Maximum latency in the current period</td>
  </tr>
</table>

### 9. threadpool
<table class="metrics-table">
  <tr>
    <th>Name</th>
    <th>Tag keys</th>
    <th>Tag values</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>threadpool.corePoolSize  </td>
    <td rowspan="8">id</td>
    <td rowspan="8">${threadPoolName}</td>
    <td>Minimum number of threads</td>
  </tr>
  <tr>
    <td>threadpool.maxThreads </td>
    <td>Maximum number of threads allowed</td>
  </tr>
  <tr>
    <td>threadpool.poolSize </td>
    <td>Current actual number of threads</td>
  </tr>
  <tr>
    <td>threadpool.currentThreadsBusy </td>
    <td>The current number of active threads, which is the number of tasks currently being executed</td>
  </tr>
  <tr>
    <td>threadpool.queueSize </td>
    <td>Number of tasks currently queued</td>
  </tr>
  <tr>
    <td>threadpool.rejectedCount </td>
    <td>The average number of tasks rejected per second during the current period</td>
  </tr>
  <tr>
    <td>threadpool.taskCount</td>
    <td>Average number of tasks submitted per second during the statistical period<br>
        taskCount=(completed + queue + active)/period (seconds)</td>
  </tr>
  <tr>
    <td>threadpool.completedTaskCount </td>
    <td>The average number of tasks completed per second during the statistical period<br>
        completedTaskCount=completed/period (seconds)</td>
  </tr>
</table>

# Fourth, business customization

Because ServiceComb has initialized the registry's registry, the business no longer has to create a registry.

Implement the MetricsInitializer interface, define the business-level Meters, or implement a custom Publisher, and then declare your implementation through the SPI mechanism.

### 1.Meters:
Creating Meters capabilities is provided by spectator, available in the [netflix spectator] (https://github.com/Netflix/spectator) documentation

### 2.Publisher:
Periodically output scenarios, such as log scenarios, subscribe to org.apache.servicecomb.foundation.metrics.PolledEvent via eventBus, PolledEvent.getMeters() is the statistical result of this cycle.
Non-periodic output scenarios, such as access through the RESTful interface, the statistical results of this cycle can be obtained through globalRegistry.iterator()
