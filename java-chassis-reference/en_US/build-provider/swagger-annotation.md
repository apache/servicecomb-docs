# Using Swagger annotations

## Concept Description

Swagger provides a set of annotations for describing interface contracts. Users can use annotations to add descriptions of contracts to their code. ServiceComb supports part of these annotations.

## Scene Description

By using annotations to describe interface contracts, users can use ServiceComb's Swagger contract generation function to automatically generate contract documents that meet the requirements without having to manually write and modify contracts, which can effectively improve development efficiency.

## Configuration instructions

The official description can be found in the [Swagger Annotation Document] (https://github.com/swagger-api/swagger-core/wiki/Annotations-1.5.X). You can refer to the official documentation and this guide to learn how to use annotations to specify the properties of a Swagger contract under the ServiceComb framework.

In ServiceComb, Swagger annotations are not required. When a user uses SpringMVC and JAX-RS annotations to annotate microservice methods, ServiceComb can infer the contract information for each microservice method based on the values ​​of these annotations.

### `@Api`

> `@Api` acts at the class level and is used to mark a Class as a Swagger resource in the official Swagger description. However, this annotation is not required in ServiceComb. ServiceComb can determine which classes need to parse the Swagger contract based on `@RestSchema` and `@RpcSchema`.

| Attribute | Type | Description |
| :--- | :------ | :--- |
| Tags | string | set the default tag value of the operation defined under the current Class |
| consumes | string | specify the MIME types of request in schema level, separated by commas |
| produces | string | specify the MIME types of response in schema level, separated by commas |

### `@SwaggerDefinition`

> Acts at the class level to define information in a Swagger resource.

| Attribute | Type | Description |
| :--- | :------ | :--- |
| info.title | string | Contract Document Title |
| info.description | string | Description |
| info.version | string | contract version number |
| info.termsOfService | string | Terms of Service |
| info.contact | string | Contact information, including name, email, url attributes |
| info.license | string | License information, including name, url attribute |
| info.extensions | string | Extended Information |
| consumes | string | Receive Request Format |
| produces | string | returned response format |
| schemes | SwaggerDefinition.Scheme | Optional values ​​are `HTTP/HTTPS/WS/WSS/DEFAULT` |
| tags | `@Tag` | Tag definition, @Tag contains three attributes: name, description, externalDocs |
| externalDocs | `@externalDocs` | External documentation links, including values ​​and urls |

### `@ApiOperation`

> Acts at the method level to describe a Swagger operation.

| Attribute | Type | Description |
| :--- | :------ | :--- |
| value | string | A brief description of the method, corresponding to the `summary` field of the Swagger contract operation |
| notes | string | Details, corresponding to the `description` field of the Swagger contract operation |
| Tags | string | label operation label |
| code | int | HTTP status code for response messages |
| response | Class<?> | Method return value type |
| responseContainer | string | The container type that wraps the return value. The optional values ​​are `List`, `Set`, `Map` |
| ResponseHeaders | `@ResponseHeader` | HTTP response message header, ServiceComb support attribute value of` name`, `response`,` responseContainer` |
| Consumes | string | specified data format request body |
| Produces | string | body in response to the data format specified |
| Protocols | string | the available protocol (schemes), possible values ​​are `http`,` https`, `ws`,` wss`, separated by commas |
| httpMethod | string | Set HTTP method |
| hidden | boolean | Weather to hide this method |

### `@ApiImplicitParam`

> Acts at the method level, which is used to describe the properties of the parameters of the operation in the Swagger document.
>
> **Note**: ServiceComb can automatically infer parameter names based on code and SpringMVC, JAX-RS annotations. If the parameter name of the `@ApiImplicitParam` configuration is different from the automatically inferred parameter name, then the parameter of the annotation configuration will be added as a new parameter to the operation in which the annotation is located; otherwise, the property of the parameter with the same name will be overwritten.

| Attribute | Type | Description |
| :--- | :------ | :--- |
| name | string | parameter name |
| value | string | Parameter Description |
| required | boolean | Is this a required parameter |
| dataType | string | Parameter Data Type |
| paramType | string | parameter location, valid optional value is path/query/body/header/form |
| allowableValues ​​| string | Range of valid values ​​for |
| allowEmptyValue | boolean | Whether to allow null values ​​|
| allowMultiple | boolean | Whether to allow multiple values ​​(if true, parameters can be used as an array) |
| collectionFormat | string | In which format the parameter array is specified, the current ServiceComb support value is `csv/multi` |
| defaultValue | string | parameter default |
| example | string | Example value for a non-body parameter |
| format | string | Allows users to customize the data format. See the Swagger official documentation for details.

### `@ApiImplicitParams`

> `@ApiImplicitParams` acts on methods, class levels, and is used to batch specify multiple `@ApiImplicitParam`.

| Attribute | Type | Description |
| :--- | :------ | :--- |
| value | `@ApiImplicitParam` | Parameter definition |

### `@ApiResponse`

> Used to describe the meaning of the HTTP status code of the returned message. Usually `@ApiOperation` can represent the HTTP status code of a normal return message. In other cases, the HTTP status code is described by this note. According to the Swagger official documentation, this annotation should not be used directly at the method level, but should be included in `@ApiResponses`.

| Attribute | Type | Description |
| :--- | :------ | :--- |
| code | int | Return the HTTP status code of the message |
| message | string | Description of the return value |
| response | Class<?> | Type of return value |
| responseContainer | string | The wrapper for the return value, with an optional value of `List/Set/Map` |
| responseHeaders | @ResponseHeader | Describes a set of HTTP headers that return messages. The properties of `@ResponseHeader` supported by ServiceComb are `name`, `description`, `response`, `responseContainer` |

### `@ApiResponses`

> Acts on methods, class levels, to specify and specify a set of return values.

| Attribute | Type | Description |
| :--- | :------ | :--- |
| value | `@ApiResponse` | Return to message description |
