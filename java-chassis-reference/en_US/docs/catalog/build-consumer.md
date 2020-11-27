## Develop consumer with Rest Template
RestTemplate is a RESTful API provided by the Spring framework.  ServiceComb provides the implementation class for service calling

## Develop consumer with AsyncRestTemplate
AsyncRestTemplate allows users to make asynchronous service calls. The logic is similar to restTemplate, except that the service is called asynchronously.

## Develop consumer with transparent RPC

The transparent RPC allows users to make service calls like a local call through a simple java interface.

## Using Contracts
When a consumer calls a service from a provider, the contract is required. The consumer can get the providers' contracts in 2 ways: get the providers' contract from off-line, then manually configure it in the  project. Or, download the contract from the service center.

## Call Control

### Instance level fault isolation
The instance-level fault isolation feature introduces the ability to isolate failed service instances by stopping sending request to them.

### Fallback strategy
The fallback strategy allows user to specify the conditions under which the ServiceComb framework will terminate the requests.

### Rate limiting strategy
The user uses the rate limiting policy on the consumer side to control the frequency of requests sent to the specified microservice.

### Fault injection
The user uses fault injection on the consumer side to set the delay and error of the request sent to the specified microservice and its trigger probability.
