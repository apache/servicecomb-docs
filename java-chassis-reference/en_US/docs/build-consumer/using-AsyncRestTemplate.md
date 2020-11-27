# Develop consumer with AsyncRestTemplate

## Concepts

AsyncRestTemplate allows users to make asynchronous service calls. The logic is similar to restTemplate, except that the service is called asynchronously.

## Sample code

The AsyncRestTemplate instance is created and retrieved via `new CseAsyncRestTemplate()`, which is then used to make service calls through a custom URL.

* Spring MVC client sample code

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
    // Set the callback function
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

> Note
>
> * The URL format is the same with RestTemplate, refer to restTemplate for details
> * The custom ListenableFuture class is the placeholder to get the results from the remote call. Users can also customize the callback function to process the return results in batches.

