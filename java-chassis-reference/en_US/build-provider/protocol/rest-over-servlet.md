## REST over Servlet
### Configuration

　　REST over Servlet is deployed and runs using a web container. You need to create a servlet project to pack the microservice, load it to the web container, and then start it. To pack a microservice, you can either fully configure it in the web.xml, or configure its listener and urlPattern in the web.xml and microservice.yaml files, respectively.

* Configure the microservice in the web.xml file.

   The web.xml file is under the src/main/webapp/WEB\_INF directory of the project, and its content is as follows:

   ```xml
   <web-app xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd" version="3.0">  
     <context-param> 
       <param-name>contextConfigLocation</param-name>  
       <param-value>classpath*:META-INF/spring/*.bean.xml classpath*:app-config.xml</param-value> 
     </context-param>  
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

* Configure the listener in the web.xml file and urlPattern in the microservice.yaml file.

   ```xml
   <web-app xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd" version="3.0">  
     <context-param> 
       <param-name>contextConfigLocation</param-name>  
       <param-value>classpath*:META-INF/spring/*.bean.xml classpath*:app-config.xml</param-value> 
     </context-param>  
     <listener> 
       <listener-class>org.apache.servicecomb.transport.rest.servlet.RestServletContextListener</listener-class> 
     </listener> 
   </web-app>
   ```

   In the microservice.yaml file, add a row to specify the urlPattern：

   ```yaml
   servicecomb.rest.servlet.urlPattern: /rest/*
   ```

The two method are equivalent, and they both require that the following dependencies be added in the pox.xml file:

```xml
<dependency> 
  <groupId>org.apache.servicecomb</groupId>  
  <artifactId>transport-rest-servlet</artifactId> 
</dependency>
```

Configuration items that need to be set in the microservice.yaml file are described in Table 1:

Table 1 Configuration items of REST over Servlet

| Configuration Item                  | Default Value | Value Range | Mandatory | Description                              | Remark                                   |
| :---------------------------------- | :------------ | :---------- | :-------- | :--------------------------------------- | :--------------------------------------- |
| servicecomb.rest.address                    | 0.0.0.0:8080  | -           | No        | Specifies the server listening IP address. | -                                        |
| servicecomb.rest.timeout                    | 3000          | -           | No        | Specifies the timeout duration           | The unit is ms.                          |
| servicecomb.request.timeout                 | 30000         | -           | No        | Specifies the request timeout duration.  | The configuration of this parameter for REST over Servlet is the same as that for REST over Vertx. |
| servicecomb.references.\[服务名\].transport    | rest          |             | No        | Specifies the accessed transport type.   | The configuration of this parameter for REST over Servlet is the same as that for REST over Vertx. |
| servicecomb.references.\[服务名\].version-rule | latest        | -           | No        | Specifies the version of the accessed instance. | The configuration of this parameter for REST over Servlet is the same as that for REST over Vertx. |

### Sample Code

The following is an example of the configuration in the microservice.yaml file for REST over Servlet:

```yaml
servicecomb:
  rest:
    address: 0.0.0.0:8080
    timeout: 3000
```
