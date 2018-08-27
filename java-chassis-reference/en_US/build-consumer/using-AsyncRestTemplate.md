# Develop service consumers with AsynRestTemplate

## Conceptual explanation

The AsyncRestTemplate development method allows users to make service calls asynchronously. The specific business process is similar to restTemplate, except that the service is called asynchronously.

## Sample code

The AsyncRestTemplate instance is created and retrieved via new CseAsyncRestTemplate(), which is then used to make service calls through a custom URL.

* Spring MVC client code example

```java

@Component
public class SpringmvcConsumerMain {
  private static final Logger LOG = LoggerFactory.getLogger(SpringmvcConsumerMain.class);

  public static void main(String[] args) throws Exception {
    init();
    Person person = new Person();
    person.setName("ServiceComb/Java Chassis");
    //AsyncRestTemplate Consumer
    CseAsyncRestTemplate cseAsyncRestTemplate = new CseAsyncRestTemplate();
    ListenableFuture<ResponseEntity<String>> responseEntityListenableFuture = cseAsyncRestTemplate
        .postForEntity("cse://springmvc/springmvchello/sayhi?name=Java Chassis", null, String.class);
    ResponseEntity<String> responseEntity = responseEntityListenableFuture.get();
    System.out.println("AsyncRestTemplate Consumer sayHi services: " + responseEntity.getBody());

    HttpEntity<Person> entity = new HttpEntity<>(person);
    ListenableFuture<ResponseEntity<String>> listenableFuture = cseAsyncRestTemplate
        .exchange("cse://springmvc/springmvchello/sayhello", HttpMethod.POST, entity, String.class);
    //    ResponseEntity<String> responseEntity1 = listenableFuture.get();
    //    System.out.println("AsyncRestTemplate Consumer sayHello services: " + responseEntity1.getBody());
    // Set callback function
    listenableFuture.addCallback(
        new ListenableFutureCallback<ResponseEntity<String>>() {
          @Override
          public void onFailure(Throwable ex) {
            LOG.error("AsyncResTemplate Consumer catched exception when sayHello, ", ex);
          }

          @Override
          public void onSuccess(ResponseEntity<String> result) {
            System.out.println("AsyncRestTemplate Consumer sayHello services: " + result.getBody());
          }
        });
  }

  public static void init() throws Exception {
    Log4jUtils.init();
    BeanUtils.init();
  }
}

```

> Description:
>
> * The format of the URL is the same as RestTemplate. For details, please refer to restTemplate.
> * Here you use the custom ListenableFuture class as a placeholder to get the results you might get after the remote call ends. At the same time, you can customize the callback function to batch process the results that may be returned.
