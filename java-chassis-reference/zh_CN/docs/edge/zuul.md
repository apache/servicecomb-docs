# 使用 `zuul` 和 `spring cloud gateway` 做网关

Zuul是Netflix的基于JVM的路由器和服务器端负载均衡器，可以使用Zuul进行以下操作：

* 认证
* 洞察
* 压力测试
* 金丝雀测试
* 动态路由
* 服务迁移
* 负载脱落
* 安全
* 静态相响应处理
* 主动/被动流量管理

关于Zuul的详细功能介绍请参考[路由器和过滤器：Zuul][zuul-ref]。

spring cloud gateway 是 spring cloud 开发的新一代网关服务，详细介绍可以参考[sprig cloud gateway][spring-cloud-gateway-ref]

使用 `zuul` 和 `spring cloud gateway` 作为网关，核心需要解决的问题是从服务中心发现其他微服务实例，
需要使用到 [spring cloud huawei][spring-cloud-huawei0] 的组件，
详细开发指南可以参考[zuul用spring cloud huawei的例子][zuul-ref]，[gateway用spring cloud huawei的例子][spring-cloud-gateway-ref]

[zuul-ref]: https://github.com/huaweicloud/spring-cloud-huawei-samples/tree/Hoxton/basic-zuul
[spring-cloud-gateway-ref]: https://github.com/huaweicloud/spring-cloud-huawei-samples/tree/master/basic
[spring-cloud-huawei0]: https://github.com/huaweicloud/spring-cloud-huawei
[spring-cloud-huawei1]: https://support.huaweicloud.com/devg-servicestage/cse_java_0059.html
[spring-cloud-huawei2]: https://support.huaweicloud.com/devg-servicestage/cse_java_0064.html

