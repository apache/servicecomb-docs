# 使用 Swagger 注解

采用 Spring MVC 或者 JAX RS 注解已经能够描述大部分常用的契约信息，但是仍然不足以描述所有契约信息。可以混合
使用 Swagger 注解，进一步补充契约信息，使得契约信息更加完整。当 Spring MVC 或者 JAR RS 注解描述的信息与
Swagger 注解描述的信息重复时，以 Swagger 注解描述的信息为准，即 Swagger 注解具有更高的优先级。

关于Swagger注解的含义，可以在[Swagger注解文档](swagger-annotation)中找到官方说明。可以对
照该官方文档与本说明来了解如何在ServiceComb框架下使用注解指定Swagger契约的各项属性。

[swagger-annotation]: https://github.com/swagger-api/swagger-core/wiki/Annotations-1.5.X

## `@Api`

> `@Api`作用于类级别，在Swagger官方描述中是用于将一个Class标注为一个Swagger资源。但该注解
> 在ServiceComb中不是必须的，ServiceComb可以根据`@RestSchema`和`@RpcSchema`确定需要从哪些
> 类中解析出Swagger契约。

| 属性 | 类型 | 说明 |
| :--- | :------ | :--- |
| tags | string | 设置当前Class下定义的operation的默认tag值 |
| consumes | string | 指定契约级别的请求体数据格式，可以使用逗号分隔指定多个 |
| produces | string | 指定契约级别的响应体数据格式，可以使用逗号分隔指定多个 |

## `@SwaggerDefinition`

> 作用于类级别，用于定义一个Swagger资源中的信息。

| 属性 | 类型 | 说明 |
| :--- | :------ | :--- |
| info.title | string | 契约文件标题 |
| info.description | string | 描述信息 |
| info.version | string | 契约版本号 |
| info.termsOfService | string | 服务条款 |
| info.contact | string | 联系信息，包含name、email、url属性 |
| info.license | string | 许可证信息，包含name、url属性 |
| info.extensions | string | 扩展信息 |
| consumes | string | 接收的请求格式 |
| produces | string | 返回的应答格式 |
| schemes | SwaggerDefinition.Scheme | 可选值有`HTTP/HTTPS/WS/WSS/DEFAULT` |
| tags | `@Tag` | Tag定义，@Tag包含name、description、externalDocs三个属性 |
| externalDocs | `@externalDocs` | 外部说明文档链接，包含value、url两个属性 |

## `@ApiOperation`

> 作用于方法级别，用于描述一个Swagger operation。

| 属性 | 类型 | 说明 |
| :--- | :------ | :--- |
| value | string | 方法的简要说明，对应于Swagger契约operation的`summary`字段 |
| notes | string | 详细信息，对应于Swagger契约operation的`description`字段 |
| tags | string | 标注operation的标签 |
| code | int | 响应消息的HTTP状态码 |
| response | Class<?> | 方法返回值类型 |
| responseContainer | string | 包装返回值的容器类型，可选值为`List`、`Set`、`Map` |
| responseHeaders | `@ResponseHeader` | 响应消息的HTTP头，ServiceComb支持的属性值为`name`、`response`、`responseContainer` |
| consumes | string | 指定请求体的数据格式 |
| produces | string | 指定响应体的数据格式 |
| protocols | string | 设置可用的协议（schemes），可选值有`http`、`https`、`ws`、`wss`，逗号分隔 |
| httpMethod | string | 设置HTTP方法 |
| hidden | boolean | 是否隐藏此方法 |

## `@ApiImplicitParam`

> 作用于方法级别，用于说明Swagger文档中operation的参数的属性。
>
> **注意**：ServiceComb可以根据代码和SpringMVC、JAX-RS的注解自动推断出参数名称。如果`@ApiImplicitParam`配置的参数名称与自动推断的参数名不同，则则该注解配置的参数将被作为一个新的参数加入到注解所在的operation中；否则将覆盖同名参数的属性。

| 属性 | 类型 | 说明 |
| :--- | :------ | :--- |
| name | string | 参数名称 |
| value | string | 参数说明 |
| required | boolean | 是否是必填参数 |
| dataType | string | 参数数据类型 |
| paramType | string | 参数位置，有效的可选值为path/query/body/header/form |
| allowableValues | string | 参数的有效值范围 |
| allowEmptyValue | boolean | 是否允许空值 |
| allowMultiple | boolean | 是否允许多个值（若为true，则可以将参数作为数组） |
| collectionFormat | string | 以何种格式指定参数数组，当前ServiceComb支持的值为`csv/multi` |
| defaultValue | string | 参数默认值 |
| example | string | 一个非body参数的示例值 |
| format | string | 允许用户自定义数据格式，详情参见Swagger官方文档 |

## `@ApiImplicitParams`

> `@ApiImplicitParams`作用于方法、类级别，用于批量指定多个`@ApiImplicitParam`。

| 属性 | 类型 | 说明 |
| :--- | :------ | :--- |
| value | `@ApiImplicitParam` | 参数定义 |

## `@ApiResponse`

> 用于描述返回消息的HTTP状态码所表达的含义。通常`@ApiOperation`可以表示一个正常情况返回消息的HTTP状态码，其他情形下的HTTP状态码由本注解描述。根据Swagger官方文档的描述，本注解不应该直接用于方法级别，而应该被包含在`@ApiResponses`中。

| 属性 | 类型 | 说明 |
| :--- | :------ | :--- |
| code | int | 返回消息的HTTP状态码 |
| message | string | 返回值的说明信息 |
| response | Class<?> | 返回值的类型 |
| responseContainer | string | 返回值的包装容器，可选值为`List/Set/Map` |
| responseHeaders | @ResponseHeader | 描述一组返回消息的HTTP头，ServiceComb支持的`@ResponseHeader`的属性有`name`、`description`、`response`、`responseContainer` |

## `@ApiResponses`

> 作用于方法、类级别，用于指定和说明一组返回值。

| 属性 | 类型 | 说明 |
| :--- | :------ | :--- |
| value | `@ApiResponse` | 返回消息说明 |
