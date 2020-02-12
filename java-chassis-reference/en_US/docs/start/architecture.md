# Java Chassis Architecture
## Basic Framework
![ServiceComb Model](../assets/images/servicecomb_mode_en.png)

## Purpose

1.To decouple the programming model and communication model, so that a programming model can be combined with any communication models as needed. Application developers only need to focus on APIs during development and can flexibly switch communication models during deployment. Services can also be switched over to a legacy system. The developers simply need to modify the configuration file(or annotation) released by the service.

Currently, applications can be developed in Spring MVC, JAX-RS, or transparent RPC mode.

2. Built-in API-first support. Through contract standardize micro-service development,  realizing cross-language communication, and supporting software toolchain (contract generation code, code generation contract, etc.)  development, to construct a complete development ecology.

3.To define common microservice running model, encapsulating fault tolerance methods to process which from service discovery to interaction process of microservices, The running model can be customized or extended.

## Modules

| Type                   | artifact id            | Available or NOT | Function                                 |
| :--------------------- | :--------------------- | :--------------- | :--------------------------------------- |
| Programming model      | provider-pojo          | Yes              | Provides the RPC development mode.       |
| Programming model      | provider-jaxrs         | Yes              | Provides the JAX-RS development mode.    |
| Programming model      | provider-springmvc     | Yes              | Provides the Spring MVC development mode. |
| Communication on model | transport-rest-vertx   | Yes              | A development framework running over HTTP, it does not depend on Web containers. Applications are packaged as executable .jar files. |
| Communication on model | transport-rest-servlet | Yes              | A development framework running on Web container. Applications are packaged as WAR files. |
| Communication on model | transport-highway      | Yes              | Provides high-performance private communication protocols for Java communication. |
| Running model          | handler-loadbalance    | Yes              | A load balancing module that provides various routing policies and configurations. It is usually used on the Consumer side. |
| Running model          | handler-bizkeeper      | Yes              | Provides service governance functions, such as isolation, fallbreak, and fault tolerance. |
| Running model          | handler-tracing        | Yes              | Invoke tracking chain module, Monitor system integration, Output data of buried point |
