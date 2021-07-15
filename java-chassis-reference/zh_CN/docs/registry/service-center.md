# 使用服务中心 

服务中心(servicecomb-service-center) 提供了完备的注册发现机制， 实现了所有 `Microservice` 和 `MicroserviceInstance` 信息的注册和发现，
是 servicecomb 缺省使用的注册发现机制。 

服务中心支持使用 `PULL` 和 `PUSH` 两种模式通知实例变化， 开发者可以配置服务中心集群地址、连接参数以及心跳管理等。

* 表1-1 访问服务中心常用的配置项

| 配置项 | 默认值 | 是否必选 | 含义 | 
| :--- | :--- | :--- | :--- | 
| servicecomb.service.registry.</p>address | http://127.0.0.1:30100 | 是 | 服务中心的地址信息，可以配置多个，用逗号分隔。 |
| servicecomb.service.registry.</p>instance.watch | true | 否 | 是否采用PUSH模式监听实例变化。为false的时候表示使用PULL模式。 |
| servicecomb.service.registry.</p>autodiscovery | false | 否 | 是否自动发现服务中心的地址。当需要配置部分地址，其他地址由配置的服务中心实例发现的时候，开启这个配置。 |
| servicecomb.service.registry.</p>instance.healthCheck.interval | 30 | 否 | 心跳间隔。 |
| servicecomb.service.registry.</p>instance.healthCheck.times | 3 | 否 | 允许的心跳失败次数。当连续第times+1次心跳仍然失败时则实例被sc下线。即interval \* (times + 1)决定了实例被自动注销的时间。如果服务中心等待这么长的时间没有收取到心跳，会注销实例。 |
| servicecomb.service.registry.</p>instance.empty.protection | true | 否 | 当从服务中心查询到的地址为空的时候，是否覆盖本地缓存。这个是一种可靠性保护机制，避免实例异常批量下线导致的请求失败。 |

servicecomb 与服务中心采用 HTTP 进行交互， HTTP client 相关配置可以参
考 [Service Center Client 配置项](../config-reference/service-center-client.md)

使用服务中心需要确保下面的软件包引入：

```
  <dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>registry-service-center</artifactId>
  </dependency>
```

也可以直接依赖：

```
  <dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>solution-basic</artifactId>
  </dependency>
```

## 使用 RBAC 认证

服务中心支持[RBAC认证](https://service-center.readthedocs.io/en/latest/user-guides/rbac.html)，服务中心开启RBAC认证之
后，客户端调用服务中心接口都需要先获取token，保证服务的安全可信。 使用 RBAC 认证， 需要使用 2.1.3 及其以上的版本。 

* 服务配置

  使用 RBAC 认证，需要在配置文件中增加如下配置项， 指定连接服务中心的用户名和密码：

        ```
        servicecomb:
          credentials:
            rbac.enabled: true # 使用启用 RBAC， 默认为 false
            account:
              name: root   #服务中心支持的用户名
              password: your-password  #用户名对应的密码
            cipher: default #账号密码加解密用的算法实现类
        ```

  账号密码都是敏感信息，一般需要加密保存，使用的时候再解密，Java Chassis 提供了一个扩展机制，用户只需要实现接口
  `org.apache.servicecomb.foundation.auth.Cipher`，并注册成Spring Bean，就会自动被使用，接口里面包含两个方法：
  
        ```java
          String name();
        
          char[] decrypt(char[] encrypted);
        ```
        
  name方法返回cipher的名称，对应 `servicecomb.credentials.cipher` 的配置，decrypt是解密接口，用户名、密码使用的时候都会调用这个方法进行解密。
  下面给了一个最简单的base64编解码的实现示例，用户使用base64编码把账号密码配置到配置文件即可。
  
  ***注意***: base64 并不是安全加密算法，请勿在生产环境使用。 
  
        ```yaml
        servicecomb:
          credentials:
            account:
              name: cm9vdA==
              password: eW91ci1wYXNzd29yZCA=
            cipher: base64
        ```
        
        ```java
        import java.util.Base64;
        
        import org.apache.servicecomb.foundation.auth.Cipher;
        import org.springframework.stereotype.Component;
        
        /**
         * Base64解码实现
         */
        @Component
        public class Base64Cipher implements Cipher {
          @Override
          public String name() {
            return "base64";
          }
        
          @Override
          public char[] decrypt(char[] encrypted) {
            return new String(Base64.getDecoder().decode(new String(encrypted))).toCharArray();
          }
        }
        ```

## 使用 AK/SK 认证

华为云微服务引擎专业版的服务中心需要使用 AK/SK 认证， 使用 AK/SK 认证， 需要使用 2.1.3 及其以上的版本。
AK/SK 认证需要配置如下信息：

```yaml
servciecomb:
  credentials:
    akskEnabled: true
    accessKey: your access key
    secretKey: your secrete key
    akskCustomCipher: default # 加密算法， 和 RBAC 一样
    project: cn-south-1 # 项目名称，根据实际情况填写
```

secreteKey 支持加密存储， 扩展方式同 RBAC 。

使用AK/SK 需要下面的软件包引入：

```
  <dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>servicestage</artifactId>
  </dependency>
```

也可以直接依赖：

```
  <dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>solution-basic</artifactId>
  </dependency>
```


