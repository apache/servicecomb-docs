# Java Chassis Architecture
## Basic Framework
![ServiceComb Model](../assets/images/servicecomb_mode_en.png)

## Purpose

1.To decouple the programming model and communication model, so that a programming model can be combined with any communication models as needed. Application developers only need to focus on APIs during development and can flexibly switch communication models during deployment. Services can also be switched over to a legacy system. The developers simply need to modify the configuration file(or annotation) released by the service.

Currently, applications can be developed in Spring MVC, JAX-RS, or transparent RPC mode.

2. Built-in API-first support. Through contract standardize micro-service development,  realizing cross-language communication, and supporting software toolchain (contract generation code, code generation contract, etc.)  development, to construct a complete development ecology.

3.To define common microservice running model, encapsulating fault tolerance methods to process which from service discovery to interaction process of microservices, The running model can be customized or extended.

