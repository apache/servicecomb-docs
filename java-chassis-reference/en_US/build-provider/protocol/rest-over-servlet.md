## REST over Servlet
## 配置说明  
与servlet机制配合，涉及到以下几个概念：
* 启动spring context  
  注意以下几种启动方式，是N选1的关系，不要同时使用。  
  * 不使用springMVC的UI或RestController
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
  其中classpath*:META-INF/spring/*.bean.xml，无论任何情况，都可以不在contextConfigLocation中配置，因为ServiceComb机制会确保加载路径中包含它。  
  这里仅仅是个示例，表示如果使用者需要定制contextConfigLocation，可以使用这个方法。  
  
  * 使用springMVC的UI或RestController，且存在org.apache.servicecomb.transport.rest.servlet.CseDispatcherServlet  
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
    **注意：**  
    该servlet不是ServiceComb的处理入口，仅仅是UI或RestController的处理入口  
  * 使用springMVC的UI或RestController，且不存在org.apache.servicecomb.transport.rest.servlet.CseDispatcherServlet  
    需要继承springMVC的DispatcherServlet，再按CseDispatcherServlet的方式，配置自己的实现类
  ```
  @Override
  protected WebApplicationContext createWebApplicationContext(ApplicationContext parent){
    setContextClass(CseXmlWebApplicationContext.class);
    return super.createWebApplicationContext(parent);
  }
  ```
* ServiceComb servlet  
  url pattern根据业务自身规划设置即可，下面的/rest/*仅仅是示例，不是固定值。  
  url pattern必须以/\*结尾  
  以下两种声明方式也是多选一的关系，不要同时使用
  * 标准声明
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
  * 快捷声明  
  在microservice.yaml文件中指定urlPattern，ServiceComb启动时会自动创建RestServlet，并设置相应的urlPattern：
  ```yaml
  servicecomb.rest.servlet.urlPattern: /rest/*
  ```
  
## 典型场景配置示例
* 纯ServiceComb，标准声明  
  web.xml  
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
* 纯ServiceComb，快捷声明  
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
* springMVC UI或RestController接入请求，通过ServiceComb作为consumer发送到内部微服务  
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
  不配置servicecomb.rest.address以及servicecomb.rest.servlet.urlPattern  
* springMVC UI或RestController接入一些请求，同时通过ServiceComb接入另一些请求  
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
## 使用servlet filter注意事项
RestServlet工作于异步模式，根据servlet 3.0的标准，整条工作链都必须是异步模式，所以，如果业务在这个流程上增加了servlet filter，也必须将它配置为异步：
```xml
<filter>
  ......
  <async-supported>true</async-supported>
</filter>
```

