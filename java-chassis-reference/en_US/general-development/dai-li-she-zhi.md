## background

As a developer, in a company development environment, it is possible to access the Internet through a corporate agent network. If debugging services depends on online resources, such as directly connecting to public cloud service center, you must configure the agent.

Configuration mode, add proxy configuration in microservice.yaml file:

```yaml
servicecomb:
  proxy:
    enable: true #Do you want to enable the proxy?
    host: yourproxyaddress #proxy address
    port: 80 #proxy port
    username: yourname #username
    passwd: yourpassword #password
```

Configure password using encryption is supported by using SPI. The SPI intrface is org.apache.servicecomb.foundation.common.encrypt.Encryption. Users can implement customer decode interface.

**Note: Currently only supports connection service center, configuration center support agent. If you connect other three-party services, you can read this configuration, configure the agent yourself, vertx httpclient supports proxy settings, for example: **

```java
    HttpClientOptions httpClientOptions = new HttpClientOptions();
    If (isProxyEnable()) {
      ProxyOptions proxy = new ProxyOptions();
      proxy.setHost("host");
      proxy.setPort(port);
      proxy.setUsername("username");
      proxy.setPassword("passwd");
      httpClientOptions.setProxyOptions(proxy);
    }
```
