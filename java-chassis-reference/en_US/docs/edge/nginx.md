# Using confd and Nginx for edge services

## Concept Description

### **confd**

Confd is a lightweight configuration management tool, source code: [https://github.com/kelseyhightower/confd] (https://github.com/kelseyhightower/confd), which stores configuration information in etcd, Consul, dynamodb, redis, and zookeeper. Confd periodically pulls the latest configuration from these storage nodes, then reloads the service and completes the configuration file update.

### **Nginx**

Nginx \(engine x\) is a high-performance HTTP and reverse proxy server with load balancing capabilities. For details, please refer to [http://www.nginx.cn/doc/] (http://www.nginx.cn/doc/). The services introduced in this section mainly use the Nginx http proxy function.

## Scene Description

The technology introduced in this section is to use nginx+confd as the edge service. At the same time, you can dock the service center in the Java Chassis microservices framework, and pull the service information from the service center to dynamically update the nginx configuration through confd.

The implementation steps of using nginx+confd dynamic reverse proxy can be found in the article [http://www.cnblogs.com/Anker/p/6112022.html] (http://www.cnblogs.com/Anker/p/6112022. Html), this section mainly introduces how confd docks the service center of the Java Chassis framework.

## Docking Service Center

The core of the technology introduced in this section is how to make confd get the service information of the service center. The service center opens the following interfaces for external calls:

### **Method one: http call **

The service provider open http interface needs to add the tenant header information: "X-Tenant-Name:tenantName", and the tenameName is the tenant name. The default is default, for example, "X-Tenant-Name: default".

* Check the health status of the service center

  ```
   GET 127.0.0.1:30100/health
  ```

* Get all micro service information

  ```
   GET 127.0.0.1:30100/registry/v3/microservices
  ```

* Get the microservice information of the specified id

> 1. First get the serviceId based on the microservice information
>
> ```
> GET 127.0.0.1:30100/registry/v3/existence?type=microservice&appId={appId}&serviceName={serviceName}&version={version}
> ```
>
2. 2. Obtain the microservice complete information according to the serviceId returned by the above interface.
>
> GET 127.0.0.1:30100/registry/v3/microservices/{serviceId}

* Get all instance information for the specified microservice

  ```
   GET 127.0.0.1:30100/registry/v3/microservices/{serviceId}/instances

   Need to add in the header: "X-ConsumerId: {serviceId}".
  ```

* Find micro service instance information

  ```
   GET 127.0.0.1:30100/registry/v3/instances?appId={appId}&serviceName={serviceName}&version={version}

   Need to add in the header: "X-ConsumerId: {serviceId}".
  ```


#### Note: In actual development, please visit the actual service-center access address, and replace the variable of {} in the above url with a specific value. The data returned by http is in json format.

### **Method 2: Use servicecomb open source code interface**

In the development of microservices applications, you only need to call the interface provided in the tool class RegistryUtil.java in the servicecomb framework code to get the information of the service center. The interface description is as follows:

* Get all micro service information

  ```java
  List<Microservice> getAllMicroservices();
  ```

* Get the microservice unique identifier

  ```java
  String getMicroserviceId(String appId, String microserviceName, String versionRule);
  ```

* Query microservice static information based on microservice unique identifier

  ```java
  Microservice getMicroservice(String microserviceId);
  ```

* Query all micro service instance information based on multiple microservice unique identifiers

  ```java
  List<MicroserviceInstance> getMicroserviceInstance(String consumerId, String providerId);
  ```

* Query instance endpoints information by app+interface+version

  ```java
  List<MicroserviceInstance> findServiceInstance(String consumerId, String appId, String serviceName, String versionRule);
  ```

Through the above http interface, information about the microservices of the service center and its instances can be obtained, thereby dynamically updating the nginx configuration through confd.
