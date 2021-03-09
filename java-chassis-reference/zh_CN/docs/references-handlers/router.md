# 灰度发布

使用灰度发布可以实现版本的零中断升级。假设微服务A当前是v1版本，v1版本存在一个实例，现在需要升级到到v2版本。首先配置一个灰度
发布规则，将100%的流量指向v1版本；配置规则生效后，部署v2版本；v2版本启动完毕，配置10%的流量到v2版本；当v2版本
运行稳定，配置100%的流量到v2版本；停止v1版本的实例。

* 前提条件：灰度发布依赖负载均衡管理模块， 参考[负载均衡](./loadbalance.md) 。 

使用灰度发布，需要在项目中引入如下依赖：

```xml
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>handler-router</artifactId>
</dependency>
```

在配置文件中增加配置项：

| 配置项名                                   | 描述                   |
| ------------------------------------------ | ---------------------- |
| servicecomb.routeRule.[targetService]      | 目标服务的路由管理规则 |
| servicecomb.router.type                    | 填写'router'           |
| servicecomb.router.header                  | 从HTTP请求头中提取额外的可以用于匹配HTTP Header信息。 以逗号分隔的多个 Header 名称。|

* 说明：路由规则里面的 headers 来源分为如下几部分：（1）servicecomb.router.header 配置的 Header 信息；（2）Invocation Arguments，即
  业务接口的参数列表。关于Invocation Arguments和Swagger Arguments的差异，请参考 Invocation 类。 Invocation Arguments的优先级
  高于 servicecomb.router.header。 

灰度发布规则示例如下：

```yaml
servicecomb:
    routeRule:  
      provider: | #服务名
        - precedence: 2 #优先级
          match:        #匹配策略
            headers:          #header匹配
              region:            
                regex: 'regoin[0-9]*'
                caseInsensitive: false # 是否区分大小写，默认为false，区分大小写
              type:         
                exact: gray
          route: #路由规则
            - weight: 100 #权重值
              tags:
                version: {version1}
                app: {appId}
        - precedence: 1
          route:
            - weight: 20
              tags:
                version: 0.01
                tags: tag
            - weight: 80
              tags:
                version: 0.02
```

#### 规则说明

- 匹配特定请求由match配置，匹配条件是headers。
- Header中的字段的匹配支持正则匹配、精准匹配。
- 如果未定义match，则可匹配任何请求。
- 转发权重定义在routeRule.{targetServiceName}.route下，由weight配置，weight数值表示百分数，需要满足加和等于100，不满足100的部分会用最新版本填充。
- 服务分组定义在routeRule.{targetServiceName}.route下，由tags配置，配置内容有version和app。
- caseInsensitive 配置条件是否区分大小写，默认false区分大小写，true则不区分大小写。
- 优先级数量越大优先级越高。

#### 匹配流程

对于上面的示例配置，所有访问provider服务的请求，首先尝试与优先级为2的第一个的match规则进行匹配
header：header存在key为region的按照正则规则区分大小写匹配，存在key为type的进行字符串精准匹配。若匹配
match成功则按照route的配置分配100%的流量到version和tags对应的实例。若匹配match失败则进入下个优先级为1的规则。不同规则优先级不能相等。

#### 异常情况的处理

如果因为规则配置错误，或者没有match到任何一条规则，流量会直接跳过灰度规则，相当于没有灰度发布配置。

如果已经匹配了match，因为对应的version或者tags找不到实例，则剩余流量自动转发到目前的最新版本。
