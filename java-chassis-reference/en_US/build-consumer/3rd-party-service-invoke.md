# Invoking 3rd party REST service

## Concept Description

ServiceComb allows users to register the information of 3rd party REST service, including endpoint and swagger, so that users can invoke 3rd party services like invoking ServiceComb provider services.
Using this feature, all the requests sent to 3rd party service will be processed by consumer handler chain and HttpClientFilters, which means this feature allows service governance function on invoking 3rd party service, and other ServiceComb custom extension mechanism is also supported.

## Sample Code

1. Assume that there is a REST 3rd party service, whose listen port is 8080, and rest interface contract is like below:
  ```yaml
  ---
  swagger: "2.0"
  info:
    version: "0.0.1"
    title: "3rd party REST service for example"
  basePath: "/rest"
  consumes:
  - "application/json"
  produces:
  - "text/plain"
  paths:
    /{pathVar}:
      get:
        operationId: "testPathVar"
        parameters:
        - name: "pathVar"
          in: "path"
          required: true
          type: "string"
        responses:
          200:
            description: "response of 200, return \"Received, OK. [${pathVar}]\""
            schema:
              type: "string"
  ```

2. To invoke this service, a java interface class should be written according to the rest contract and annotated by rest annotations.
  The way to write java interface class is similar to writing SpringMVC or JAX-RS style
  ServiceComb provider service. Interface code is like below:
  ```java
  @Path("/rest")
  @Api(produces = MediaType.TEXT_PLAIN)
  public interface VertxServerIntf {
    @Path("/{pathVar}")
    @GET
    String testPathVar(@PathParam("pathVar") String pathVar);
  }
  ```

3. Register the information of 3rd party rest service on consumer side:
  ```java
  String endpoint = "rest://127.0.0.1:8080";
  RegistryUtils.getServiceRegistry().registerMicroserviceMappingByEndpoints(
      // 3rd party rest service name, you can specify the name on your need as long as you obey the microservice naming rule
      "thirdPartyService",
      // service version
      "0.0.1",
      // list of endpoints
      Collections.singletonList(endpoint),
      // java interface class to generate swagger schema
      ThirdPartyRestServiceInterface.class
  );
  ```

4. Invoke 3rd party rest service in the way similar to invoking ServiceComb provider service.
  Here is a RPC style invoking example:
  ```java
  // declare rpc reference to 3rd party rest service, schemaId is the same as microservice name
  @RpcReference(microserviceName = "thirdPartyService", schemaId = "thirdPartyService")
  ThirdPartyRestServiceInterface thirdPartyRestService;

  @RequestMapping(path = "/{pathVar}", method = RequestMethod.GET)
  public String testInvoke(@PathVariable(name = "pathVar") String pathVar) {
    LOGGER.info("testInvoke() is called, pathVar = [{}]", pathVar);
    // invoke 3rd party rest service
    String response = thirdPartyRestService.testPathVar(pathVar);
    LOGGER.info("testInvoke() response = [{}]", response);
    return response;
  }
  ```

5. Service governance on invoking 3rd party REST service

  The service governance configuration on invoking 3rd party REST service is similar to the scenario that ServiceComb consumer invokes ServiceComb provider. Take the rate limiting policy for example, the configuration of consumer side microservice.yaml is like below:
  ```yaml
    servicecomb:
      flowcontrol:
        Consumer:
          qps:
            enabled: true
            limit:
              thirdPartyService: 1
  ```
  As the config above, the rate to send request to the service named as "thirdPartyService", which is the 3rd party rest service, is limited to 1QPS.
  When request rate is above 1QPS, consumer will get an `InvocationException` indicating `429 Too Many Requests` error.

> ***Cautions:***
- endpoint is prefixed with `rest`, instead of `http`. You can refer the endpoints registered to service center to write it.
- One 3rd party REST service can hold multiple endpoints. Consumer side load balance function is supported.
- Currently the information of a 3rd party service can only be initialized for once. i.e. adding, deleting and modifying is not supported.
