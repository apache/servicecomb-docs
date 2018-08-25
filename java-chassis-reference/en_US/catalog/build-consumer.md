## Using RestTemplate to develop service consumers
RestTemplate is a RESTful access interface provided by Spring. ServiceComb provides an implementation class for this interface for service calls.

## Using AsynRestTemplate to develop service consumers
The AsyncRestTemplate development method allows users to make service calls asynchronously. The specific business process is similar to restTemplate, except that the service is called asynchronously.

## Using a transparent RPC approach to develop service consumers

The transparent RPC development model allows users to make service calls like a local call through a simple java interface.

## Using a service contract
When a service consumer invokes a service provider's service, a service contract needs to be registered. Consumers have two ways to obtain the provider's service contract. One is to obtain the contract file offline from the provider of the service and manually configure it into the project; the other is to automatically download the contract from the service center.

## Call Control

### Instance level fault isolation
The instance-level fault isolation feature allows the ability to isolate a failed instance by stopping the sending of a request to the failed instance when a partial instance call to the microservice fails.

### Fuse strategy
The fuse strategy is the setting of the ServiceComb fuse function. The user can specify the conditions under which the ServiceComb framework will terminate the send request by configuring the fuse policy.

### Current limiting strategy
The user uses the traffic limiting policy on the consumer side to limit the frequency of requests sent to the specified microservice.

### Fault injection
The user uses fault injection on the consumer side to set the delay and error of the request to the specified microservice and its trigger probability.