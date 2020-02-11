## Implicit Contract
### Concept Description

　　The Implicit Contract definition is ServiceComb automatically generate a contract of service based on the service implementation class.

### Scenario

　　By using the implicit API definition you can define the implementation class without pre-defining APIs. When the service is started, an API is automatically generated and registered to the service center.

### Involved API

　　Implicit API definitions can be used for Spring MVC, JAX-RS, and transparent RPC development modes, For details, see [Development Style-SpringMVC](/users/develop-with-springmvc/), [Development Stype-JAX-RS](/users/develop-with-jax-rs/) and [Development Style-Transparent RPC](/users/develop-with-transparent-rpc/).

　　When you develop a microservice in transparent RPC mode, the code does not show how you want to define an API, and all generated APIs are POST methods, The input parameters of all the methods will be packaged as a class and transferred as body parameters. Therefore, if you develop providers using implicit APIs, you are advised to choose Spring MVC or JAX-RS mode to obtain complete RESTful statements.
