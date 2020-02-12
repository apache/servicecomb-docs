# Develop consumer with Rest Template  
## Concepts

Rest Template is a RESTful API provided by the Spring framework.  ServiceComb provides the implementation class for service calling

## Scenario

With ServiceComb's RestTemplate instance, users can call the service with a customized URL without knowing the service's address.



## Sample Code

The RestTemplate instance is created by the static method  `RestTemplateBuilder.create()`. Then, users can call the microservices with the instance and the customized URL. The code is as follows:

- Sample code for Sprint MVC consumer

```java
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import org.apache.servicecomb.foundation.common.utils.BeanUtils;
import org.apache.servicecomb.foundation.common.utils.Log4jUtils;
import org.apache.servicecomb.provider.springmvc.reference.RestTemplateBuilder;
import org.apache.servicecomb.samples.common.schema.models.Person;

@Component
public class SpringmvcConsumerMain {
    private static RestTemplate restTemplate = RestTemplateBuilder.create();

    public static void main(String[] args) throws Exception {
        init();
        Person person = new Person();
        person.setName("ServiceComb/Java Chassis");
        String sayHiResult = restTemplate
                .postForObject("cse://springmvc/springmvchello/sayhi?name=Java Chassis", null, String.class);
        String sayHelloResult = restTemplate
                .postForObject("cse://springmvc/springmvchello/sayhello", person, String.class);
        System.out.println("RestTemplate consumer sayhi services: " + sayHiResult);
        System.out.println("RestTemplate consumer sayhello services: " + sayHelloResult);
    }

    public static void init() throws Exception {
        Log4jUtils.init();
        BeanUtils.init();
    }
}
```

- Sample code for JAX RS Consumer:

```java
@Component
public class JaxrsConsumerMain {

    public static void main(String[] args) throws Exception {
        init();
        // The rest is just like the Spring MVC Consumer sample code, notice that if the provider only accepts GET requests, the consumer should use method getForObject()
        RestTemplate restTemplate = RestTemplateBuilder.create();
        String result = restTemplate.getForObject("cse://jaxrs/jaxrshello/saybye", String.class);
    }

    public static void init() throws Exception {
        Log4jUtils.init();
        BeanUtils.init();
    }
}
```
> NOTE:
>
> - The URL should be in format: `cse//microserviceName/path?querystring`. Taking the provider example from [Develop micro service with SpringMVC](../build-provider/springmvc.md), the micro service's name is `springmvc`, the basePath is `/springmvchello`, then the microserviceName in the URL is `springmvc`, the path to call sayhi is `springmvchello/sayhi`, so the URL for sayhi in the sample is `cse://springmvc/springmvchello/sayhi?name=Java Chassis`, below is the code for the provider:

```java
@RestSchema(schemaId = "springmvcHello")
@RequestMapping(path = "/springmvchello", produces = MediaType.APPLICATION_JSON)
//这里 path = “/springmvchello” 中的 springmvchello 就是 上述的basePath
public class SpringmvcHelloImpl implements Hello {
    @Override
    @RequestMapping(path = "/sayhi", method = RequestMethod.POST)
    public String sayHi(@RequestParam(name = "name") String name) {
        return "Hello " + name;
    }

    @Override
    @RequestMapping(path = "/sayhello", method = RequestMethod.POST)
    public String sayHello(@RequestBody Person person) {
        return "Hello person " + person.getName();
    }
}
```



> The following configuration is the file `resources/microservice.yaml` of the springmvc-provider module in the [SpringMVC sample](https://github.com/apache/incubator-servicecomb-java-chassis/tree/master/samples/springmvc-sample):

```yaml
APPLICATION_ID: springmvc-sample
service_description:
  name: springmvc # The name of the micro service
  version: 0.0.2
servicecomb:
  service:
    registry:
      address: http://127.0.0.1:30100
  rest:
    address: 0.0.0.0:8080
  highway:
    address: 0.0.0.0:7070
  handler:
    chain:
      Provider:
        default: bizkeeper-provider
cse:
  service:
    registry:
      address: http://127.0.0.1:30100		#service center address
```

- With the URL format, ServiceComb framework will perform internal microservice descovery, fallback, fault tolerance and send the requests to the microservice providers.
