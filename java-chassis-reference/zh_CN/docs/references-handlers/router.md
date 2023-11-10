# 灰度发布

使用灰度发布可以实现版本的零中断升级。假设微服务A当前是v1版本，v1版本存在一个实例，现在需要升级到到v2版本。首先配置一个灰度
发布规则，将100%的流量指向v1版本；配置规则生效后，部署v2版本；v2版本启动完毕，配置10%的流量到v2版本；当v2版本
运行稳定，配置100%的流量到v2版本；停止v1版本的实例。

* 前提条件：灰度发布依赖负载均衡管理模块， 参考[负载均衡](./loadbalance.md) 。 


| 配置项名                                   | 描述                   |
| ------------------------------------------ | ---------------------- |
| servicecomb.routeRule.[targetService]      | 目标服务的路由管理规则 |
| servicecomb.router.type                    | 填写'router'           |

灰度发布规则示例如下：

```yaml
servicecomb: 
  router:
    type: router
  routeRule:
    business: |
      - precedence: 2
        match:
          apiPath:
            prefix: "/business/v2"
        route:
          - weight: 100
            tags:
              version: 2.0.0
      - precedence: 1
        match:
          apiPath:
            prefix: "/business/v1/dec"
        route:
          - weight: 50
            tags:
              version: 1.1.0
          - weight: 50
            tags:
              version: 2.0.0

```

#### 规则说明

- 匹配特定请求由match配置,  match的配置逻辑和 [流量特征治理](governance.md) 一致。
- 转发权重定义在routeRule.{targetServiceName}.route下，由weight配置，weight数值表示百分数，需要满足加和等于100，不满足100的部分会用最新版本填充。
- 服务分组定义在routeRule.{targetServiceName}.route下，由tags配置，配置内容有version和app。
- 优先级数量越大优先级越高。

#### 匹配流程

对于上面的示例配置，所有访问provider服务的请求，首先尝试与优先级为2的第一个的match规则进行匹配
header：header存在key为region的按照正则规则区分大小写匹配，存在key为type的进行字符串精准匹配。若匹配
match成功则按照route的配置分配100%的流量到version和tags对应的实例。若匹配match失败则进入下个优先级为1的规则。不同规则优先级不能相等。

#### 异常情况的处理

如果因为规则配置错误，或者没有match到任何一条规则，流量会直接跳过灰度规则，相当于没有灰度发布配置。

如果已经匹配了match，因为对应的version或者tags找不到实例，则剩余流量自动转发到目前的最新版本。
