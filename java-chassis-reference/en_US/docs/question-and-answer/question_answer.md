# Problem: How to customize the HTTP status code in the REST interface corresponding to a Java method?

**Solution:**

For normal return values, this can be done with SwaggerAnnotation, for example:

```java
@ApiResponse(code = 300, response = String.class, message = "")
public int test(int x) {
  return 100;
}
```

For the return value of the exception, you can do this by throwing a custom InvocationException, for example:

```java
    public String testException(int code) {
        String strCode = String.valueOf(code);
        switch (code) {
            case 200:
                return strCode;
            case 456:
                throw new InvocationException(code, strCode, strCode + " error");
            case 556:
                throw new InvocationException(code, strCode, Arrays.asList(strCode + " error"));
            case 557:
                throw new InvocationException(code, strCode, Arrays.asList(Arrays.asList(strCode + " error")));
            default:
                break;
        }

        return "not expected";
    }
```

# Problem: How to customize the log configuration of your own microservice

** Solution:**
ServiceComb does not bind the logger, use slf4j, users can freely choose log4j/log4j2/logback and so on.
ServiceComb provides a log4j extension that supports incremental configuration of log4j's properties files on a standard log4j basis.

* By default, the configuration file is loaded from the path: "classpath\*:config/log4j.properties"
* It will actually search all the `config/log4j.properties and config/log4j.*.properties` in the classpath, cut out the `\*` part from the searched file, sort the alpha, then load it in order, and finally compose The file is used as the log4j configuration file.
* If you want to use ServiceComb's log4j extension, you need to call Log4jUtils.init, otherwise it will be used according to the rules of the standard logger.

# Problem: When the service is configured with multiple types of transport, What are the mechanisms for ServiceComb choose which transport to use at runtime?

** Solution:**

* ServiceComb's consumer, transport, handler, and producer are decoupled. The functions work together through contract definitions, that is, whether the consumer uses transparent rpc, or springmvc develops and uses a highway, or RESTful does not transmit on the network. Relationships and producers use transparent rpc, or jaxrs, or springmvc development, and there is no relationship between the receiver and the perception, business development methods and transmission methods.

* Consumer access producer, in the runtime transport selection, the general rule is: the consumer's transport and producer's endpoint intersection, if there are multiple transports after the intersection, then use in turn

Decomposed, there are the following scenarios:

* When a microservice producer provided both the highway and the RESTful endpoint
  * Only the highway transport jar is deployed in the consumer process, only the producer's highway endpoint is accessed.
  * Only the RESTful transport jar is deployed in the consumer process, only the RESTful endpoint of the producer is accessed.
  * The consumer process, while deploying the highway and RESTful transport jar, will take turns accessing the producer's highway, RESTful endpoint

If at this time, the consumer wants to use a transport to access the producer, it can be configured in the microservice.yaml of the consumer process, specifying the name of the transport:

```
servicecomb:
  references:
    transport: 
      <service_name>: highway
```

* When a microservice producer only provided the endpoint of the highway

  * The consumer process only deploys the highway transport jar, and normally uses higway endpoint.
  * The consumer process can only be accessed if only the RESTful transport jar is deployed
  * The consumer process deploys both the highway and the RESTful transport jar, and the highway access is normally used.

* When a microservice producer only provided RESTful endpoints

  * The consumer process only deploys the highway transport jar and cannot access it.
  * The consumer process only deploys RESTful transport jars, which normally use RESTful access
  * The consumer process deploys both the highway and the RESTful transport jar, and the RESTful access is normally used.

# Problem: The swagger body parameter type is incorrectly defined, resulting in no content information for the content registered by the service center.

**Symptom:**

Define the following interface, put the parameters into the body to pass

```
/testInherate:
    post:
      operationId: "testInherate"
      parameters:
      - in: "body"
        name: "xxxxx"
        required: false
        type: string
      responses:
        200:
          description: "response of 200"
          schema:
            $ref: "#/definitions/ReponseImpl"
```

Define the interface in the above way. After the service is registered, the interface type: a string that is queried from the service center is lost and becomes:

```
/testInherate:
    post:
      operationId: "testInherate"
      parameters:
      - in: "body"
        name: "xxxxx"
        required: false
      responses:
        200:
          description: "response of 200"
          schema:
            $ref: "#/definitions/ReponseImpl"
```

If the client does not place a swagger, the following exception is also reported:

Caused by: java.lang.ClassFormatError: Method "testInherate" in class ? has illegal signature. "

**Solution:**

When defining the type of the body parameter, you can't use type directly instead use the schema.

