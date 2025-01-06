# 使用 consul

可以通过 [Consul官网](https://developer.hashicorp.com/consul/install?product_intent=consul) 下载和安装 Consul。

使用Consul需要确保下面的软件包引入：

```xml
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>registry-consul</artifactId>
  <version>x.x.x</version>
</dependency>
```

* 表1-1 访问consul常用的配置项

| 配置项                                             | 默认值         | 是否必选 | 含义                            |
|:--------------------------------------------------|:---------------|:-----|:-----------------------------------|
| servicecomb.registry.consul.enabled               | true           | 是    | 是否启用consul                    |
| servicecomb.registry.consul.host                  | localhost      | 是    | consul的ip                        |
| servicecomb.registry.consul.port                  | 8500           | 是    | 是否注册契约
| servicecomb.registry.consul.disdovery.enabled     | true           | 是    | 是否启用服务发现                    |
| servicecomb.registry.consul.disdovery.acl-token   | null           | 否    | 当服务端启用ACL认证后,必须设置该值   |
| servicecomb.registry.consul.disdovery.tags        | 空数组          | 否    | 服务的标签                         |
| servicecomb.registry.consul.disdovery.watch-seconds | 8            | 是    | 监听服务变化的时间频率,在1-9之间,单位秒 |

## Consul开启ACL
开启Consul ACL的步骤如下：

1. 在各个节点，新建目录，如:config
1. 在config目录下新建 XXX.hcl
1. 在XXX.hcl中添加acl的配置
```
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
}
```
* 参数说明
```
enaled=true 代表开启ACL
default_policy="deny" 默认为allow，如果需要自定义权限，需要将其设置为deny
ebale_token_persistence=true 开启token持久化，将token持久化到磁盘上
```
1. 服务器端的启动命令添加 -config-data=config目录的绝对或相对路径 的启动参数
1. 详细步骤可以参考：https://www.cnblogs.com/yucongblog/p/17833634.html