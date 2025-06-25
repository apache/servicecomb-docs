# 灰度发布

使用灰度发布可以实现版本的零中断升级。假设微服务A当前是v1版本，v1版本存在一个实例，现在需要升级到到v2版本。首先配置一个灰度
发布规则，将100%的流量指向v1版本；配置规则生效后，部署v2版本；v2版本启动完毕，配置10%的流量到v2版本；当v2版本
运行稳定，配置100%的流量到v2版本；停止v1版本的实例。

* 前提条件：灰度发布依赖负载均衡管理模块， 参考[负载均衡](./loadbalance.md) 。 


| 配置项名                                   | 描述                   |
| ------------------------------------------ | ---------------------- |
| servicecomb.routeRule.[targetService]      | 目标服务的路由管理规则 |
| servicecomb.router.type                    | 填写'router'           |

## 服务级灰度发布规则

```yaml
servicecomb: 
  router:
    type: router
  routeRule:
    business: |
      - precedence: 3
        emptyProtection: false
        match:
          apiPath:
            prefix: "/business/v3"
        route:
          - weight: 50
            tags:
              version: 1.1.0
          - weight: 50
            tags:
              version: 2.0.0
      - precedence: 2
        emptyProtection: true
        match:
          apiPath:
            prefix: "/business/v2"
        route:
          - weight: 50
            tags:
              version: 1.1.0
          - weight: 50
            tags:
              version: 2.0.0
        fallback:
          - weight: 100
            tags:
              version: 1.0.0
      - precedence: 1
        emptyProtection: false
        match:
          apiPath:
            prefix: "/business/v1/dec"
        route:
          - weight: 50
            tags:
              version: 1.1.0
```

#### 规则说明

- 匹配特定请求由match配置, match的配置逻辑和 [流量特征治理](rule-governance.md) 一致。
- business为目标服务名。
- precedence为规则优先级，数字越大，优先级越高。
- emptyProtection路由空实例保护开关，当按照设定的路由规则未匹配到实例时，开关打开则返回所有实例，开关关闭返回空实例，默认为打开。
- route服务路由规则，weight对应tags实例转发权重，数值为百分数，设置值小于等于100；tags对应路由目标服务属性，内容有version和实例properties。
- fallback降级服务路由规则，当routeRule.{targetServiceName}.route下设置tags未匹配到服务实例时，按fallback路由规则匹配路由实例。

#### 路由规则逻辑

对于上面的示例配置，所有访问provider服务的请求，按照precedence优先级顺序匹配
match规则，未设置match的不需要匹配，直接使用路由规则。如果因为规则配置错误，或者没
有match到任何一条规则，流量会直接跳过灰度规则，相当于没有灰度发布配置。

路由执行逻辑：
- 正常按照route设置的权重、tags进行选择服务实例路由；
- 若route规则选择的实例为空，判断是否设置fallback路由规则，如果存在，则按照fallback设置的权重、tags进行选择服务实例路由；
- 若route规则选择的实例为空，且fallback规则选择实例为空或未设置时：
  1、route设置的权重总和等于100，emptyProtection为true时，返回所有目标服务实例；
  2、route设置的权重总和等于100，emptyProtection为false时，返回空实例；
  3、route设置的权重总和小于100，存在路由规则中未设置的服务实例时，返回未设置的服务实例；
  4、route设置的权重总和小于100，不存在路由规则中未设置的服务实例时，emptyProtection为true时，返回所有目标服务实例，false时返回空实例；

上述规则为例：

- precedence: 3
  1、请求url前缀为/business/v3则使用该条路由规则。
  2、如果存在2.0.0、1.1.0两个version实例时，路由按照权重评分请求到两个实例，即使存在其他实例也是一样。
  3、如果2.0.0、1.1.0中的一个实例不存在，50%返回空实例，即使存在其他实例也是一样。
  4、如果2.0.0、1.1.0实例都不存在，100%返回空实例，即使存在其他实例也是一样。

- precedence: 2
  1、请求url前缀为/business/v2则使用该条路由规则。
  2、如果存在2.0.0、1.1.0两个version实例时，路由按照权重评分请求到两个实例，即使存在其他实例也是一样。
  3、如果version 2.0.0、1.1.0中的一个实例或都不存在，且存在1.0.0对应实例时，route规则未匹配到实例时，返回1.0.0实例。
  4、如果version 2.0.0、1.1.0中的一个实例或都不存在，且不存在1.0.0对应实例时，route规则未匹配到实例时，返回所有实例。

- precedence: 1
  1、请求url前缀为/business/v1/dec则使用该条路由规则。
  2、如果仅存在version 1.1.0实例时，路由完全分配到该实例。
  3、如果存在version 1.1.0及其他实例，那么50%流量分配到1.1.0实例，50%流量分配到其他实例。
  4、如果不存在version 1.1.0实例，那么100%流量分配到其他实例。

## 全局灰度发布规则

```yaml
servicecomb: 
  router:
    type: router
  globalRouteRule: |
    - precedence: 2
      match:
        apiPath:
          prefix: "/business/v2"
      route:
        - weight: 50
          tags:
            version: 1.1.0
        - weight: 50
          tags:
            version: 2.0.0
      fallback:
        - weight: 100
          tags:
            version: 1.0.0
```

#### 规则说明

- 全局路由规则优先级低于服务级路由规则，当全局路由、服务级路由同时存在时，优先使用服务级路由规则。
- 全局路由规则的匹配逻辑与服务级路由相同。