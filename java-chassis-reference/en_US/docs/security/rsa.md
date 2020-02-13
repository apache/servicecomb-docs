## Scene Description

Users can enable RSA authentication between services through simple configuration to ensure the security of the service interface.

Detailed introduction [public key authentication] (../references-handlers/publickey.md)

## Consumer Configuration

* Add dependencies in pom.xml:

```
   <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>handler-publickey-auth</artifactId>
    </dependency>
```

* Added to the processing chain in microservice.yaml

```
servicecomb:
  handler:
    chain:
      Consumer:
        default: auth-consumer
```

## Provider Configuration

* Add dependencies in pom.xml:

```
<dependency> 
  <groupId>org.apache.servicecomb</groupId> 
  <artifactId>handler-publickey-auth</artifactId> 
</dependency>
```

* Added to the processing chain in microservice.yaml

```
servicecomb:
  handler:
    chain:
      Provider:
        default: auth-provider
```



