# Java-Chassis 入门指南 - 开发 porter 应用

示例项目包含如下章节：

  * [User Story](application-porter/user-story.md)
  * [设计微服务](application-porter/design.md)
  * [开发界面\(porter-website\)](application-porter/porter-website.md)
  * [开发文件上传功能\(file-service\)](application-porter/file-service.md)
  * [开发网关\(gateway-service\)](application-porter/gateway-service.md)
  * [使用MyBatis访问数据库\(user-service\)](application-porter/user-service.md)
  * [进行认证和鉴权设计](application-porter/authentication.md)
  * [网关HTTPS安全配置](application-porter/https.md)

示例项目的出发点是帮助开发者开发一个完整的微服务应用。通过一个典型的应用场景，展现一个微服务应用需要解决那些问题，在不同的章节里面，会详细解释解决解决这些问题的技术原理和实现过程。

这个应用场景，是通过收集了一些用户的真实业务场景提取出来的。具体包括：

1. 一个推荐的微服务设计方案；

2. 认证鉴权；

3. 使用mybatis访问数据库；

4. 使用html+js提供界面服务；

5. 上传文件；

6. 使用网关和配置HTTPS；

在这个应用中，尽可能让服务小、每个微服务完全独立，没有代码上的依赖，服务之间通过REST接口相互访问。为了达到这个目的，可能会有些重复代码（包括配置类文件如pom.xml、数据模型类文件等）。开发者可以结合实际情况选择是否提供公共模块，来避免这种情况。在这个项目中选择的是用重复代码来换取自由度的方案。

在实际的代码中，我们还会遵循其他一些和微服务开发有关的原则，包括无状态设计等。这里的例子的目的是搭建一个商业可用的微服务，因此我们会在架构设计、方案设计上也给出一定的建议以及说明这样处理的目的。

本专题的涉及的代码均托管在github，参考 [Porter应用](https://github.com/apache/servicecomb-samples/tree/master/porter_lightweight) 。开发者可以clone一份供学习使用，或者作为正式项目的模板。

