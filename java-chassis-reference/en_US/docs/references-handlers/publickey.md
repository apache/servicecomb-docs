# public key authentication

## Scene Description

Public key authentication is a simple and efficient authentication mechanism between microservices provided by ServiceComb. Its security is based on the trust between microservices and service centers, namely microservices and service centers. The authentication mechanism must be enabled first. Its basic process is as follows:

1. When the microservice starts, generate a secret key pair and register the public key to the service center.
2. The consumer signs the message with his or her private key before accessing the provider.
3. The provider obtains the consumer public key from the service center and verifies the signed message.

Public key authentication needs to be enabled for both consumers and providers.

```
servicecomb:
  handler:
    chain:
      Consumer:
        default: auth-consumer
      Provider:
        default: auth-provider
```

POM Dependency:

* Add dependencies in pom.xml:

  ```
   <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>handler-publickey-auth</artifactId>
    </dependency>
  ```

## Configuring black and white list

Based on the public key authentication mechanism, ServiceComb provides a black and white list function. Through the black and white list, you can control which other services are allowed to be accessed by the microservice. Currently supported by configuring service attributes, the configuration items are as follows:

```
servicecomb:
  publicKey:
    accessControl:
      black:
        list01:
          category: property ## property, fixed value
          propertyName: serviceName ## property name
# property value matches expression.
# only supports prefix match and postfix match and exactly match.
#, e.g., hacker*, *hacker, hacker
          rule: hacker
      white:
        list02:
          category: property
          propertyName: serviceName
          rule: cust*
```

The above rules are configured with black and white rule. includePathPatterns is set the request path that needs auth, and excludePathPatterns is set the request path that not need auth. black/white is microservice black and white rules.

IncludePathPatterns, excludePathPatterns Supports three types of matching rules: prefix (xxx/), suffix (/xxx) and exact match.

Logic for determining whether the current request requires authentication:

1.Check whether the path of current request matches the excludePathPatterns setting rule. If yes, authentication is not required.

2.If excludePathPatterns does not match, check whether a rule is configured for includePathPatterns. If no, all requests need to be authenticated; If set, check whether the path of current request matches the rule. If yes, authentication is required. If no, authentication is not required.

Microservice black/white determination rules: which do not allow microservice names to be accessed by hackers; whitelists allow access to services with microservice names named cust.

ServiceComb provides [trust-sample] (https://github.com/apache/servicecomb-samples/tree/master/java-chassis-samples/trust-sample) to demonstrate the black and white list feature.
