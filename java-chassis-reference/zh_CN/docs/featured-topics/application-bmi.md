# Java-Chassis 入门指南 - 开发BMI应用

本指南将以一个简单的 **体质指数(BMI)** 应用开展微服务之旅。[体质指数](https://baike.baidu.com/item/%E4%BD%93%E8%B4%A8%E6%8C%87%E6%95%B0)主要用于衡量人体胖瘦程度。该应用主要包含两个微服务：

* **体质指数计算器**：负责处理运算事务。

* **体质指数界面**：提供用户界面及网关服务。

其运行流程为：  
![体质指数应用运行流程](application-bmi/quick-start-sample-workflow.png)

其中，虚线表示服务注册及服务发现的过程。

本指南包含如下内容：

* [快速入门](application-bmi/quick-start.md)
* [体质指数微服务应用开发](application-bmi/quick-start-bmi.md)
* [微服务开发进阶](application-bmi/quick-start-advance.md)

介绍文档的源代码托管在[github](https://github.com/apache/servicecomb-samples/tree/master/java-chassis-samples/bmi)