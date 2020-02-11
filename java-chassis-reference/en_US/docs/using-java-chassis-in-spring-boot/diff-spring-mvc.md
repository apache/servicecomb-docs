
Java chassis supports the use of the label \(org.springframework.web.bind.annotation\) provided by Spring MVC to declare the REST interface, but the two are independent implementations and have different design goals. The goal of the java chassis is to provide a cross-language framework that supports multiple communication protocols. Therefore, some features of Spring MVC that are not very good for cross-language support are removed, and features that are strongly related to a specific running framework are not supported, such as direct access to the Servlet protocol definition. HttpServletRequest. Here are some notable differences.

* Service declaration method

Spring MVC uses @RestController to declare the service, and java chassis uses @RestSchema to declare the service and needs to display the service path using @RequestMapping to distinguish whether the service uses Spring MVC Annotations or JAX RS Annotations.

```
@RestSchema(schemaId = "hello")
@RequestMapping(path = "/")
```

The schema is the service contract of java chassis, which is the basis of service runtime. Service management, codec and so on are all based on contract. In a cross-language scenario, the contract also defines the parts of the language that can be understood simultaneously.

* Data type support

With Spring MVC, you can use multiple data types in a service definition as long as it can be serialized and deserialized by json. Such as:

```
// abstract type
Public void postData(@RequestBody Object data)
// Interface definition
Public void postData(@RequestBody IPerson interfaceData)
//  Generics tpye without specified type
Public void postData(@RequestBody Map rawData)
// specific protocol related types
Public void postData(HttpServletRequest request)
```

The above types are not supported in the java chassis. Because java chassis will generate contracts according to the interface definition, from the above interface definition, if you do not combine the actual implementation code or additional development documentation, you can not directly generate the contract. That is, standing in the REST perspective of the browser, I don't know how to construct the message content in the body.

To support rapid development, the data type restrictions of java chassis are also constantly expanding, such as support for HttpServletRequest, but when they are used, they are different from the semantics of the WEB server, such as the inability to directly manipulate the stream. Therefore, it is recommended that the developer use the type of contract that can be described as much as possible in the usage scenario so that the code is more readable.

For more information on java chassis support for data types, please refer to the "Supported Data Types" section.

* Common Annotation Support

The following is the java chassis support for Spring MVC common annotation.

| Tag Name | Support | Description |
| :--- | :--- | :--- |
| RequestMapping | Yes | |
| GetMapping | Yes | |
| PutMapping | Yes | |
| PostMapping | Yes | |
| DeleteMapping | Yes | |
| PatchMapping | Yes | |
| RequestParam | Yes | |
| CookieValue | Yes | |
| PathVariable | Yes | |
| RequestHeader | Yes | |
RequestBody | Yes | Currently supports application/json,plain/text |
RequestPart | Yes | For file upload scenarios, the corresponding tags are Part, MultipartFile |
| ResponseBody | No | The return value defaults to the body return |
| ResponseStatus | No | The error code returned can be specified by ApiResponse |
RequestAttribute | No | Servlet Protocol Related Tags |
SessionAttribute | No | Servlet Protocol Related Tags |
| MatrixVariable | No | |
| ModelAttribute | No | |
| ControllerAdvice | No | |
| CrossOrigin | No | |
| ExceptionHandler | No | |
| InitBinder | No | |

* Other

Using POJO objects for parameter mapping in GET methods is not supported.

For example: public void getOperation\(Person p\)

Do not support the use of Map mapping in the GET method for all possible parameters.

For example: public void getOperation\(Map&lt;String,String&gt; p\)
