For Spring Boot, Spring Cloud, the following components are provided:

* spring-boot-starter-configuration

Access the configuration center. When you need to use the Configuration Center as a dynamic configuration management tool in Spring Boot and Spring Cloud applications, you need dependence of them.



* spring-boot-starter-registry

Access to the service center. When you need to use the service center as a service registration and discovery management tool in Spring Boot and Spring Cloud applications, you need dependence of them.



* spring-boot-starter-discovery

Adapt to the Spring Cloud's DiscoveryClient interface. When using @EnableDiscoveryClient in Spring Cloud, you need dependence of them.



* spring-boot-starter-provider

Enable the core functionality of java chassis via @EnableServiceComb in Spring Boot. This feature can be used for "JAVA application mode" and "Web development mode". In the "Web development mode", the web environment is disabled by spring.main.web-environment=false. Therefore, this module is mainly to solve the problem of "JAVA application mode".



* spring-boot-starter-transport

Enable the core functionality of the java chassis via @EnableServiceComb in Spring Boot and enable the RestServlet for the java chassis. Used in "Web development mode".