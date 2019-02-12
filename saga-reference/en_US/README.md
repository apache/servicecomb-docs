# Saga
Apache ServiceComb Saga is an eventually data consistency solution for micro-service applications.

## Features
* High availability. The coordinator is stateless and thus can have multiple instances.
* High reliability. All transaction events are stored in database permanently.
* High performance. Transaction events are reported to coordinator via gRPC and transaction payloads are serialized/deserialized by Kyro.
* Low invasion. All you need to do is add 2-3 annotations and the corresponding compensate methods.
* Easy to deploy. All components can boot via docker.
* Support both forward(retry) and backward(compensate) recovery.
* Easy to extend other coordination protocol which is based on the Pack.

## Architecture
Saga Pack is composed of  **alpha** and **omega**.
* The alpha plays as the coordinator. It is responsible for the management of transactions.
* The omega plays as an agent inside the micro-service. It intercepts incoming/outgoing requests and reports transaction events to alpha.


The following diagram shows the relationships among alpha, omega and services.
![Saga Pack Architecture](static_files/pack.png)

In this way, we can implement different coordination protocols, such as saga and TCC. See [Saga Pack Design](design.md) for details.

Now we have different lanaguage implementation of Omega
* Go lang version of Omega here https://github.com/jeremyxu2010/matrix-saga-go
* C# version of Omega here https://github.com/OpenSagas-csharp/servicecomb-saga-csharp

## Get Started
* For ServiceComb Java Chassis application, please see [Booking Demo](https://github.com/apache/servicecomb-pack/blob/master/demo/saga-servicecomb-demo/README.md) for details.
* For Spring applications, please see [Booking Demo](https://github.com/apache/servicecomb-pack/blob/master/demo/saga-spring-demo/README.md) for details.
* For Dubbo applications, please see [Dubbo Demo](https://github.com/apache/servicecomb-pack/blob/master/demo/saga-dubbo-demo/README.md) for details.
* For TCC with Spring application, please see [Tcc Demo](https://github.com/apache/servicecomb-pack/blob/master/demo/tcc-spring-demo/README.md) for details.
* To debug the applications, please see [Spring Demo Debugging](https://github.com/apache/servicecomb-pack/blob/master/demo/saga-spring-demo#debugging) for details.

## Build and Run the tests from source
* Build the source code and run the tests
   ```bash
      $ mvn clean install
   ```
* Build the source demo docker images and run the accept tests
   ```bash
      $ mvn clean install -Pdemo,docker
   ```
* Current Saga code supports Spring Boot 1.x and Spring Boot 2.x at the same time, saga uses Spring Boot 1.x by default, you can use *-Pspring-boot-2* to switch Spring Boot version to 2.x.
Since Spring Boot supports JDK9 since 2.x, if you want to build and run test the Saga with JDK9 or JDK10, you need to use the spring-boot-2 profile.
   ```bash
      $ mvn clean install -Pdemo,docker,spring-boot-2
   ```
