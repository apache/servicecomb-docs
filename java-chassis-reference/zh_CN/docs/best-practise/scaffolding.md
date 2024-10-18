# 项目脚手架

为了支持快速开发，提供脚手架快速生成项目是非常好的实践。ServiceComb Fence的网关服务（edge service）、认证服务(authentication server)、管理服务（admin-service、admin-website），开发者可以直接基于源码扩展新的业务场景和逻辑。一般的业务服务，都是基于资源服务(resource-server)模板。 

编译完成 ServiceComb Fence 项目后，可以使用 maven archetype 来生成一个新的微服务项目：


```shell
mvn archetype:generate 
  -DserviceName=resource-server2 
  -DartifactId=resouerce-server2
  -DwebRoot=resource 
  -DserverPort=9090 
  -DarchetypeGroupId=org.apache.servicecomb.fence 
  -DarchetypeArtifactId=fence-archetype 
```

基于可运行的项目工程完成一个新的业务开发，可以快速迭代新功能，并且可以在此基础上不断的补充新的测试用例，以支持系统的持续演进，是非常好的软件工程实践。 

