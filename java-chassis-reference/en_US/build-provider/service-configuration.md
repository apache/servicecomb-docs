## [Load Balancing Policy](/build-provider/configuration/lb-strategy.html)
• ServiceComb provides a Ribbon-based load balancing solution. You can configure a load balancing policy in the configuration file. Currently, a load balancing routing policy can be random, sequential, or based on response time weight. [Service Center](https://github.com/apache/incubator-servicecomb-saga)

## [Rate Limiting Policy](/build-provider/configuration/ratelimite-strategy.html) 
• Users at the provider end can use the rate limiting policy to limit the maximum number of requests sent from a specified microservice per second.

## [Fallback Policy](/build-provider/configuration/parameter-validator.html)  
• A fallback policy is used when a service request is abnormal.

## [Parameter Validation](/build-provider/configuration/parameter-validator.html)
• The user uses the parameter validation on the provider client, and can set the corresponding parameter input requirements in advance, and perform the effect processing before the interface is actually called to achieve the effect of the control parameter input standard.

