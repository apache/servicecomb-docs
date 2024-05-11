# 微服务间认证

## 场景描述

微服务间认证是 `Java Chassis` 提供的一种简单高效的微服务之间认证机制，它的安全性建立在微服务与注册中心之间的交互是可信的基础之上，即微服务和注册中心之间必须先启用认证机制。它的基本流程如下：

1. 微服务启动的时候，生成秘钥对，并将公钥注册到注册中心。
2. 消费者访问提供者之前，使用自己的私钥对消息进行签名。
3. 提供者从注册中心获取消费者公钥，对签名的消息进行校验。

## 启用微服务间认证功能

微服务间认证需要同时在消费者和提供者启用公钥认证（如果已经间接引入依赖，则无需添加）。 

* 消费者配置

在pom.xml中增加依赖：

```
<dependency> 
  <groupId>org.apache.servicecomb</groupId> 
  <artifactId>handler-publickey-auth</artifactId> 
</dependency>
```

* 提供者配置

在pom.xml中增加依赖：

```
<dependency> 
  <groupId>org.apache.servicecomb</groupId> 
  <artifactId>handler-publickey-auth</artifactId> 
</dependency>
```

## 配置认证规则(黑白名单)

基于公钥认证机制， `Java Chassis` 提供了黑白名单功能。通过黑白名单，可以控制微服务允许其他哪些服务访问。目前支持通过配置服务属性来控制，配置项如下：

```
servicecomb:
  publicKey:
    accessControl:
      enabled: true
      includePathPatterns: '/authIncludePath'
      excludePathPatterns: '/authExcludePath'
      black:
        list01:
          category: property ## property, fixed value
          propertyName: serviceName ## property name
          # property value match expression. 
          # only supports prefix match and postfix match and exactly match. 
          # e.g. hacker*, *hacker, hacker
          rule: hacker 
      white:
        list02:
          category: property
          propertyName: serviceName
          rule: cust*
```

以上为服务黑白名单规则配置，其中includePathPatterns为需要鉴权请求path，excludePathPatterns为不需要鉴权请求path，black/white分别为微服务黑白名单规则。

includePathPatterns、excludePathPatterns规则设置支持前缀(xxx/)、后缀(/xxx)、精确三种匹配规则。

判断当前请求是否需要鉴权逻辑：

1、判断当前请求path是否能够匹配excludePathPatterns设置规则，如果匹配，则不需要鉴权；

2、excludePathPatterns未满足条件，再判断includePathPatterns是否设置规则，如果未设置则所有请求均需要进行鉴权；如果有设置规则，则判断当前请求path是否能够匹配设置规则，如果匹配则需要鉴权，如果不匹配则不需要鉴权。

微服务黑名单判断规则：不允许微服务名称为hacker的访问；白名单，允许微服务名称为 `cust` 前缀的服务访问。

