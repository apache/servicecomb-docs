# REST over Servlet
REST over Servlet的本质是将Java Chassis作为一个Servlet，部署到支持Servlet的Web容器中。 通常有两种使用场景：第一种是在
独立的Web容器中部署运行，比如Tomcat；第二种是组合Spring Boot提供的Embedded Tomcat运行。 

本章节主要介绍在独立的Web容器中部署运行。在Spring Boot提供的Embedded Tomcat中运行，请参考
[在Spring Boot中使用java chassis](../using-java-chassis-in-spring-boot/using-java-chassis-in-spring-boot.md)。


## 对外发布的Path
当微服务部署到web容器中时，相对于独立运行，会涉及到web root以及servlet url pattern对url的改变。  
对于传统开发框架而言，需要consumer感知对方的完整url；比如web root为/mywebapp，url pattern为/rest，业务级path为/application，则consumer代码必须通过/mywebapp/rest/application来访问。  
这将导致一旦部署方式发生变化，比如从web容器变成standalone运行，则consumer或是producer必须修改代码来适配这个变化。  

建议使用ServiceComb的部署解耦特性，无论是consumer，还是producer，在代码中都不要感知web root以及url pattern，这样ServiceComb在运行时，会自动适配producer实例的web root以及url pattern。  

对于一些遗留系统改造，用户期望继续使用restTemplate.getForObject("cse://serviceName/mywebapp/rest/application"...)，这个时候，用户必须将接口定义的path定位为: /mywebapp/rest/application，例如：

```
@RestSchema(schemaId = "test")
@RequestMapping(path = "/mywebapp/rest/application")
```

尽管如此，仍然推荐使用部署形态无关的方式来编码，可以减少后续由于部署形态变化，带来的修改代码问题。
## maven依赖

```xml
<dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>transport-rest-servlet</artifactId>
</dependency>
```

## 配置说明  
与servlet机制配合，涉及到以下几个概念：

* 启动spring context  
  注意以下几种启动方式，是N选1的关系，不要同时使用。  

    * 不使用springMVC的UI或RestController

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

        其中`classpath*:META-INF/spring/*.bean.xml`可以不在contextConfigLocation中配置，因为ServiceComb机制会确保加载路径中包含它。  
        这里仅仅是个示例，表示如果使用者需要定制contextConfigLocation，可以使用这个方法。  
  
    * 使用springMVC的UI或RestController，且存在org.apache.servicecomb.transport.rest.servlet.CseDispatcherServlet  
    
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

        
        **注意：**  
        该servlet不是ServiceComb的处理入口，仅仅是UI或RestController的处理入口  
 
    * 使用springMVC的UI或RestController，且不存在org.apache.servicecomb.transport.rest.servlet.CseDispatcherServlet  
        需要继承springMVC的DispatcherServlet，再按CseDispatcherServlet的方式，配置自己的实现类
    
            @Override
            protected WebApplicationContext createWebApplicationContext(ApplicationContext parent){
              setContextClass(CseXmlWebApplicationContext.class);
              return super.createWebApplicationContext(parent);
            }

        
* ServiceComb servlet  
  url pattern根据业务自身规划设置即可，下面的`/rest/*`仅仅是示例，不是固定值。  
  url pattern必须以`/*`结尾  
  以下两种声明方式也是多选一的关系，不要同时使用
  
    * 标准声明
  
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

  
    * 快捷声明  
 
         在microservice.yaml文件中指定urlPattern，ServiceComb启动时会自动创建RestServlet，并设置相应的urlPattern：

            servicecomb.rest.servlet.urlPattern: /rest/*
  
## 典型场景配置示例

* 纯ServiceComb，标准声明  
      web.xml  
  
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
        
* 纯ServiceComb，快捷声明  
      web.xml
  
          <web-app xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
                 version="3.0">
            <listener>
                <listener-class>org.apache.servicecomb.transport.rest.servlet.RestServletContextListener</listener-class>
            </listener>
          </web-app>

        
      microservice.yaml：
  
          servicecomb.rest.servlet.urlPattern: /rest/*
        
* springMVC UI或RestController接入请求，通过ServiceComb作为consumer发送到内部微服务  
      web.xml：  
  
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
  
      microservice.yaml：不配置servicecomb.rest.address以及servicecomb.rest.servlet.urlPattern  
  
* springMVC UI或RestController接入一些请求，同时通过ServiceComb接入另一些请求  
      web.xml：  
  
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
  
      microservice.yaml：  
  
          servicecomb:
            rest:
              servlet:
                urlPattern: /rest/*
              address: 0.0.0.0:8080
  
## 使用servlet filter注意事项

RestServlet工作于异步模式，根据servlet 3.0的标准，整条工作链都必须是异步模式，所以，如果业务在这个流程上增加了servlet filter，也必须将它配置为异步：

```xml
<filter>
  ......
  <async-supported>true</async-supported>
</filter>
```

## **配置项**

REST over Servlet在microservice.yaml文件中的配置项见表3-9。

表1-1 REST over Servlet配置项说明

| 配置项                                           | 默认值       | 含义                                                  |
| :----------------------------------------------- | :----------- | :---------------------------------------------------- |
| servicecomb.rest.address                         | 0.0.0.0:8080 | 服务监听地址<br>必须配置为与web容器监听地址相同的地址  |
| servicecomb.rest.server.timeout                  | -1           | 异步servlet超时时间, 单位为毫秒<br>建议保持默认值      |
| servicecomb.Provider.requestWaitInPoolTimeout${op-priority}| 30000 | 在同步线程中排队等待执行的超时时间，单位为毫秒 |
| servicecomb.rest.server.requestWaitInPoolTimeout | 30000        | 同servicecomb.Provider.requestWaitInPoolTimeout${op-priority}, 该配置项优先级更高。       |
| servicecomb.rest.servlet.urlPattern              | 无           | 用于简化servlet+servlet mapping配置<br>只有在web.xml中未配置servlet+servlet mapping时，才使用此配置项，配置格式为：/\* 或  /path/\*，其中path可以是多次目录 |
| servicecomb.uploads.maxSize                      | 无           | 文件上传 form body 最大大小                    |
| servicecomb.uploads.maxFileSize                  | 无           | 文件上传所有文件总的大小限制 |
| servicecomb.uploads.fileSizeThreshold            | 无           | 文件上传，实际写入磁盘文件的最大大小 |


