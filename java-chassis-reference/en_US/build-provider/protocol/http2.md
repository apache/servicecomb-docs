## Scenario

Users can easily enable Http2 protocol for better performance through configuration.

## External Service Communication Configuration

The configuration for external service communication is in the microservice.yaml file.

* Enable h2\(Http2 + TLS\)

     Append  `?sslEnabled=true` to the listening address to enable  TLS communication on server side. For details, see the section [Using TLS Communication](../../security/tls.md). Then add `&protocol=http2` to enable h2 communication. Here is the sample configuration:

  ```yaml
  servicecomb:
    rest:
      address: 0.0.0.0:8080?sslEnabled=true&protocol=http2
    highway:
      address: 0.0.0.0:7070?sslEnabled=true&protocol=http2
  ```

* Enable h2c\(Http2 without TLS\)

     Simply add `?protocol=http2` to enable h2c communication in the server's configuration:

  ```yaml
  servicecomb:
    rest:
      address: 0.0.0.0:8080?protocol=http2
    highway:
      address: 0.0.0.0:7070?protocol=http2
  ```
* The client will read the server's address configuration from service center, then communicate with the server by http2 protocol.
