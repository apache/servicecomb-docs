In the process of continuous iterative development of microservices, due to the continuous addition of new features, some old features are continually being modified, and interface compatibility issues face enormous challenges, especially in the running environment multi-version coexistence (grayscale release) ). This chapter mainly describes some practical suggestions for interface compatibility management and solutions to compatibility problems during use. Since microservices generally provide services externally through the REST interface, the interface here refers to the REST interface without special instructions.

# Practice of ensuring interface compatibility

To prevent interface compatibility problems, developers are advised to follow the following principles when making interface changes (add, modify, delete, etc.).

1. Only add interfaces, do not modify or delete interfaces.
2. As a Provider, when adding an interface, the microservice version number is incremented accordingly. For example, change 2.1.2 to 2.1.3.
3. As a Consumer, when using the new interface of the Provider, specify the minimum version number of the Provider. For example: servicecomb.references.\[serviceName\].version-rule=2.1.3+, The serviceName is the Provider's microservice name.
4. In the service center, regularly clean up the old version of microservice information that is no longer used.

If microservice version number is not changed and when startup, the meta info in service center will not overridden. The Consumers see old meta data. To prevent this happen, ServiceComb will stop boot when incompatible interface change and version is the same. In newly developed project, use development environment to bypass this check. 

```
service_description:
  environment: development
```

Please notice that consumer is also need reboot or old interface metadata will be used. 

# interface compatibility common problems and their solutions

During the development phase, due to various interface modification, the data of the service center would not be cleaned up, and the interface call fails when debugging. Developers are advised to install and download a [frontend] of the service center (http://apache.org/dyn/closer.cgi/incubator/servicecomb/incubator-servicecomb-service-center/1.0.0-m1/), anytime Clean up service center data.

If you use Huawei's public cloud online service center, you can log in directly using the management functions provided by the microservice engine to delete.

During the release phase, you need to review the steps of the interface-compatible practices to ensure that interface compatibility issues are not online.

If you accidentally miss one of these steps, it may lead to the following interface compatibility issues:

1. If the interface is modified or deleted: some old Consumers will fail to request the new route of the new Provider.
2. If you forget to modify the microservice version number: some new Consumers will fail to request the route of the old Provider.
3. If you forget to configure the minimum dependent version of the Consumer: when the deployment order is to stop the Consumer first, then start the Consumer, then stop the Provider, and then start the Provider. The Consumer cannot obtain the new interface information, and the old interface is used. When the Provider starts, The Consumer initiates a call to the new interface that fails; or fails to call the new interface before the Provider started.

Workarounds for problems: There are different interface compatibility issues and different handling methods. In extreme cases, you only need to clean up the Provider and Consumer microservices, and then restart the microservice. When the service call relationship is complexed, the interface compatibility problem will be more extensive and clean the Provider, and Consumer data will become complicated. Therefore, it is recommended to follow the above specifications to avoid incompatibility.


