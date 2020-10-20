## 场景描述

服务注册发现，服务中心需要确保服务是信任的，服务中心支持[RBAC认证](https://service-center.readthedocs.io/en/latest/user-guides/rbac.html)，服务中心开启RBAC认证之后，客户端调用服务中心接口都需要先获取token，保证服务的安全可信（需要2.1.2+版本才支持）

## 服务配置

* 在pom.xml中增加依赖：

```
  <dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>solution-basic</artifactId>
  </dependency>
  <dependency>
    <groupId>org.apache.servicecomb</groupId>
    <artifactId>registry-service-center</artifactId>
  </dependency>
```

* 在microservice.yaml中添加账号配置

```
servicecomb:
  credentials:
    account:
      name: root   #服务中心支持的用户名
      password: your-password  #用户名对应的密码
    cipher: default #账号密码加解密用的算法实现类
```

## 账号密码加解密配置
账号密码都是敏感信息，一般需要加密保存，使用的时候再解密，ServiceComb JavaChassis提供了一个扩展机制，用户只需要实现接口org.apache.servicecomb.foundation.auth.Cipher，并注册成Spring Bean，就会自动被使用，接口里面包含两个方法：
```java
  String name();

  char[] decrypt(char[] encrypted);
```
name方法返回cipher的名称，对应servicecomb.credentials.cipher的配置，decrypt是解密接口，用户名、密码使用的时候都会调用这个方法进行解密。下面给了一个最简单的base64编解码的实现示例，用户使用base64编码把账号密码配置到配置文件即可
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



