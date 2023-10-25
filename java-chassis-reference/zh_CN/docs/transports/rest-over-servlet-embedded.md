# REST over Servlet(Spring Boot Embedded)

## 开发介绍

参考 [Spring Boot集成Java Chassis介绍](../spring-boot/introduction.md) ，Web开发模式使用 REST over Servlet(Spring Boot Embedded)。

REST over Servlet的本质是将Java Chassis作为一个Servlet，部署到支持Servlet的Web容器中。 

## 配置参考

使用Spring Boot Embedded场景，相关Web容器参数需要结合Spring Boot配置，这里不详细介绍。 只给出Java Chassis增加的配置。 


| 配置项                                                         | 默认值          | 含义                                                                                                                  |
|:------------------------------------------------------------|:-------------|:--------------------------------------------------------------------------------------------------------------------|
| servicecomb.rest.address                                    | 0.0.0.0:8080 | 服务监听地址<br>必须配置为与web容器监听地址相同的地址                                                                                      |
| servicecomb.rest.server.timeout                             | -1           | 异步servlet超时时间, 单位为毫秒<br>建议保持默认值                                                                                     |
| servicecomb.Provider.requestWaitInPoolTimeout${op-priority} | 30000        | 在同步线程中排队等待执行的超时时间，单位为毫秒                                                                                             |
| servicecomb.rest.server.requestWaitInPoolTimeout            | 30000        | 同servicecomb.Provider.requestWaitInPoolTimeout${op-priority}, 该配置项优先级更高。                                            |

