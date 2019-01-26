# Apache ServiceComb Pack ：Saga QuickStart
### [Saga-servicecomb-demo](https://github.com/apache/servicecomb-pack) 背景介绍的Pack代码机制解读

![Saga demo背景](static_files/pack_demo.png)

为了更好的学习Apache ServiceComb Pack，Demo设定一个实际需要分布式一致性的业务场景来方便理解。  
上图中：用户对预定服务Booking发起请求，其中租车订单服务car和酒店订单服务hotel没有依赖关系，可以并行处理，但对于我们的客户来说，只在所有预订成功后一次付费更加友好。  

![Saga demo背景](static_files/pack_arc.png)

### Demo中的Saga场景
上图中:Saga中包含两个组件，即Omega和Alpha, 另外还有用来持久化的DB。  
结合图一：三个服务，booking、car、hotel均为omega进程，均通过alpha协调。  

##### Omega像一个agent内嵌各Service中,主要负责：
* 监控本地事务执行情况，并以Event形式向alpha上报事务执行状态。  
* 异常情况下根据alpha下发的指令执行相应的补偿操作。    
  
##### Alpha充当协调者的角色，主要负责: 
* 对本地事务的事件进行持久化存储。  
* 在本地事务与全局事务出现不一致的情况下，Alpha会回调相关Omega进行补偿（最终保持全局事务一致）。  

例：当异常情况下，如ServiceB的事务执行失败，Alpha扫描到Omega发送的TxAbortedEvent事件，就会回调ServiceA的补偿方法，执行自定义回滚逻辑，使各服务回到事务执行之前的状态。  

##### 下面我们对Saga的事件建立初步了解后，再来看看Saga-servicecomb-demo具体直了写什么。

## Saga中的Event简介
[EventType事件参考代码](https://github.com/apache/servicecomb-pack/blob/master/pack-common/src/main/java/org/apache/servicecomb/pack/common/EventType.java)

SagaStartedEvent: 代表Saga事务的开始，Alpha接受到该事件会保存整个saga请求的上下文，其中包括多个事务/补偿请求  
TxStartedEvent: Alpha保存对应事务请求的上下文  
TXEndedEvent: Alpha保存对应事务请求及其回复  
TxAbortedEvent: Alpha保存对应事务请求和失败的原因  
TxCompensatedEvent: 保存对应补偿请求及其回复  
SagaEndedEvent: 标志着saga事务请求的结束，不需要保存任何内容  

![成功场景](static_files/Success.png)

成功场景下，全局事务事件SagaStartedEvent对应SagaEndedEvent ，每个子事务开始的事件TxStartedEvent都会有对应的结束事件TXEndedEvent。
![异常场景](static_files/Exception.png)

异常场景下，omega会向alpha上报中断事件TxAbortedEvent，然后alpha会向该全局事务的其它已成功的子事务(以完成TXEndedEvent)发送补偿指令，确保最终所有的子事务要么都成功，要么都回滚。

![超时场景](static_files/Timeout.png)

超时场景下，已超时的事件会被alpha的定期扫描器检测出来，与此同时，该超时事务对应的全局事务也会被中断。  
                 
![恢复机制](static_files/defaultRecovery.png)
1.用户发送Request请求调用业务方法(business logic)  
2.preIntercept向alpha发送TxStartedEvent  
3.被AOP拦截的方法(business logic)被调用  
4.当执行成功时postIntercept发送TxEndedEvent到alpha  
5.最后业务方法向用户发送response  
基本运行机制清楚了，接下看具体实现的代码:  

