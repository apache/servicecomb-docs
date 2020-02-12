HTTP协议已逐渐被标记为不安全，配置HTTPS可以防止用户数据被窃取和篡改，提升了安全性。考虑到性能的影响，我们只在网关使用HTTPS接入，内部服务之间仍然使用HTTP。

使用HTTPS之前，需要准备证书。通常是向权威机构申请，这样的证书才会被浏览器等设备标记为可信。在这个例子中，我们使用通过工具已经生成好的证书。并且将自己的证书通过PKCS12格式存储在server.p12文件中，将CA的证书使用JKS格式存储在trust.jks中。

网关启用HTTP只需要在监听的端口中增加sslEnabled配置项：

```
servicecomb:
  rest:
    address: 0.0.0.0:9090 ?sslEnabled=true
```

然后增加ssl相关的配置。下面的配置包含了TLS的协议、是否认证对端以及证书和密码信息。其中```EdgeSSLCustom```用于证书路径和证书密码的转换，不实现的时候，默认从当前目录读取证书文件，证书的密码明文存储。当业务需要做一些高级安全特性，比如密码保护的时候，可以通过扩展这个类实现。

```
ssl.protocols: TLSv1.2
ssl.authPeer: false
ssl.checkCN.host: false
ssl.trustStore: trust.jks
ssl.trustStoreType: JKS
ssl.trustStoreValue: Changeme_123
ssl.keyStore: server.p12
ssl.keyStoreType: PKCS12
ssl.keyStoreValue: Changeme_123
ssl.crl: revoke.crl
ssl.sslCustomClass: org.apache.servicecomb.samples.porter.gateway.EdgeSSLCustom
```

开发完成后，访问界面就可以通过https进行了

```
https://localhost:9090/ui/porter-website/index.html
```



