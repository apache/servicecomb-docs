# Communication Protocol
### Concept Description

ServiceComb uses two network channels, REST and Highway, both supporting encrypted Transport Layer Security (TLS) transmission. The REST channel releases services in the standard RESTful form. The consumer can send requests using http client.

### Precautions

Serialization of parameters and the returned values:

Currently, the body parameters of the REST channel support only the application/json serialization. To send form-type parameters to the server, construct a body of the application/json format at the consumer end. Do not send the form type parameters in multipart/form-data format.

Currently, the REST channel supports the application/json and text/plain serialization. A provider uses produces to declare that it has the serialization capability. The consumer specifies the serialization mode of the returned values by setting parameters regarding the requested Accept header. Data serialized in application/json serialization mode is returned by default.
