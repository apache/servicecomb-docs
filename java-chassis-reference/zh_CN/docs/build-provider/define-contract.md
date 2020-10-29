# 理解服务契约

servicecomb 的核心设计理念是 `以契约为中心`，契约是微服务系统运行和治理的基础。 可以将契约理解为基
于 OpenAPI 规范的微服务接口描述。java chassis 提供了两种方式定义契约：`code first` 和
 `contract first` 。

* code first

  开发者首先通过 JAVA 代码定义接口信息，servicecomb 会根据代码定义，生成以 yaml 文件描述的 OpenAPI
  文档。 servicecomb 支持使用 `JAX-RS`, `Spring MVC` 等  REST Annotation 描述接口信息，还可以通过
  swagger API 补充其他接口信息。 在使用 `RPC` 方式定义接口的时候， 系统会按照默认的规则生成接口描述，
  也可以使用这些标签修饰接口信息，让契约信息更加容易阅读和理解。

* contract first

  开发者先通过契约编辑器书写 yaml 格式的接口描述，然后通过代码生成工具，生成项目代码。这种方式通常
  需要定义一套标准的软件工程规范，并提供相关的工具支持。这种方式更加容易实现接口规范管理，实现测试自动化
  等软件工程流程。

由于 `contract first` 实践起来，需要配套的管理过程和工具体系支持，这里不详细描述，
本章节简单描述如何书写契约。后续的章节会描述使用 `code first` 的开发细节。

# contract first 开发步骤简要描述

ServiceComb 使用 yaml 文件格式定义服务契约，推荐使用[Swagger Editor](http://editor.swagger.io/#/)工具来编写契约，
可检查语法格式及自动生成API文档。详细的契约文件格式请参考[OpenAPI官方文档](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md)。

契约文件放置在 `resources/microservices` 或者 `resources/application` 目录下，目录结构如下所示。

```yaml
resources
  - microservices  
    - serviceName #微服务名  
      - schemaId.yaml #schema接口的契约
  - applications  
    - appId #应用ID  
      - serviceName #微服务名  
        - schemaId.yaml #schema接口的契约
```

ServiceComb的Swagger契约文件应当使用UTF-8字符集保存。如果当用户使用其他字符集保存契约文件，且文
件中包含中文字符时，可能会导致未知错误。

## 示例代码

`resources/microservices`目录和`resources/application` 目录下的schemaId.yaml文件内容示例如下。

```yaml
swagger: '2.0'
info:
  title: hello
  version: 1.0.0
  x-java-interface: org.apache.servicecomb.samples.common.schema.Hello
basePath: /springmvchello
produces:
  - application/json

paths:
  /sayhi:
    post:
      operationId: sayHi
      parameters:
        - name: name
          in: query
          required: true
          type: string
      responses:
        200:
          description: 正确返回
          schema:
            type: string
        default:
          description: 默认返回
          schema:
            type: string
  /sayhello:
    post:
      operationId: sayHello
      parameters:
        - name: person
          in: body
          required: true
          schema:
            $ref: "#/definitions/Person"
      responses:
        200:
          description: 正确返回
          schema:
            type: string
        default:
          description: 默认返回
          schema:
            type: string
definitions:
  Person:
    type: "object"
    properties:
      name:
        type: "string"
        description: "person name"
    xml:
      name: "Person"
```

ServiceComb中的契约，basePath不需要包含web container的web root，以及servlet的url pattern。
因为ServiceComb支持部署解耦，既可以脱离servlet container独立部署，也可使用war的方式部署
到servlet container中，还可以使用embedded servlet container的方式运行。
部署方式修改导致的实际url变更，ServiceComb consumer业务代码并不需要感知，框架会自动适配。 

说明：

  * info.x-java-interface需要标明具体的接口路径，根据项目实际情况而定。该信息主要是为了和老版本兼容，
    新版本可以不需要指定。
  * SchemaId中可以包含"."字符，但不推荐这样命名。这是由于ServiceComb使用的配置文件是yaml格式的，
    "."符号用于分割配置项名称，如果SchemaId中也包含了"."可能会导致一些支持契约级别的配置无法正确被识别。
  * OperationId的命名中不可包含"."字符。



