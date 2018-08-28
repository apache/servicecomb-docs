# 开发指南

这个章节是关于如何基于实现微服务发现功能

## Micro-service注册
```bash
curl -X POST \
  http://127.0.0.1:30100/registry/v3/microservices \
  -H 'content-type: application/json' \
  -H 'x-domain-name: default' \
  -d '{
	"service":
	{
		"appId": "default",
		"serviceName": "DemoService",
		"version":"1.0.0"
	}
}'
```
这时候你可以额获取'DemoService'的ID，如下：

```json
{
    "serviceId": "a3fae679211211e8a831286ed488fc1b"
}
```

## 实例注册

标记micro-service ID并调用实例注册API，根据Service CeCube定义：一个进程应该注册一个实例。

```bash
curl -X POST \
  http://127.0.0.1:30100/registry/v3/microservices/a3fae679211211e8a831286ed488fc1b/instances \
  -H 'content-type: application/json' \
  -H 'x-domain-name: default' \
  -d '{
	"instance": 
	{
	    "hostName":"demo-pc",
	    "endpoints": [
		    "rest://127.0.0.1:8080"
	    ]
	}
}'
```

响应成功如下:

```json
{
    "instanceId": "288ad703211311e8a831286ed488fc1b"
}
```

如果全部成功，意味着你已经完成微服务的注册于实例的发布。  

## 服务发现

下一步是根据服务名称和版本规则的微服务实例发现。

```bash
curl -X GET \
  'http://127.0.0.1:30100/registry/v3/instances?appId=default&serviceName=DemoService&version=latest' \
  -H 'content-type: application/json' \
  -H 'x-consumerid: a3fae679211211e8a831286ed488fc1b' \
  -H 'x-domain-name: default'
```

这里，你可以从响应中获取信息。

```json
{
    "instances": [
        {
            "instanceId": "b4c9e57f211311e8a831286ed488fc1b",
            "serviceId": "a3fae679211211e8a831286ed488fc1b",
            "version": "1.0.0",
            "hostName": "demo-pc",
            "endpoints": [
                "rest://127.0.0.1:8080"
            ],
            "status": "UP",
            "healthCheck": {
                "mode": "push",
                "interval": 30,
                "times": 3
            },
            "timestamp": "1520322915",
            "modTimestamp": "1520322915"
        }
    ]
}
```