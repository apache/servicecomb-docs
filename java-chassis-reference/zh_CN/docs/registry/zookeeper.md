# 使用 ZooKeeper

可以通过 [ZooKeeper官网](https://zookeeper.apache.org/index.html) 下载和安装 ZooKeeper。

使用ZooKeeper需要确保下面的软件包引入：

```
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>registry-zookeeper</artifactId>
</dependency>
```

* 表1-1 访问ZooKeeper常用的配置项

| 配置项                                               | 默认值            | 是否必选 | 含义                                            |
|:--------------------------------------------------|:---------------|:-----|:----------------------------------------------|
| servicecomb.registry.zk.enabled                   | true           | 是    | 是否启用。                                         |
| servicecomb.registry.zk.connectString             | 127.0.0.1:2181 | 是    | ZooKeeper的地址信息，可以配置多个，用逗号分隔。                  |
| servicecomb.registry.zk.authenticationSchema      | 空              | 否    | 认证方式，目前只能配置为 digest。                          |
| servicecomb.registry.zk.authenticationInfo        | 空              | 否    | 当认证方式为 digest 的时候，配置用户名密码信息，比如: user:password |
| servicecomb.registry.zk.connectionTimeoutMillis   | 1000           | 否    | 连接超时时间                                        |
| servicecomb.registry.zk.sessionTimeoutMillis      | 60000          | 否    | 会话超时时间                                        |
| servicecomb.registry.zk.enableSwaggerRegistration | false          | 否    | 是否注册契约                                        |

## ZooKeeper使用认证

ZooKeeper使用认证详细情况可以参考官网。这里给出核心重要的步骤，本步骤基于Zookeeper 3.8.3版本进行验证。 

1. 修改 zoo.cfg

    在配置文件增加。其中 `sessionRequireClientSASLAuth` 指定了必须登录才能够访问 Zookeeper。 

    ```text
    authProvider.1=org.apache.zookeeper.server.auth.SASLAuthenticationProvider
    sessionRequireClientSASLAuth=true
    ```
   
2. 修改 java.env

   在配置文件增加。 其中 `file.conf` 是第3步增加的文件路径

    ```text
    SERVER_JVMFLAGS="-Djava.security.auth.login.config=/opt/file.conf"
    ```

3. 增加 file.conf

    配置文件指定合法的登录用户。 

    ```text
    Server {
       org.apache.zookeeper.server.auth.DigestLoginModule required
       user_super="adminsecret"
       user_bob="bobsecret";
    };
    ```
