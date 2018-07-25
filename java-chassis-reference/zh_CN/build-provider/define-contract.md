# 定义服务契约
``
## 概念阐述

服务契约，指基于OpenAPI规范的微服务接口契约，是服务端与消费端对于接口的定义。java chassis提供了两种方式定义契约：code first和contract first。
* code first

producer使用Jax-RS或SpringMVC的RESTful annotation声明接口的输入、输出参数，或者再配合OpenAPI的annotation，增加人类可读的信息，比如样例代码、文本描述等等；ServiceComb引擎启动时，根据这些annotation生成契约描述，并自动上传到服务中心。producer也可以使用透明RPC方式开发，但是因为没有任何RESTful的annotation指导如何生成契约，所以此时自动生成的契约非常的不RESTful化，不建议使用。
consumer使用透明RPC或RestTemplate进行调用。
code first的开发模式下，开发人员，不必手写契约。

* contract first

此场景下，不使用框架自动生成的契约，而是直接使用开发人员提供的契约文件，这需要由开发人员保证契约与代码的一致性。

## 场景描述

服务契约用于服务端和消费端的解耦，服务端围绕契约进行服务的实现，消费端根据契约进行服务的调用，可支持服务端和消费端采用不同的编程语言实现。

> _**说明:**_  
> 服务提供者在启动时会将接口契约注册到服务中心，可供服务消费者下载使用。接口契约是微服务-版本级别的信息，当多个微服务实例启动时，有一个实例将契约注册到服务中心后，服务中心就不会再用后来者注册的契约信息覆盖已有的契约。因此，仅修改服务提供者的接口信息不会让服务中心存储的契约发生变化，对于服务消费者而言，获取到的接口信息依然是旧的。若要更新服务中心中的接口契约，可以选择升级微服务版本号，或者删除已有的微服务信息（后者不建议在生产环境使用）。

## 配置说明

ServiceComb使用yaml文件格式定义服务契约，推荐使用[Swagger Editor](http://editor.swagger.io/#/)工具来编写契约，可检查语法格式及自动生成API文档。详细的契约文件格式请参考[OpenAPI官方文档](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md)。

契约文件放置在"resources/microservices"或者"resources/application"目录下，目录结构如下所示。

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

> **注意**：
>
> * ServiceComb的Swagger契约文件应当使用UTF-8字符集保存。如果当用户使用其他字符集保存契约文件，且文件中包含中文字符时，可能会导致未知错误。

## 示例代码

`resources/microservices`目录和`resources/application`目录下的schemaId.yaml文件内容示例如下。文件中的接口定义需要与服务的实际接口相符。

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

> **注意**：
>
> * ServiceComb中的契约，建议basePath不要包含web container的web root，以及servlet的url pattern。

因为ServiceComb支持部署解耦，既可以脱离servlet container独立部署，也可使用war的方式部署到servlet container中，还可以使用embedded servlet container的方式运行。
只要base path不包含web root以及url pattern，则部署方式修改导致的实际url变更，ServiceComb consumer业务代码并不需要感知，框架会自动适配。 
> * info.x-java-interface需要标明具体的接口路径，根据项目实际情况而定。
> * SchemaId中可以包含"."字符，但不推荐这样命名。这是由于ServiceComb使用的配置文件是yaml格式的，"."符号用于分割配置项名称，如果SchemaId中也包含了"."可能会导致一些支持契约级别的配置无法正确被识别。
> * OperationId的命名中不可包含"."字符。



