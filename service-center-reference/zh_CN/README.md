## Service-Center 设计原理

Service-Center(SC)是一个服务注册中心，允许服务注册他们的实例信息并发现给定服务的提供者。以下简称SC：
SC使用ETCD存储微服务的所有信息及其实例。下面是SC的工作原理和流程图。

#### On StartUp
假设我们的微服务是使用 [java-chassis](https://github.com/ServiceComb/java-chassis) SDK编写的。因此，当微服务启动时，Java chassis SDK执行以下任务列表。

1 在启动provider时注册微服务到SC。（执行该步的条件是：既没有在之前注册，也没在sc登记它的实例信息，如它的IP和端口上运行的实例信息）

2 SC将provider信息存储在ETCD中。

3 被启用的consumer检索所有provider实例的列表 （这个列表是由provider微服务名称构成，且从sc获得）

4 Consumer SDK将provider实例的所有信息存储在其缓存中。

5 Consumer SDK创建到SC的Web socket连接，以查看所有提供程序实例信息，如果提供者中有任何更改，SDK更新其缓存信息。


![Onstartup](static_files/onStartup.PNG)

#### Consumer -> Provider 之间的通信
一旦启动成功，那么消费者可以完美地与提供者通信，下面是说明提供者和消费者之间的通信的图表。

![Commuication](static_files/communication.PNG)

Provider程序实例每隔30秒定期发送心跳信号到SC，如果SC不接收某一个实例的心跳，则该实例信息将在ETCD中过期，并且该provider实例信息被sc移除。Consumer由SC监视Provider实例的信息，如果有任何变化，则更新缓存。当Consumer需要与Provider通信时，Consumer从缓存读取Provider实例的endpoints，并进行负载平衡以与provider者通信。

Note: 这个文档是beta阶段，可以自由的向该文档提交贡献.
