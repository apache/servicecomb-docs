# 优雅停机
ServiceComb是通过JDK的ShutdownHook来完成优雅停机的。

## 使用场景

优雅停机可以解决以下场景：
* KILL PID
* 应用意外自动退出（System.exit(n)）

优雅停机解决不了以下场景：
* KILL -9 PID 或 taskkill /f /pid

## 效果
触发优雅停机时：
* 服务提供者：
  * 标记当前服务状态为STOPPING，不接受新的客户端请求，新的客户端访问请求会在客户端直接报错，客户端配合重试机制可重试其他实例；
  * 等待当前已运行线程执行完毕，如果设置了provider端超时，超时则强制关闭；
* 服务消费者：
  * 标记当前服务状态为STOPPING，直接拒绝新的调用请求；
  * 等待当前已发送请求的响应，如果超过客户端接收响应的超时时间（默认30秒），则强制关闭；

## 原理
触发优雅停机时，会依次执行以下步骤：
1. 给所有listener下发BEFORE_CLOSE事件，通知listener处理对应事件；
2. 将当前服务状态标记为STOPPING；
3. 从服务中心注销当前微服务实例，并关闭registry对应vertx；
4. 等待所有当前已存在invocation调用完成；
5. 关闭config-center和transport对应vertx；
6. 给所有listener下发AFTER_CLOSE事件，通知listener处理对应事件；
7. 将当前服务状态标记为DOWN；优雅停机结束；