```
/testInherate:
    post:
      operationId: "testInherate"
      parameters:
      - in: "body"
        name: "request"
        required: false
        schema:
          type: string
      responses:
        200:
          description: "response of 200"
          schema:
            $ref: "#/definitions/ReponseImpl"
```

# Problem: Does the microservices framework service call use long live connection?

** Solution:**

Http uses a long connection (with a timeout), and the highway mode uses a long connection (always on).

# Problem: When the service is disconnected from the service center, will the registration information be deleted automatically?

** Solution:**

The service center heartbeat detects that the service instance is unavailable, only the service instance information is removed, and the static data of the service is not removed.


# Problem: How does the microservices framework achieve transparent transmission of data between multiple microservices?

** Solution:**

Transmitting data into:

```java
CseHttpEntity<xxxx.class> httpEntity = new CseHttpEntity<>(xxx);
//Transmission content
httpEntity.addContext("contextKey","contextValue");
ResponseEntity<String> responseEntity = RestTemplateBuilder.create().exchange("cse://springmvc/springmvchello/sayhello",HttpMethod.POST,httpEntity,String.class);
```

Transparent data acquisition:

```java
@Override
@RequestMapping(path="/sayhello",method = RequestMethod.POST)
public String sayHello(@RequestBody Person person,InvocationContext context){
    //Transparent data acquisition
    context.getContext();
    return "Hello person " + person.getName();
}
```

# Problem: How the microservices framework service customizes the return status code

** Solution:**

```java
@Override
@RequestMapping(path = "/sayhello",method = RequestMethod.POST)
public String sayHello(@RequestBody Person person){
    InvocationContext context = ContextUtils.getInvocationContext();
    //自定义状态码
    context.setStatus(Status.CREATED);
    return "Hello person "+person.getName();
}
```

# Problem: Partial exposure of body Model

** Solution:**

In the body object corresponding to an interface, there may be some attributes that are internal. Do not want to open it. Do not bring it out when generating the schema. Use:

```java
@ApiModelProperty(hidden = true)
```

# Problem: The framework obtains the address of the remote consumer

** Solution:**

If you use the http rest method (using the transport-rest-vertx dependency) you can get it in the following way:

```java
HttpServletRequest request = (HttpServletRequest) invocation.getHandlerContext().get(RestConst.REST_REQUEST);
String host = request.getRemoteHost();
```

The actual scene is to take the external address, so it should be LB passed to edgeservice, and edgeService is then passed to the context and passed.


# Problem: Description of the handler

** Solution:**

Consumer default handler is simpleLB, and the handler chain will use this when there is no configuration, if the handler is configured, it must contain the lb handler. Otherwise the call error, need to be described in the document.


# Problem: Netty version problem

** Solution:**

Netty3 and netty4 are completely different tripartites because the coordinates are not the same as the package, so they can coexist, but pay attention to the minor version problem, the version that the small version must use.

# Problem: Service Timeout Settings

** Solution:**

Add the following configuration to the microservice description file (microservice.yaml):

```
servicecomb:
  request:
    timeout: 30000
```

# Problem: Is there a required for the processing chain's sequence of service governance?

**Solution:**

The order of the processing chains is different, and the system works differently. List the common questions below.

1, loadbalance and bizkeeper-consumer

These two sequences can be combined randomly. But the behavior is different.

When loadbalance is in the front, the retry function provided by loadbalance will occur when bizkeeper-consumer throws an exception, such as timeout. But if you have done a fallback policy configuration, such as return null, then loadbalance will not retry.

If loadbalance is behind, the retry will extend the timeout. Even if the retry is successful, if the timeout period set by bizkeeper-consumer is not enough, the final call result will also fail.

2, tracing-consumer, sla-consumer, tracing-provider, sla-provider

These processing chains are recommended to be placed at the very beginning of the processing chain to ensure that the success and failure of the log can be recorded (because the log requires IP and other information, for consumers, can only be placed behind the loadbalance).

If you do not need to record the exception returned by the client, you can put it to the end and only pay attention to the error returned by the network layer. However, if the bizkeeper-consumer timeout returns earlier, the log may not be logged.

3. Suggested order

Consumer: loadbalance, tracing-consumer, sla-consumer, bizkeeper-consumer

Provider: tracing-provider, sla-provider, bizkeeper-provider

This order is sufficient for most scenarios and is not easy to cause errors.

# Problem: the meaning of config item servicecomb.uploads.maxSize in file uploading

config item: servicecomb.uploads.maxSize

meaning: The maximum allowable size of http body in bytes, the default value of -1 means unlimited.
