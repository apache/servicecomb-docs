#Http2

## Scenario

Users can easily enable Http2 protocol for better performance through configuration.

## External Service Communication Configuration

The configuration for external service communication is in the microservice.yaml file.

* Enable h2\(Http2 + TLS\)

     Append  `sslEnabled=true` to the listening address to enable  TLS communication on server side. For details, see the section [Using TLS Communication](../security/tls.md). Then add `protocol=http2` to enable h2 communication. Here is the sample configuration:

  ```yaml
  servicecomb:
    rest:
      address: 0.0.0.0:8080?sslEnabled=true&protocol=http2
  ```

* Enable h2c\(Http2 without TLS\)

     Simply add `protocol=http2` to enable h2c communication in the server's configuration:

  ```yaml
  servicecomb:
    rest:
      address: 0.0.0.0:8080?protocol=http2
  ```
* The client will read the server's address configuration from service center, then communicate with the server by http2 protocol.

Specific examples can refer to [http2-it-tests](https://github.com/apache/servicecomb-java-chassis/blob/master/integration-tests/it-consumer/src/main/java/org/apache/servicecomb/it/ConsumerMain.java)

## http2 server configuration

| configuration                                 | default | description                                             | notice | 
|-----------------------------------------------|---------|-------------------------------------------------------- |--------|
|servicecomb.rest.server.http2.useAlpnEnabled   | true    |Whether to enable ALPN                                   |        |
|servicecomb.rest.server.http2.HeaderTableSize  | 4096    |                                                         |        |
|servicecomb.rest.server.http2.pushEnabled      | true    |                                                         |        |
|servicecomb.rest.server.http2.initialWindowSize| 65535   |                                                         |        |
|servicecomb.rest.server.http2.maxFrameSize     | 16384   |                                                         |        |
|servicecomb.rest.server.http2.maxHeaderListSize|Integer.MAX_VALUE|                                                 |        |
|servicecomb.rest.server.http2.concurrentStreams| 100     |The maximum stream concurrency supported in a connection |The smaller value of the concurrentStreams on the server side and the multiplexingLimit on the client side|

## http2 client configuration

| configuration                                     | default | description                                                                               | notice | 
|---------------------------------------------------|---------|------------------------------------------------------------------------------------------ |--------|
|servicecomb.rest.client.http2.useAlpnEnabled       |true     |Whether to enable ALPN                                                                     |        |
|servicecomb.rest.client.http2.multiplexingLimit    |-1       |The maximum stream concurrency supported in a connection,-1 means no limit                 |The smaller value of the concurrentStreams on the server side and the multiplexingLimit on the client side|
|servicecomb.rest.client.http2.maxPoolSize          |1        |The maximum number of connections established for each IP:Port in each connection pool     |        |
|servicecomb.rest.client.http2.idleTimeoutInSeconds |0        |The timeout period of the idle connection, the connection will be closed after the timeout |        |

