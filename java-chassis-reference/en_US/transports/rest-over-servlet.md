# REST over Servlet

The REST over Servlet mode applications runs in web container. You need to create a new servlet project to wrap the microservices, pack them into war packages, and load them into the web container to run.

## Path for external access

Not like running as a standalone process, when the microservice runs in the web container, the web root and servlet url pattern will be different.

For the traditional development framework, the consumer needs to perceive the complete url of the service; for example, the web root is /mywebapp, the url pattern is /rest, and the business-level path is /application, then consumer must access the service via the url /mywebapp/rest/application.

So when the deployment pattern changes, like from web container to a standalone process, the consumer or producer have to modify the code to adapt to the changes.

It is recommended to use ServiceComb's deployment decoupling feature. Whether it is a consumer or a producer, the application don't perceive the web root and url pattern in the code, while ServiceComb will automatically adapt them for the producer instance at runtime.

For some legacy systems, if users expect to use restTemplate.getForObject("cse://serviceName/mywebapp/rest/application"...) without too many changes, then the path of the interface should be defined as /mywebapp/rest/application:

```
@RestSchema(schemaId = "test")
@RequestMapping(path = "/mywebapp/rest/application")
```

However, it is still recommended to use a deployment-independent way to write the code, which introduces less code modifications when the deployment pattern changes.

## maven dependencies

```xml
<dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>transport-rest-servlet</artifactId>
</dependency>
```

## Configurations

When integrating with servlet, there are a few concepts involved:

- Start spring context  
  Note the following startup methods cannot be used at the same time, just choose one of them.  

  - Without SpringMVC UI or RestController

  ```xml
  <web-app xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
         version="3.0">
    <context-param>
       <param-name>contextConfigLocation</param-name>
       <param-value>classpath*:META-INF/spring/*.bean.xml</param-value>
    </context-param>
    <listener>
       <listener-class>org.apache.servicecomb.transport.rest.servlet.RestServletContextListener</listener-class>
    </listener>
  </web-app>
  ```

  The `classpath*:META-INF/spring/*.bean.xml` configured in contextConfigLocation is optional, because the ServiceComb will ensure that it is included in the load path.

  This is just an example to indicate that the user can customize the contextConfigLocation.

  - Use SpringMVC  UI or RestController, and org.apache.servicecomb.transport.rest.servlet.CseDispatcherServlet exists

  ```xml
  <web-app xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
         version="3.0">
    <servlet>
      <servlet-name>SpringMVCServlet</servlet-name>
      <servlet-class>org.apache.servicecomb.transport.rest.servlet.CseDispatcherServlet</servlet-class>
      <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
      <servlet-name>SpringMVCServlet</servlet-name>
      <url-pattern>yourUrlPattern</url-pattern>
    </servlet-mapping>
  </web-app>
  ```

  **Note**  
  This servlet is not the processing entry of ServiceComb, but the processing entry of UI or RestController.

  - Use SpringMVC's UI or RestController, and there is no org.apache.servicecomb.transport.rest.servlet.CseDispatcherServlet

    In this case, the application class should inherit SpringMVC's DispatcherServlet, and then configure its implementation classes in CseDispatcherServlet's way.

  ```
  @Override
  protected WebApplicationContext createWebApplicationContext(ApplicationContext parent){
    setContextClass(CseXmlWebApplicationContext.class);
    return super.createWebApplicationContext(parent);
  }
  ```

- ServiceComb servlet  

  The url pattern can be set according to the business logic. The following `/rest/*` is just an example, not a fixed value.

  Url pattern must end with `/*`

  The following two declarations types can not be used at the same time.

  - Standard declaration

  ```xml
  <web-app xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
         version="3.0">
    <servlet>
        <servlet-name>RestServlet</servlet-name>
        <servlet-class>org.apache.servicecomb.transport.rest.servlet.RestServlet</servlet-class>
        <load-on-startup>1</load-on-startup>
        <async-supported>true</async-supported>
    </servlet>
    <servlet-mapping>
        <servlet-name>RestServlet</servlet-name>
        <url-pattern>/rest/*</url-pattern>
    </servlet-mapping>
  </web-app>
  ```

  - Quick declaration 

  ```yaml
  servicecomb.rest.servlet.urlPattern: /rest/*
  ```

  Specify urlPattern in the microservice.yaml file. When ServiceComb starts, it will automatically create RestServlet and set the corresponding urlPattern.

