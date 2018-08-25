## Scene Description

When doing service discovery, developers need to understand that the microservice can discover instances of those other services. ServiceComb provides hierarchical instance isolation.

# Microservices instance hierarchical management

To understand the isolation level between instances, you first need to understand a well-established microservice system structure defined by ServiceComb:

![](/assets/sc-meta.png)

In the microservice system structure, the top layer is the “project”, which is divided into multiple tenants under the project. The tenant contains multiple applications, and each application contains multiple environments, that is, the test and production environments can be separated.
In a particular environment of a particular application, there are multiple microservices, and one microservice can have multiple versions at the same time.
The above is the scope of all static metadata. A specific version of a particular service contains multiple microservice instances registered at runtime, because the information of the service instance is dynamic at runtime because of system scaling, failure, etc. The change, so the routing information of the service instance is again dynamic data.
By hierarchically managing these data for microservices, this is natural to achieve logical isolation between instances.
# isolation level description

ServiceComb supports custom hierarchical configuration to meet the hierarchical management requirements of users. The following is the specific configuration instructions.

* Application ID

Defined by APPLICATIOIN\_ID, the default value is 'default'. When a microservice discovers an instance, it can only be discovered by consumers under the same APPLICATIOIN\_ID by default.

* Domain name

Defined by servicecomb.config.client.domainName, the default value is 'default'. As a micro service provider, it is used to indicate the tenant information that it belongs to. When a microservice finds an instance, it can only be discovered by consumers under the same tenant.

* Data Center Information

The data center consists of three attributes: servicecomb.datacenter.name, servicecomb.datacenter.region, servicecomb.datacenter.availableZone. Data center information does not provide isolation capabilities, and microservices can discover instances of other data centers. However, you can prioritize sending messages to a specified zone or zone by enabling instance affinity:

```
servicecomb:
  datacenter:
    name: mydatacenter
    region: my-Region
    availableZone: my-Zone
```

After this configuration, when the client routes, it will forward the request to the same instance with the same zone/region. Then, if the instances with the same region but different zones are different, select one according to the routing rule. Affinity is not logical isolation. As long as the network between the instances is connected, it is possible to access it; if the network is unreachable, the access will fail.

* Environmental information

It is configured in the yaml file by 'service\_description.environment'. It is also supported by the environment variable 'SERVICECOMB\_ENV'. It only supports the following enumeration : 'development', 'testing', 'acceptance', 'production'. The default value is ""\(empty\). When a microservice discovers an instance, it can only be discovered by consumers under the same environment by default.

```
service_description:
  environment: production
```

