## Scene Description

Users can enable Http2 to communicate and improve performance through simple configuration.

## External Service Communication Configuration

The configuration related to external service communication is written in the microservice.yaml file.

* Enable h2\(Http2 + TLS\) for communication
   When configuring the service listening address, the server can enable TLS communication by appending `?sslEnabled=true` to the address. For details, see the section [Using TLS Communication] (../../security/tls.md). Then add `&protocol=http2` to enable h2 communication. An example is as follows:

  ```yaml
  servicecomb:
    rest:
      address: 0.0.0.0:8080?sslEnabled=true&protocol=http2
    highway:
      address: 0.0.0.0:7070?sslEnabled=true&protocol=http2
  ```

* Enable h2c\(Http2 without TLS\) for communication
   When the server configures the service listening address, the server can enable h2c communication by appending `?protocol=http2` to the address. An example is as follows:

  ```yaml
  servicecomb:
    rest:
      address: 0.0.0.0:8080?protocol=http2
    highway:
      address: 0.0.0.0:7070?protocol=http2
  ```
* The client will communicate using http2 by reading the configuration in the server address from the service center.



