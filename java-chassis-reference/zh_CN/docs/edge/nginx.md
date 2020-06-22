# nginx 网关简单介绍

## 概念阐述

### **confd**

confd是一个轻量级的配置管理工具，源码地址：[https://github.com/kelseyhightower/confd](https://github.com/kelseyhightower/confd)，
它可以将配置信息存储在etcd、consul、dynamodb、redis以及zookeeper等。confd定期会从这些存储节点pull最
新的配置，然后重新加载服务，完成配置文件的更新。

### **Nginx**

Nginx \(engine x\)是一个高性能的HTTP和反向代理服务器，具有负载均衡的功能。详情请
参考[http://www.nginx.cn/doc/](http://www.nginx.cn/doc/)。

## 场景描述

本小节简单介绍 Nginx 对接服务中心，从服务中心中获取服务信息并通过 confd 动态更新 Nginx 的配置。

使用 nginx+confd 动态反向代理的实现步骤可参考文
章[http://www.cnblogs.com/Anker/p/6112022.html](http://www.cnblogs.com/Anker/p/6112022.html)。

* 方法一：http调用

  服务中心开放http接口均需要添加租户头部信息：“X-Tenant-Name:tenantName”，tenameName为租户名，默
  认为default，例如"X-Tenant-Name:default"。

  * 检查服务中心健康状态

            ```
            GET 127.0.0.1:30100/health
            ```

  * 获取所有微服务信息

            ```
            GET 127.0.0.1:30100/registry/v3/microservices
            ```

  * 获取指定id的微服务信息

    首先根据微服务信息获取serviceId

            GET 127.0.0.1:30100/registry/v3/existence?type=microservice&appId={appId}&serviceName={serviceName}&version={version}

    根据上述接口返回的serviceId获取微服务完整信息

            GET 127.0.0.1:30100/registry/v3/microservices/{serviceId}

  * 获取指定微服务的所有实例信息

            GET 127.0.0.1:30100/registry/v3/microservices/{serviceId}/instances
        
    需要在header中添加："X-ConsumerId:{serviceId}"。

  * 查找微服务实例信息

            GET 127.0.0.1:30100/registry/v3/instances?appId={appId}&serviceName={serviceName}&version={version}
        
    需要在header中添加: "X-ConsumerId:{serviceId}"。


* 方法二：使用servicecomb开源代码接口

  在开发微服务应用，只需要调用servicecomb框架代码中的工具类RegistryUtil.java中提供的接口，即可
  获取服务中心的信息，接口描述如下：

  * 获取所有微服务信息  

            List<Microservice> getAllMicroservices();

  * 获取微服务唯一标识  

            String getMicroserviceId(String appId, String microserviceName, String versionRule);

  * 根据微服务唯一标识查询微服务静态信息  

            Microservice getMicroservice(String microserviceId);

  * 根据多个微服务唯一标识查询所有微服务实例信息  

            List<MicroserviceInstance> getMicroserviceInstance(String consumerId, String providerId);

  * 按照app+interface+version查询实例endpoints信息  

            List<MicroserviceInstance> findServiceInstance(String consumerId, String appId, String serviceName,String versionRule);


  通过上述http接口可获取到服务中心的微服务和其实例的信息，从而通过confd动态更新nginx配置。

