# Apache ServiceComb Pack
Apache ServiceComb Pack QuickStart
saga-servicecomb-demo中的Saga代码解读



* 为了更好的学习Apache ServiceComb Pack，我们设定一个实际需要分布式一致性的业务场景来方便理解，场景中：预定服务Booking、租车订单服务car、和酒店订单服务hotel没有依赖关系，可以并行处理，但对于我们的客户来说，只在所有预订成功后一次付费更加友好。 那么这三个服务的事务关系可以用下图表示：
[github](https://github.com/apache/servicecomb-saga/tree/master/saga-demo/saga-servicecomb-demo/README.md)

![Saga demo背景](static_files/pack_demo.png)

## Pack Event 介绍
SagaStartedEvent 保存整个saga请求，其中包括多个事务/补偿请求
TxStartedEvent 保存对应事务请求
TXEndedEvent 保存对应事务请求及其回复
TxAbortedEvent 保存对应事务请求和失败的原因
TxCompensatedEvent 保存对应补偿请求及其回复
SagaEndedEvent 标志着saga事务请求的结束，不需要保存任何内容

## Demo中的Pack场景
Pack中包含两个组件，即 alpha 和 omega。
图中的三个服务，booking、car、hotel均为omega进程，且通过alpha协调。booking调用car与hotel，且omega像一个agent内嵌其中，负责：1）对网络请求进行拦截并向alpha上报事务事件 2）异常情况下根据alpha下发的指令执行相应的补偿操作。而alpha充当协调者的角色，主要负责1）对事务的事件进行持久化存储2）协调子事务的状态，使其得以最终与全局事务的状态保持一致。

成功场景下，全局事务事件SagaStartedEvent对应SagaEndedEvent ，每个子事务开始的事件TxStartedEvent都会有对应的结束事件TXEndedEvent。

异常场景下，omega会向alpha上报中断事件TxAbortedEvent，然后alpha会向该全局事务的其它已完成的子事务发送补偿指令TxCompensatedEvent，确保最终所有的子事务要么都成功，要么都回滚。

## 全局事务执行过程
   ```

class SagaStartAnnotationProcessor {

  private final OmegaContext omegaContext;
  private final SagaMessageSender sender;

  SagaStartAnnotationProcessor(OmegaContext omegaContext, SagaMessageSender sender) {
    this.omegaContext = omegaContext;
    this.sender = sender;
  }

  AlphaResponse preIntercept(int timeout) {
    try {
      return sender
          .send(new SagaStartedEvent(omegaContext.globalTxId(), omegaContext.localTxId(), timeout));
    } catch (OmegaException e) {
      throw new TransactionalException(e.getMessage(), e.getCause());
    }
  }

  void postIntercept(String parentTxId) {
    AlphaResponse response = sender
        .send(new SagaEndedEvent(omegaContext.globalTxId(), omegaContext.localTxId()));
    if (response.aborted()) {
      throw new OmegaException("transaction " + parentTxId + " is aborted");
    }
  }

  void onError(String compensationMethod, Throwable throwable) {
    String globalTxId = omegaContext.globalTxId();
    sender.send(
        new TxAbortedEvent(globalTxId, omegaContext.localTxId(), null, compensationMethod,
            throwable));
  }
}
   ```


在SagaStartAnnotationProcessor
Annotation被触发  
1 当Request发送请求
2 调用preIntercept 发送 SagaStartedEvent 开始事务  
3 调用postIntercept 发送 SagaEndedEvent 事务结束执行  

compensableAnnotationProcessor执行补偿  
路径：servicecomb/saga/omega/transaction/

### EnableOmega

   ```
   //BookingApplication Class 
	@EnableOmega
	public class BookingApplication {
   ```
* 当EnableOmega签注生效时TransactionAspectConfig同时被实例化
* TransactionAspectConfig中的sagaStartAspect方法，返回初始化的SagaStartAspect对象。
* SagaStartAspect在构造函数中初始化SagaStartAnnotationProcessor（参数：OmegaContext及SagaMessagerSende） 参考下面的代码： 

   ```
//SagaStartAspect Class
@Around("execution(@org.apache.servicecomb.saga.omega.context.annotations.SagaStart * *(..)) && @annotation(sagaStart)")
  Object advise(ProceedingJoinPoint joinPoint, SagaStart sagaStart) throws Throwable {
    initializeOmegaContext();
    Method method = ((MethodSignature) joinPoint.getSignature()).getMethod();

  sagaStartAnnotationProcessor.preIntercept(sagaStart.timeout());

    try {
      Object result = joinPoint.proceed();
      sagaStartAnnotationProcessor.postIntercept(context.globalTxId());
      LOG.debug("Transaction with context {} has finished.", context);

      return result;
    } catch (Throwable throwable) {
      if (!(throwable instanceof OmegaException)) {
        sagaStartAnnotationProcessor.onError(method.toString(), throwable);
      }
      throw throwable;
    } 
  }
   ```

* 当全局事务开始时候
* SagaStartAspect调用preIntercept来发送SagaStartedEvent表示事务的开始
* SagaStartAspect调用postIntercept来发送SagaEndedEvent事件来结束全局事务
* 在SagaStartAspect中会对签注SagaStart的对象发送Sender对象（Sender对象包含 globalTxId及localTxId）
* 在事务执行出现异常的时候会发送TxAbortedEvent并通过反射调用compensationMethod  

## 子事务执行过程

在SagaStartAnnotationProcessor
Annotation被触发  
1 当Request发送请求
2 调用preIntercept发送TxStartedEvent 开始事务   
3 postIntercept 发送 TxEndedEvent 事务结束执行  

### 首先Spring Bean会初始化TransactionAspect并调用CompensableInterceptor实例
### 在CompensableInterceptor中
* AlphaResponse调用TxStartedEvent
* postIntercept发送TxEndedEvent
* 当出现错误的时候 onError会发送 TxAbortedEvent事件

