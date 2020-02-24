# 2.0.1 新特性介绍： date和date-time

OpenAPI 针对时间定义了两种类型 [date 和 date-time](https://swagger.io/docs/specification/data-models/data-types/#string)。
JavaChassis 在2.0.1之前的版本只支持使用 date-time，而且必须要求使用 `java.util.Date` 作为运行时类型，
2.0.1 版本扩充了 date 和 date-time 的实现，开发者可以使用更加灵活的方式使用这两种类型。

## 使用 date

可以在 query, path, body 等参数中使用 date 类型。 date 类型对应的 Java 类型为 `java.time.LocalDate`。
使用 Spring MVC， 分别采用如下方式定义接口：

```java
@GetMapping(path = "/getLocalDate")
public LocalDate getLocalDate(@RequestParam("date") LocalDate date) {
return date;
}

@GetMapping(path = "/getLocalDate/{date}")
public LocalDate getLocalDatePath(@PathParam("date") LocalDate date) {
return date;
}

@PostMapping(path = "/postLocalDate")
public LocalDate postLocalDate(@RequestBody LocalDate date) {
return date;
}
```

其中 `getLocalDatePath` 接口定义生成的 swagger 描述如下：

```yaml
/getLocalDate/{date}:
get:
  operationId: "getLocalDatePath"
  parameters:
  - name: "date"
    in: "path"
    required: true
    type: "string"
    format: "date"
  responses:
    "200":
      description: "response of 200"
      schema:
        type: "string"
        format: "date"
```

可以看出，date 在网络上是通过 String 进行编码进行传输的， 格式是标准的格式， 比如 `2020-02-20`。

## 使用 date-time

可以在 query, path, body 等参数中使用 date-time 类型。 date 类型对应的 Java 类型为 `java.time.LocalDateTime`，
或者 `java.util.Date` 。
使用 Spring MVC， 分别采用如下方式定义接口：

```java
@GetMapping(path = "/getDate")
public Date getDate(@RequestParam("date") Date date) {
return date;
}

@GetMapping(path = "/getDatePath/{date}")
public Date getDatePath(@PathParam("date") Date date) {
return date;
}

@PostMapping(path = "/postDate")
public Date postDate(@RequestBody Date date) {
return date;
}

@GetMapping(path = "/getLocalDateTime")
public LocalDateTime getLocalDateTime(@RequestParam("date") LocalDateTime date) {
return date;
}

@GetMapping(path = "/getLocalDateTime/{date}")
public LocalDateTime getLocalDateTimePath(@PathParam("date") LocalDateTime date) {
return date;
}

@PostMapping(path = "/postLocalDateTime")
public LocalDateTime postLocalDateTime(@RequestBody LocalDateTime date) {
return date;
}
```

其中 `getLocalDateTimePath` 接口定义生成的 swagger 描述如下：

```yaml
/getLocalDateTime/{date}:
get:
  operationId: "getLocalDateTimePath"
  parameters:
  - name: "date"
    in: "path"
    required: true
    type: "string"
    format: "date-time"
  responses:
    "200":
      description: "response of 200"
      schema:
        type: "string"
        format: "date-time"
```

可以看出，date-time 在网络上是通过 String 进行编码进行传输的， 格式是标准的格式， 比如 `2017-07-21T17:32:28Z`。
由于 date-time 的标准格式包含特殊字符，在作为 query 或者 path 参数的时候， 需要做好 URL 编解码，
网络上传递的实际内容为 `2017-07-21T17%3A32%3A28Z`， 比如： `http://localhost:8082/dateTime/getLocalDateTime?date=2017-07-21T17%3A32%3A28Z`,
作为 body 参数， 内容不会编解码， 是引号包含起来的 String 类型， 比如 `"2017-07-21T17:32:28Z"`。

