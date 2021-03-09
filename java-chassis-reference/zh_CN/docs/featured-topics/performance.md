# 性能问题分析和调优

性能优化是应用程序开发很重要的环节，也是比较复杂的过程。分析性能问题的关键是能够收集到尽可能多的信息，识别性能瓶颈。
Java Chassis针对性能分析提供的最有用工具是[应用性能监控](../general-development/metrics.md)。应用性能监控
默认周期性收集系统性能数据，并将数据输出到日志文件。应用性能监控数据统计提供了非常高效的实现，建议应用程序默认打开。

应用性能监控推荐下面的配置：

```yaml
servicecomb:
  metrics:
    window_time: 60000
    invocation:
      latencyDistribution: 0,1,10,100,1000
    Consumer.invocation.slow:
      enabled: true
      msTime: 1000
    Provider.invocation.slow:
      enabled: true
      msTime: 1000
    publisher.defaultLog:
      enabled: true
      endpoints.client.detail.enabled: true
```

结合业务自己的日志系统，可以将性能统计日志存储到独立的日志文件，减少对业务日志查看的干扰。

## 性能问题分析

性能问题一般以超时的方式表现出来，当出现性能问题的时候，建议收集如下日志：

1. consumer调用出错日志（如果有的话，比如超时）；
2. provider调用出错日志（如果有的话，比如丢弃请求）；
3. consumer对应时间段的metrics日志，包括周期统计数据和慢调用日志；
4. provider对应时间段的metrics日志，包括周期统计数据和慢调用日志；

通常结合上面的日志，就能够初步识别出性能瓶颈的位置了。metrics日志重点反映的是Java Chassis各个处理环节的耗时，
对于线程排队的场景，需要进一步识别业务的性能瓶颈。

1. 通过jstack采集堆栈信息。这个通常比较难于收集，需要在出现性能缓慢的时刻，抓取。建议每隔几秒钟，连续抓取3个以上堆栈，用于分析。
2. 对于涉及内存管理和垃圾回收的问题，需要收集GC的信息，和内存增长趋势。 

收集性能数据是分析的第一步，理解性能数据需要熟悉Java Chassis的处理过程、线程池排队和执行原理、JVM线程堆栈和GC机制等，这里不详细
描述，结合实际问题在过程中学习是更好的提升方式。 Java Chassis中通过[performance标签][performance]的问题和性能有关，可以作为业务性能问题
分析的参考，碰到性能问题，也可以[提交issue][issue]，找社区寻求帮助，记得在issue中包含metrics信息。 

[performance]: https://github.com/apache/servicecomb-java-chassis/issues?q=is%3Aissue+is%3Aclosed+label%3Aperformance
[issue]: https://github.com/apache/servicecomb-java-chassis/issues

## 性能常识

下面提供一些常见的数据，帮助识别性能瓶颈。这些数据并不是理论上精确的，仅供参考。 

* 通过一次调用，可以收集到一个请求发出到收到响应的时延，这个时延称为平均时延。并发场景，平均时延并不是固定的，通常随着并发数
  增大而增大。
* 一个请求的平均时延在0.1ms~1ms之间，TPS可以达到1万~10万。 0.1ms的时延，是不带任何业务逻辑的开发框架时延，当平均时延
  小于1ms的情况，进一步提升性能，需要考虑框架性能调优，还会涉及操作系统、网络等调优，比较复杂；大于1ms的情况，通常都需要
  调优业务代码，框架不是性能瓶颈。
* 一个请求的平均时延在1ms~10ms之间，TPS可以达到1千~1万。
* 一个请求的平均时延在100ms~100ms之间，TPS可以达到1百~1千。
* 有个简单的公式，可以估算最大TPS： `CPU核数 * (1000/平均时延)` < TPS < `线程数 * (1000/平均时延)`。 越是计算密集型的
  任务，TPS越接近`CPU核数 * (1000/平均时延)`；空闲等待任务越多，越是接近`线程数 * (1000/平均时延)`。 压测的时候，如果并发
  请求大于上述估算值，那么就会出现大量请求超时。 
  

