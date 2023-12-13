# 概述
Java Chassis 给开发者提供一个快速构建微服务的 JAVA SDK 。它包含如下特性：

* 多种开发风格，REST(JAX-RS、Spring MVC）和 RPC
* 多种通信协议, HTTP over Vert.x、Http Over Servlet、Highway 等
* 统一一致的服务提供者、服务消费者处理链，以及基于契约的开箱即用的服务治理能力

开发者可以通过[Java Chassis设计参考](start/design.md)了解 Java Chassis 的设计思路。

开发者可以通过下面的链接获取其他版本的帮助文档。

| 适用版本           | 正式发布地址                                                  | 预览版本地址                                                    | 
|:---------------|:--------------------------------------------------------|:----------------------------------------------------------|
| Java Chassis 3 | [中文][apache.zh_CN], [English][apache.en_US]             | [中文][preview.zh_CN], [English][preview.en_US]             |
| Java Chassis 2 | [中文][apache.zh_CN.2.8.x], [English][apache.en_US.2.8.x] | [中文][preview.zh_CN.2.8.x], [English][preview.en_US.2.8.x] |
| Java Chassis 1 | [中文][apache.zh_CN.1.3.x], [English][apache.en_US.1.3.x] | [中文][preview.zh_CN.1.3.x], [English][preview.en_US.1.3.x] |


[apache.zh_CN]: https://servicecomb.apache.org/references/java-chassis/zh_CN/
[apache.en_US]: https://servicecomb.apache.org/references/java-chassis/en_US/
[apache.zh_CN.2.8.x]: https://servicecomb.apache.org/references/java-chassis/2.x/zh_CN/
[apache.en_US.2.8.x]: https://servicecomb.apache.org/references/java-chassis/2.x/en_US/
[apache.zh_CN.1.3.x]: https://servicecomb.apache.org/references/java-chassis/1.x/zh_CN/
[apache.en_US.1.3.x]: https://servicecomb.apache.org/references/java-chassis/1.x/en_US/

[preview.zh_CN]: https://huaweicse.github.io/servicecomb-java-chassis-doc/java-chassis/zh_CN/
[preview.en_US]: https://huaweicse.github.io/servicecomb-java-chassis-doc/java-chassis/en_US/
[preview.zh_CN.2.8.x]: https://huaweicse.github.io/servicecomb-java-chassis-doc/java-chassis/2.x/zh_CN/
[preview.en_US.2.8.x]: https://huaweicse.github.io/servicecomb-java-chassis-doc/java-chassis/2.x/en_US/
[preview.zh_CN.1.3.x]: https://huaweicse.github.io/servicecomb-java-chassis-doc/java-chassis/1.x/zh_CN/
[preview.en_US.1.3.x]: https://huaweicse.github.io/servicecomb-java-chassis-doc/java-chassis/1.x/en_US/

## 术语表

|        缩略语         |        英文词汇        | 中文词汇  | 解释                                                                                                                                                                                                                 |
|:------------------:|:------------------:|:-----:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|    Application     |    Application     |  应用   | 应用代表一个软件应用的逻辑实体，表示一个有业务功能呈现给用户的计算机软件应用。一个以微服务化架构构建的应用通常由多个微服务组成。                                                                                                                                                   |
|      Service       |      Service       |  微服务  | 微服务是一种轻量级SOA架构，通常用来描述广泛用于云应用、互联网应用的一种松耦合分布式架构。                                                                                                                                                                     |
|      Instance      |      Instance      | 微服务实例 | 一个微服务的最小运行和部署单元，通常对应一个应用进程。                                                                                                                                                                                        |
|      Provider      |      Provider      | 服务提供者 | 在微服务调用关系中处于被调用一方的服务。                                                                                                                                                                                               |
|      Consumer      |      Consumer      | 服务消费者 | 在微服务调用关系中处于调用发起方的服务。                                                                                                                                                                                               |
|       Schema       |       Schema       | 微服务契约 | 微服务契约是对外接口的OpenAPI表示。OpenAPI增强了微服务的可见性，方便服务的分发、使用和治理。                                                                                                                                                              |
|     Code Style     |     Code Style     | 编程模型  | 编程模型指如何进行服务接口开发和调用，Java Chassis提供了Spring Web MVC、JAX RS等编程模型。编程模型独立于处理链和通信模型                                                                                                                                       |
|       Filter       |       Filter       |  处理链  | 处理链定义了一个请求的处理流程，包括编解码、服务治理、网络发送等。                                                                                                                                                                                  |
|     Transport      |     Transport      | 通信模型  | 通信模型定义了对象如何编解码，使用什么协议传输等。Java Chassis提供了REST、HIGHWAY等通信模型。                                                                                                                                                         |
|    Load Balance    |    Load Balance    | 负载均衡  | 当应用访问一个具有多个实例的微服务时，会涉及到路由负载均衡。可以通过配置文件配置负载均衡策略，支持随机，轮询、会话保持和基于响应时间的权值等多种负载均衡路由策略。                                                                                                                                  |
|   Rate Limiting    |   Rate Limiting    |  限流   | 当资源成为瓶颈时，服务框架需要对消费者的访问请求做限流，启动流控保护机制。在服务消费者端和提供者端均可进行流量控制。在服务消费端，可以限制发往某个微服务提供者的请求频率；在服务提供端，可以限制每个微服务消费端发过来的请求频率，也可以根据服务提供端资源消耗情况确定总的请求频率限制，防止服务因资源耗尽而崩溃。                                                          |
|  Service Degrade   |  Service Degrade   |  降级   | 服务降级主要包括屏蔽降级和容错降级两种策略：屏蔽降级是指当外界的触发条件达到某个临界值时，由运维人员/开发人员决策，对某类或者某个服务进行强制降级。容错降级是指当非核心服务不可用时，可以对故障服务做业务逻辑放通，以保障核心服务的运行。                                                                                              |
|  Fault Tolerance   |  Fault Tolerance   |  容错   | 容错是消费者访问服务时出现异常的场景下的一种处理策略，出现异常后由服务框架自动选择新的服务路由进行调用。                                                                                                                                                               |
|  Circuit Breaker   |  Circuit Breaker   |  熔断   | 微服务之间通常存在依赖关系，服务调用链路可能包含多个微服务，如果链路中一个或多个服务访问延迟过高，会导致入口服务的请求不断堆积，持续消耗更多的线程、io资源，最终由于资源累积使系统出现瓶颈，造成更多服务不可用，产生雪崩效应。熔断机制就是针对上述场景设计的，当某个目标服务响应缓慢或者有大量超时情况发生时，熔断该服务的调用，对于后续调用请求，不再继续调用目标服务，直接返回，快速释放资源，等到该目标服务情况好转再恢复调用。 |
|      Bulkhead      |      Bulkhead      |  隔离仓  | 隔离仓是一种异常检测机制，常用的检测方法是请求超时、流量过大等。一般的设置参数包括超时时间、最大并发请求数等，当超过超时时间或最大并发请求数时，记录一次异常，在熔断、实例隔离机制中，用于计算错误率。                                                                                                                |
| Instance Isolation | Instance Isolation | 实例隔离  | 实例隔离通过检测实例的错误率、超时请求数等指标，短暂的屏蔽故障实例的访问，降低错误率以及防止发生雪崩效应。                                                                                                                                                              |

## 帮助改善

* Java Chassis的 [文档源代码](https://github.com/apache/servicecomb-docs/tree/master/java-chassis-reference) 托管在Github， 可以下载后 ，采用 MkDocs 本地使用。 也可以在 [Issues](https://github.com/apache/servicecomb-docs/issues) 提交改进建议。 

>>> 备注：Java Chassis 2和Java Chassis 3缺少英文翻译，非常期待您的帮助支持。
