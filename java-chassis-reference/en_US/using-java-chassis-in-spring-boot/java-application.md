Using JAVA integration, an efficient HTTP server and REST development framework has been added for Spring Boot applications. This way of integration is very simple. Just introduce the relevant dependencies into the project and use the @EnableServiceComb annotation.

This project [code example] (https://github.com/huaweicse/servicecomb-java-chassis-samples/tree/master/spring-boot-simple)



* Introducing dependencies

Add the spring-boot-starter-provider to the dependency to introduce the core functions of the java chassis. The purpose of introducing hibernate-validator is that spring boot will detect the implementation class of validation-api, and it will not start if it is not detected.

```
<dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.apache.servicecomb</groupId>
        <artifactId>java-chassis-dependencies</artifactId>
        <version>1.0.0-m1</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
</dependencyManagement>

<dependencies>
    <dependency>
        <groupId>org.apache.servicecomb</groupId>
        <artifactId>spring-boot-starter-provider</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>org.hibernate</groupId>
        <artifactId>hibernate-validator</artifactId>
    </dependency>
</dependencies>
```


* Enable the core functions of java chassis

Add @EnableServiceComb in front of the startup class.

```
@SpringBootApplication
@EnableServiceComb
public class WebsiteMain {
    public static void main(final String[] args) {
        SpringApplication.run(WebsiteMain.class, args);
    }
}
```


With the above configuration, you can fully use all the functions provided by the java chassis, use the java chassis to develop REST services, and open various governance functions.



* Configure microservices

The microservice.yaml file allows you to customize the microservice information, including the application id, microservice name, listener address and port.



After integrating java chassis, you can develop REST interface through it:

```
@RestSchema(schemaId = "hello")
@RequestMapping(path = "/")
public class HelloService {
    @RequestMapping(path = "hello", method = RequestMethod.GET)
    public String sayHello(@RequestParam(name="name") String name) {
        return "Hello " + name;
    }
}
```



Then you can access it by http://localhost:9093/hello?name=world.
