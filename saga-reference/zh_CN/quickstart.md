# Apache ServiceComb Pack
Apache ServiceComb Pack QuickStart
saga-servicecomb-demo中的Saga代码解读

## 全局事务执行过程

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

### 在CompensableInterceptor中
* AlphaResponse调用TxStartedEvent
* postIntercept发送TxEndedEvent
* 当出现错误的时候 onError会发送 TxAbortedEvent事件

