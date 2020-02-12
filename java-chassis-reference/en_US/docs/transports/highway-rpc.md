# Highway

## Concept Description

Highway is ServiceComb's private high-performance protocol, it's suitable for the performance sensitive scenarios.

## Configuration

To use the Highway channel, add the following dependencies in the pom.xml file:

```xml
<dependency> 
  <groupId>org.apache.servicecomb</groupId>  
  <artifactId>transport-highway</artifactId> 
</dependency>
```

The Highway configuration items in the microservice.yaml file are described below:

Table 1-1 Highway configuration items

| Configuration Item                          | Default Value                                   | Description                                      | 
| :------------------------------------------ | :---------------------------------------------- | :----------------------------------------------- | 
| servicecomb.highway.address                 |                                                 |The address that the server listens, empty for not listen, just a highway client|
| servicecomb.highway.server.connection-limit | Integer.MAX_VALUE                               |Allow client maximum connections                  |
| servicecomb.highway.server.thread-count     | [verticle-count](verticle-count.md) |highway server verticle instance count(Deprecated)|
| servicecomb.highway.server.verticle-count   | [verticle-count](verticle-count.md) |highway server verticle instance count            |
| servicecomb.highway.client.thread-count     | [verticle-count](verticle-count.md) |highway client verticle instance count(Deprecated)|
| servicecomb.highway.client.verticle-count   | [verticle-count](verticle-count.md) |highway client verticle instance count(Deprecated)|
## Sample code

An example of the Highway configuration in the microservice.yaml:

```yaml
servicecomb:
  highway:
    address: 0.0.0.0:7070
```
