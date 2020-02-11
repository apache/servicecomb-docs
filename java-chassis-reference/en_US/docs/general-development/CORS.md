# CORS mechanism

## Concept Description

Cross-Origin Resource Sharing (CORS) allows Web servers to perform cross-domain access, enabling browsers to more securely transfer data across domains.

## Scenario

When the user needs to send REST requests across the origin webserver, the CORS mechanism may be used. The microservices that receive cross-domain requests need to enable CORS support.

## Configuration instructions

The CORS function is configured in the microservice.yaml file. The configuration items are described in the following table.

| Configuration Item | Default Value | Range of Value | Required | Meaning |
| :--- | :--- | :--- | :--- | :--- | :--- |
| servicecomb.cors.enabled | `false` | `true`/`false` | No | Whether to enable CORS function | - |
| servicecomb.cors.origin | `*` | - | No | Access-Control-Allow-Origin | - |
| servicecomb.cors.allowCredentials | `false` | `true`/`false` | No | Access-Control-Allow-Credentials | According to the CORS standard, when Access-Control-Allow-Credentials is set to `true`, Access- Control-Allow-Origin cannot be set to "*", otherwise an exception will be thrown |
| servicecomb.cors.allowedHeader | None | - | No | Access-Control-Allow-Headers | Multiple values ​​separated by commas |
| servicecomb.cors.allowedMethod | None | - | No | Access-Control-Allow-Methods | Multiple values ​​separated by commas |
| servicecomb.cors.exposedHeader | None | - | No | Access-Control-Expose-Headers | Multiple values ​​separated by commas |
| servicecomb.cors.maxAge | None | (0,2147483647], Integer | No | Access-Control-Max-Age | The unit is seconds. If the user does not configure this, there is no Access-Control-Max in the CORS response. Age |


## Sample Code

```yaml
servicecomb:
  cors:
    enabled: true
    origin: "*"
    allowCredentials: false
    allowedMethod: PUT,DELETE
    maxAge: 3600
```
