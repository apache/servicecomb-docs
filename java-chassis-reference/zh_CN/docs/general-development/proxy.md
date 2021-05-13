# 代理设置

作为一名开发者，在公司开发环境，可能是通过公司代理网络接入到因特网。如果调试服务时还必须依赖网上资源，比如直接连接公有云服务中心，那么就必须配置代理。

配置方式，在 microservice.yaml 文件增加 proxy 配置：

```yaml
servicecomb:
  proxy:
    enable: true            #是否开启代理
    host: yourproxyaddress  #代理地址
    port: 80                #代理端口
    username: yourname      #用户名
    passwd: yourpassword    #密码
```

有些用户需要通过加密保护密码信息。可以通过实现SPI扩展来实现。需要扩展的SPI接口名称为：org.apache.servicecomb.foundation.common.encrypt.Encryption，实现 decode 接口即可。


