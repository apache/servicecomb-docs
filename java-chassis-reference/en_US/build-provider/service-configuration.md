## [Load Balancing Policy](/build-provider/configuration/lb-strategy.html)
• ServiceComb provides a Ribbon-based load balancing solution which can be configured through file. There are different routing policies including random, sequential, policy based on response time weight etc. [Service Center](https://github.com/apache/incubator-servicecomb-saga)

## [Rate Limiting Policy](/build-provider/configuration/ratelimite-strategy.html) 
• Users can set the rate limiting policy in the provider's configuration. By setting the request frequency from a particular micro service, provider can limit the max number of requests per second.

## [Fallback Policy](/build-provider/configuration/parameter-validator.html)  
• A fallback policy is used when a service request is abnormal.

## [Parameter Validation](/build-provider/configuration/parameter-validator.html)
• Users can set parameter validation rules in the provider's configuration. The rules will validate input parameters when provider APIs are called, so the parameters can be defined in a specific format.