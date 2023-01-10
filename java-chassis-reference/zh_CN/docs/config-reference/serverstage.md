# ServiceStage 配置项

* 已提供的环境参数入口

  |配置项名称|缺省值|功能描述|
  |---|---|---|
  |CAS_APPLICATION_ID|无|cas的应用名称|
  |CAS_COMPONENT_NAME|无|cas的组件名字|
  |CAS_INSTANCE_VERSION|无|cas的实例版本|
  |CAS_INSTANCE_ID|无|cas的实例id|
  |CAS_ENVIRONMENT_ID|无|cas的环境id|
  |SERVICECOMB_SERVICE_PROPS|无|CSE实例的端口|

* 注意事项
1. cas是servicestage的后台服务，以上的值是由ServiceStage部署时自动生成与微服务本身信息无直接逻辑联系，客户可以只关注自身的微服务信息而不关注以上的参数值。
  
2. 以上参数的赋值是ServiceStage部署时由ServiceStage自动注入，未使用ServiceStage的用户可以不必关注这些参数，使用ServiceStage的用户也不必自己手动注入。
