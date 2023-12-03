# 流量控制

流量控制机制通过控制数据传输速率来避免微服务过载运行。本指南将展示如何在 *体质指数* 应用中使用流量控制能力。

## 前言

在您进一步阅读之前，请确保您已阅读了[体质指数微服务应用开发](quick-start-bmi.md)，并已成功运行体质指数微服务。

## 开启

* 在 *体质指数计算器* 的 `application.yml` 文件中指明流控策略：

```yaml
servicecomb:
  matchGroup:
    bmi-operation: |
      matches:
        - apiPath:
            exact: "/bmi"
  rateLimiting:
    bmi-operation: |
      timeoutDuration: 0
      limitRefreshPeriod: 1000
      rate: 1
```

## 验证 

访问 <a>http://localhost:8889</a>，在身高和体重的输入框中输入正数，尝试在1秒内多次点击 *Submit* 按钮，此时就能看到网页由左侧的正常的界面变成了右侧提示由于流控受限而请求被拒的界面。

![流量控制效果图](flow-control-result.png)
