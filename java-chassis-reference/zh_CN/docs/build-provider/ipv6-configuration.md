## 概念阐述

随着IPV6的普及，很多场景下微服务都需要支持IPV6地址，特别是物联网场景下，需要更多的地址。ServiceComb支持Ipv6地址监听、注册和调用，使用起来和默认的Ipv4几乎没有差别，只是配置略不同。

## 配置

1. 把监听地址改成ipv6    
```yaml
servicecomb:
  rest:
    address: '[::]:13092'
```
如果全网监听，ServiceComb JavaChassis 1.2.1以及之前的版本都需要再配置servicecomb.service.publishAddress，否则注册的还是ipv4地址。


2、优秀实践，因为全网监听不太安全，一般建议监听到具体地址，可以使用脚本的方式获取IPV6地址，然后使用环境变量的方式配置地址，比如在启动脚本中使用如下脚本的方式获取网卡ipv6地址，这样就不用配置servicecomb.service.publishAddress，也不会有全网监听的问题。
```yaml
servicecomb:
  rest:
    address: '[${REST_ADDRESS}]:8080'
```
```shell
#/bin/bash

ethname=eth0  #需要监听的网卡名，一般都是eth0，如果是多网卡场景需要修改
export REST_ADDRESS=`ifconfig $ethname | awk '/inet6 /{print $2}'`
nohup java -jar yourapp.jar > console.log 2>&1 &
```
最后可以使用netstat -nltp|grep 8080查看监听地址是否正确，并且到服务中心检查注册的endpoint地址是否正确。    

3、IPV6测试，确保curl支持ipv6，可以使用curl --help，检查是否有-6选项    
curl -v -6 -g --interface eth0 http://[实际ipv6地址]:8080/