# 线程池

## 说明
线程池用于执行同步模式的业务逻辑。  
网络收发及reactive模式的业务逻辑在Eventloop中执行，与线程池无关  

默认所有同步方法都在一个全局内置线程池中执行  
如果业务有特殊的需求，可以指定使用自定义的全局线程池，并且可以根据schemaId或operationId指定各自使用独立的线程池，实现隔离仓的效果  

## 定制线程池
* 实现线程池  
  下面的方法任选其一即可
  * 实现`java.util.concurrent.Executor`接口  
    为了支持优雅退出，如果内部线程未设置为daemon线程，则还需要实现`java.io.Closeable`接口，负责销毁线程池
  * 实现`java.util.concurrent.ExecutorService`接口
* 将实现的线程池声明为spring bean
* 启用线程池  
  假设新线程池bean id为custom-executor
  * 替换全局线程池  
    servicecomb.executors.default: custom-executor
  * 指定schema专用的线程池  
    servicecomb.executors.Provider.${schemaId}: custom-executor
  * 指定operation专用的线程池  
    servicecomb.executors.Provider.${schemaId}.${operationId}: custom-executor
  

## ServiceComb内置线程池
一般的线程池都是所有线程共享一个任务队列，在这种情况下，所有网络线程需要向同一个队列申请请求入队，线程池中的所有线程需要从同一个队列中抢任务执行，对于高吞吐的场景，这会导致竞争冲突，形成性能瓶颈  
所以，为了提升性能，ServiceComb内置线程池实际是真正线程池的包装，允许在其内部配置多组线程池，且每个网络线程绑定一组线程池，以减小竞争冲突  
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
