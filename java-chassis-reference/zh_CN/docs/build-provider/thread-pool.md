# 线程池

线程池用于执行同步模式的业务逻辑，网络收发及reactive模式的业务逻辑在 event-loop 中执行，与线程池无关。 默认情况下，  Consumer 和 Provider 的
业务逻辑代码的执行都是在线程池里面， Edge Service 的业务逻辑执行在 event-loop 里面。 

Java Chassis 提供了一个全局的内置线程池， 如果业务有特殊的需求，可以指定使用自定义的全局线程池，并且可以根
据 schemaId 或 operationId 指定各自使用独立的线程池，实现隔离仓的效果。   

## 定制线程池

* 实现线程池  
    下面的方法任选其一即可
    * 实现`java.util.concurrent.Executor`接口， 为了支持优雅退出，如果内部线程未设置为daemon线程，则还需要实现`java.io.Closeable`接口，负责销毁线程池
    * 实现`java.util.concurrent.ExecutorService`接口
* 将实现的线程池声明为 spring bean
* 启用线程池  
  假设新线程池bean id为custom-executor
  * 替换全局线程池：`servicecomb.executors.default: custom-executor`
  * 指定schema专用的线程池: `servicecomb.executors.Provider.${microserviceId}.${schemaId}: custom-executor`
  * 指定operation专用的线程池: `servicecomb.executors.Provider.${microserviceId}.${schemaId}.${operationId}: custom-executor`
  * 指定microservice专用的线程池: `servicecomb.executors.Provider.${microserviceId}: custom-executor`
    其中microserviceId为可选项，在edge service中用以区分不同的microservice
 
## Java Chassis 内置线程池

Java Chassis提供了两个内置的线程池，`servicecomb.executor.groupThreadPool` 和 `servicecomb.executor.reactive`。 前者
是同步线程池，在Consumer和Provider默认启用；后者是异步线程池，在Edge Service默认启用。 

### 同步线程池

一般的线程池都是所有线程共享一个任务队列，在这种情况下，所有网络线程需要向同一个队列申请请求入队，线程池中的所有线程需要从同一个队列中抢任务执行，对于高吞吐的场景，这会导致竞争冲突，形成性能瓶颈  
所以，为了提升性能，Java Chassis内置线程池实际是真正线程池的包装，允许在其内部配置多组线程池，且每个网络线程绑定一组线程池，以减小竞争冲突  
![](../assets/producer-default-executor.png)

* 1.2.0之前的版本

| 配置项                                           | 默认值       | 含义                   |
| :----------------------------------------------- | :----------- | :--------------------- |
| servicecomb.executor.default.group               | 2            | 创建几组线程池         |
| servicecomb.executor.default.thread-per-group    | CPU数        | 每组线程池的线程数     |


* 大于等于1.2.0的版本

| 配置项                                              | 默认值            | 含义                                                                      |
| :-------------------------------------------------- | :---------------- | :------------------------------------------------------------------------ |
| servicecomb.executor.default.group                  | 2                 | 创建几组线程池                                                            |
| servicecomb.executor.default.thread-per-group       | 100               | 每组线程池的最大线程数<br>Deprecated，新名字：maxThreads-per-group        |
| servicecomb.executor.default.coreThreads-per-group  | 25                | 每组线程池的最小线程数<br>线程不会预创建，而是已经创建后，只有大于这个值的线程，才会因idle而销毁 |
| servicecomb.executor.default.maxThreads-per-group   | 100               | 每组线程池的最大线程数                                                    |
| servicecomb.executor.default.maxIdleSecond-per-group| 60                | 每组线程池中超过coreThreads-per-group的线程，如果idle超时，则会销毁该线程 |
| servicecomb.executor.default.maxQueueSize-per-group | Integer.MAX_VALUE | 每组线程池中任务队列的最大长度                                            |
| servicecomb.rest.server.requestWaitInPoolTimeout    | 30000             |在同步线程中排队等待执行的超时时间，单位为毫秒         |

### 异步线程池

所谓的异步线程池，实际上是没有提供额外的线程池。 所有的业务逻辑直接在 event-loop 线程池执行。 使用异步线程池，业务代码不能够存在阻塞操作。
常见的阻塞操作包括

* 使用同步API，调用其他微服务，比如 RestTemplate、透明RPC等。
* 特别耗时的任务。比如等待IO、等待锁、Sleep等。

