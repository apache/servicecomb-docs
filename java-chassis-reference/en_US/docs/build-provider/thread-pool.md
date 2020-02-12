# Thread pool

## Concept Description
Thread pool is for executing synchronization business logic.  
net send/receive or reactive business logic executing in eventloop, is independent of the thread pool  

By default all synchronization methods are executed in a global built-in thread pool  
If the business has special requirements, you can specify to use a custom global thread pool, and you can use separate thread pools according to the schemaId or operationId to achieve the effect of the isolated bin.  

## Customize thread pool  
* Implementing a thread pool  
  Choose one of the following methods.  
  * Implement the `java.util.concurrent.Executor` interface   
    In order to support elegant exit, if the internal thread is not set to the daemon thread, you also need to implement the `java.io.Closeable` interface, responsible for destroying the thread pool.  
  * Implement the `java.util.concurrent.ExecutorService` interface  
* Declare the thread pool of the implementation as a spring bean  
* Enable thread pool  
  Suppose the new thread pool spring bean id is custom-executor  
  * Replace the global thread pool  
    servicecomb.executors.default: custom-executor
  * Specify a thread pool dedicated to the schema    
    servicecomb.executors.Provider.${schemaId}: custom-executor
  * Specify a thread pool dedicated to the operation    
    servicecomb.executors.Provider.${schemaId}.${operationId}: custom-executor
  

## ServiceComb built-in thread pool  
In a general thread pool, all threads share a task queue. In this case, all network threads need to apply for the same queue to join the queue. All threads in the thread pool need to grab the task from the same queue. Throughput scenarios, which can lead to competitive conflicts and create performance bottlenecks  
Therefore, in order to improve performance, ServiceComb's built-in thread pool is actually a wrapper of real thread pools, allowing multiple sets of thread pools to be configured inside, and each network thread is bound to a set of thread pools to reduce contention conflicts.  
![](../assets/producer-default-executor.png)

* Before version 1.2.0  

| Configuration                                    | default      | Description                           |
| :----------------------------------------------- | :----------- | :------------------------------------ |
| servicecomb.executor.default.group               | 2            | Create several sets of thread pools   |
| servicecomb.executor.default.thread-per-group    | CPU count    | Number of threads per thread pool     |

* Version greater than or equal to 1.2.0

| Configuration                                       | default           | Description                                                               |
| :-------------------------------------------------- | :---------------- | :------------------------------------------------------------------------ |
| servicecomb.executor.default.group                  | 2                 | Create several sets of thread pools                                       |
| servicecomb.executor.default.thread-per-group       | 100               | Maximum number of threads per group of thread pools<br>Deprecated，new name：maxThreads-per-group        |
| servicecomb.executor.default.coreThreads-per-group  | 25                | Minimum number of threads per group of thread pools<br>Threads are not pre-created, but after they have been created, only threads larger than this value will be destroyed by idle. |
| servicecomb.executor.default.maxThreads-per-group   | 100               | Maximum number of threads per group of thread pools                       |
| servicecomb.executor.default.maxIdleSecond-per-group| 60                | Each thread in the thread pool that exceeds coreThreads-per-group will destroy the thread if the idle timeout |
| servicecomb.executor.default.maxQueueSize-per-group | Integer.MAX_VALUE | Maximum length of the task queue in each group of thread pools            |
