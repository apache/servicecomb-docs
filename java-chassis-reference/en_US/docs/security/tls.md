## Scene Description

Users can enable TLS communication through simple configuration to ensure data transmission security.

## External Service Communication Configuration

The configuration related to external service communication is written in the microservice.yaml file.

* Service Center, Configuration Center TLS communication configuration
   The connection between the microservices and the service center and the configuration center can be enabled by changing http to https. The configuration example is as follows:

  ```yaml
  servicecomb:
    service:
      registry:
        address: https://127.0.0.1:30100
    config:
      client:
        serverUri: https://127.0.0.1:30103
  ```

* Service provider enables TLS communication
   When the service provider configures the service listening address, it can open TLS communication by appending `?sslEnabled=true` to the address. The example is as follows:

  ```yaml
  servicecomb:
    rest:
      address: 0.0.0.0:8080?sslEnabled=true
    highway:
      address: 0.0.0.0:7070?sslEnabled=true
  ```

## Certificate Configuration

The certificate configuration item is written in the microservice.yaml file. It supports the unified development of certificates. It can also add tags for finer-grained configuration. The tag configuration overrides the global configuration. The configuration format is as follows:

```
ssl.[tag].[property]
```
The common tags are as follows:

| Project | tag |
| :--- | :--- |
| Service Center | sc.consumer |
| Configuration Center | cc.consumer |
| Kanban Center | mc.consumer |
| Rest server | rest.provider |
| Highway Server | highway.provider |
| Rest client | rest.consumer|
| Highway Client | highway.consumer|
| auth client | apiserver.consumer|
Generally, there is no need to configure tags. The normal situation is divided into three categories: 1. Connecting internal services 2. As a server 3. As a client, if the certificates required by these three types are inconsistent, then you need to use tags to distinguish

The certificate configuration items are shown in Table 1. Certificate Configuration Item Description Table.
**Table 1 Certificate Configuration Item Description Table**

| Configuration Item | Default Value | Range of Value | Required | Meaning | Caution |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Ssl.engine| jdk | - | No | ssl protocol, provide jdk/openssl options | default jdk |
| ssl.protocols | TLSv1.2 | - | No | Protocol List | separated by comma |
| ssl.ciphers | TLS\_ECDHE\_RSA\_WITH\_AES\_256\_GCM\_SHA384,<br/>TLS\_ECDHE\_RSA\_WITH \_AES\_128\_GCM\_SHA256 | - | No| List of laws | separated by comma |
| ssl.authPeer | false | - | No | Whether to authenticate the peer | - |
| ssl.checkCN.host | false | - | No | Check whether the CN of the certificate is checked. | This configuration item is valid only on the Consumer side and is valid using the http protocol. That is, the Consusser side uses the rest channel. Invalid for Provider, highway, etc. The purpose of checking CN is to prevent the server from being phishing, refer to Standard definition: [https://tools.ietf.org/html/rfc2818. ](https://tools.ietf.org/html/rfc2818.) |
| ssl.trustStore | trust.jks | - | No | Trust certificate file | - |
| ssl.trustStoreType | JKS | - | No | Trust Certificate Type | - |
| ssl.trustStoreValue | - | - | No | Trust Certificate Password | - |
| ssl.keyStore | server.p12 | - | No | Identity Certificate File | - |
| ssl.keyStoreType | PKCS12 | - | No | Identity Certificate Type | - |
| ssl.keyStoreValue | - | - | No | Identity Certificate Password | - |
| ssl.crl | revoke.crl | - | No | Revoked Certificate File | - |
| ssl.sslCustomClass | - | org.apache.servicecomb.foundation.ssl.SSLCustom implementation class | No | SSLCustom class implementation for developers to convert passwords, file paths, etc. | - |

> **Description**:
>
> * The default protocol algorithm is a high-intensity encryption algorithm. The JDK needs to install the corresponding policy file. Reference: [http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html]( Http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html). You can use a non-high-intensity algorithm in your profile configuration.
> * Microservice consumers, can specify certificates for different providers (current certificates are issued according to HOST, different providers use a certificate storage medium, this medium is also used by the microservice access service center and configuration center ).

## Sample Code

An example of a configuration for enabling TLS communication in the microservice.yaml file is as follows:
```yaml
servicecomb:
  service:
    registry:
      address: https://127.0.0.1:30100
  config:
    client:
      serverUri: https://127.0.0.1:30103
  rest:
    address: 0.0.0.0:8080?sslEnabled=true
  highway:
    address: 0.0.0.0:7070?sslEnabled=true

#########SSL options
ssl.protocols: TLSv1.2
ssl.authPeer: true
ssl.checkCN.host: true

#########certificates config
ssl.trustStore: trust.jks
ssl.trustStoreType: JKS
ssl.trustStoreValue: Changeme_123
ssl.keyStore: server.p12
ssl.keyStoreType: PKCS12
ssl.keyStoreValue: Changeme_123
ssl.crl: revoke.crl
ssl.sslCustomClass: org.apache.servicecomb.demo.DemoSSLCustom
```