## Configuration example for typical scenarios 

- Standard declaration in pure ServiceComb mode

  web.xml:  

  ```xml
  <web-app xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
         version="3.0">
    <listener>
        <listener-class>org.apache.servicecomb.transport.rest.servlet.RestServletContextListener</listener-class>
    </listener>
    <servlet>
        <servlet-name>RestServlet</servlet-name>
        <servlet-class>org.apache.servicecomb.transport.rest.servlet.RestServlet</servlet-class>
        <load-on-startup>1</load-on-startup>
        <async-supported>true</async-supported>
    </servlet>
    <servlet-mapping>
        <servlet-name>RestServlet</servlet-name>
        <url-pattern>/rest/*</url-pattern>
    </servlet-mapping>
  </web-app>
  ```

- Quick declaration in pure ServiceComb mode 
  web.xml：  

  ```xml
  <web-app xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
         version="3.0">
    <listener>
        <listener-class>org.apache.servicecomb.transport.rest.servlet.RestServletContextListener</listener-class>
    </listener>
  </web-app>
  ```

  microservice.yaml：

  ```yaml
  servicecomb.rest.servlet.urlPattern: /rest/*
  ```

- SpringMVC or RestController provide web services, ServiceComb proxy the requests as consumer

  web.xml：

  ```xml
  <web-app xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
         version="3.0">
    <servlet>
      <servlet-name>SpringMVCServlet</servlet-name>
      <servlet-class>org.apache.servicecomb.transport.rest.servlet.CseDispatcherServlet</servlet-class>
      <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
      <servlet-name>SpringMVCServlet</servlet-name>
      <url-pattern>yourUrlPattern</url-pattern>
    </servlet-mapping>
  </web-app>
  ```

  microservice.yaml：
  Servicecomb.rest.address and servicecomb.rest.servlet.urlPattern are not configured

- SpringMVC UI/RestController and ServiceComb provide services at the same time
  web.xml：

  ```xml
  <web-app xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
         version="3.0">
    <servlet>
      <servlet-name>SpringMVCServlet</servlet-name>
      <servlet-class>org.apache.servicecomb.transport.rest.servlet.CseDispatcherServlet</servlet-class>
      <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
      <servlet-name>SpringMVCServlet</servlet-name>
      <url-pattern>yourUrlPattern</url-pattern>
    </servlet-mapping>
  </web-app>
  ```

  microservice.yaml：  

  ```yaml
  servicecomb:
    rest:
      servlet:
        urlPattern: /rest/*
      address: 0.0.0.0:8080
  ```

## Things to notice with servlet filter

RestServlet works in asynchronous mode. According to the servlet 3.0 standard, the entire work chain must be asynchronous. Therefore, the servlet filter should be set to be asynchronous when it's added to the chain:

```xml
<filter>
  ......
  <async-supported>true</async-supported>
</filter>
```

## Configuration items

The related items for REST over Servlet in the microservice.yaml are described below:

Table1-1 REST over Servlet Configuration Items

| Configuration Item                               |Default Value |Required|Description|
| :----------------------------------------------- | :----------- | :----- | :-------- |
| servicecomb.rest.address                         | 0.0.0.0:8080 | No     |The service listening address<br>Should be the same with the web container's listening address|
| servicecomb.rest.server.timeout                  | -1           | No     |Server aync servlet timeout in milliseconds, suggest set to -1                                |
| servicecomb.rest.server.requestWaitInPoolTimeout | 30000        | No     |for sync business logic, timeout in milliseconds for waiting in executor queue                |
| servicecomb.rest.servlet.urlPattern              |              | No     |Used to simplify servlet+servlet mapping config<br>This item is used only when servlet+servlet mapping is not configured in web.xml.The format is:/\* or /path/\*, where path can be nested |

