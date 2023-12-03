# 使用MyBatis访问数据库

访问数据库可以使用第三方提供的组件。这里选择了MyBatis说明如何访问数据库。开发者也可以直接参考：

[http://www.mybatis.org/spring/zh/index.html](http://www.mybatis.org/spring/zh/index.html)

这里给出一个快速集成参考。在本章中涉及到建表等数据库操作的时候，数据库选用MySQL。

# 设计表

本应用提供了非常简单的用户管理和基于角色的鉴权机制。因此我们设计了非常简单的用户表，表格包含了用户名称及用户所属的角色。为了测试的目的，还插入了两个用户数据，其中密码采用SHA256进行单向加密保存。

    CREATE DATABASE IF NOT EXISTS porter_user_db;

    USE porter_user_db;

    DROP TABLE IF EXISTS T_USER;

    CREATE TABLE `T_USER` (
      `ID`  INTEGER(20) NOT NULL COMMENT '用户ID',
      `USER_NAME`  VARCHAR(64) NOT NULL COMMENT '用户名称',
      `PASSWORD`  VARCHAR(64) NOT NULL COMMENT '用户密码',
      `ROLE_NAME`  VARCHAR(64) NOT NULL COMMENT '角色名称',
      PRIMARY KEY (`ID`)
    );

    insert into T_USER(ID, USER_NAME, PASSWORD, ROLE_NAME) values(1, "admin", "n4bQgYhMfWWaL+qgxVrQFaO/TxsrC4Is0V1sFbDwCgg=", "admin");
    insert into T_USER(ID, USER_NAME, PASSWORD, ROLE_NAME) values(2, "guest", "n4bQgYhMfWWaL+qgxVrQFaO/TxsrC4Is0V1sFbDwCgg=", "guest");

# 使用MyBatis

* 引用MyBatis的相关依赖

依赖包含了MyBatis和Spring、DBCP2数据库连接池管理相关组件。这些组件都是使用Spring和MyBatis必须的。

```
<dependency>
  <groupId>org.mybatis.spring.boot</groupId>
  <artifactId>mybatis-spring-boot-starter</artifactId>
  <exclusions>
    <exclusion>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-logging</artifactId>
    </exclusion>
  </exclusions>
</dependency>
<dependency>
  <groupId>mysql</groupId>
  <artifactId>mysql-connector-java</artifactId>
</dependency>
<dependency>
  <groupId>org.apache.commons</groupId>
  <artifactId>commons-dbcp2</artifactId>
</dependency>
<dependency>
  <groupId>org.springframework</groupId>
  <artifactId>spring-jdbc</artifactId>
  <scope>compile</scope>
</dependency>
<dependency>
  <groupId>org.springframework</groupId>
  <artifactId>spring-aop</artifactId>
</dependency>
<dependency>
  <groupId>org.springframework</groupId>
  <artifactId>spring-context-support</artifactId>
</dependency>
<dependency>
  <groupId>org.springframework</groupId>
  <artifactId>spring-tx</artifactId>
</dependency>
```

* 配置数据源和SqlSessionFactory

本例子使用Spring Data Source， 只需要在配置文件中加上配置信息：

```
spring:
  datasource:
    url: jdbc:mysql://localhost/porter_user_db
    username: root
    password: root
    driver-class-name: com.mysql.jdbc.Driver
```

* 书写Mapper文件

涉及到JAVA的Mapper定义UserMapper。

```
@Mapper
public interface UserMapper {
  @Insert("""
      insert into T_USER (ID, USER_NAME, PASSWORD, ROLE_NAME)
        values(#{id,jdbcType=INTEGER}, #{userName,jdbcType=VARCHAR},
               #{password,jdbcType=VARCHAR}, #{roleName,jdbcType=VARCHAR})""")
  void createUser(UserInfo userInfo);

  @Select("""
      select ID, USER_NAME, PASSWORD, ROLE_NAME
        from T_USER where USER_NAME = #{userName,jdbcType=VARCHAR}""")
  @Results({
      @Result(property = "id", column = "ID"),
      @Result(property = "userName", column = "USER_NAME"),
      @Result(property = "password", column = "PASSWORD"),
      @Result(property = "roleName", column = "ROLE_NAME")
  })
  UserInfo getUserInfo(String userName);
}

```

## 设计用户服务

经过上面的配置，数据库访问相关开发已经完成了。 结合User Story，可以先设计一个login的服务接口。 这个服务在UserServiceEndpoint里面进行定义。

```
@PostMapping(path = "/login", produces = MediaType.APPLICATION_JSON_VALUE)
public SessionInfo login(@RequestParam(name = "userName") String userName, 
    @RequestParam(name = "password") String password)
```

接口会返回SessionInfo，这些必要的信息，会在后续的鉴权、认证操作中起到很大的方便。

经过以上的开发，就可以启动用户服务，配置数据库和插入相关数据，从界面访问这个接口。

```
#### 访问login接口的HTTP请求和响应

#Request
POST http://localhost:9090/api/user-service/v1/user/login

Content-Type: application/x-www-form-urlencoded

userName=admin&password=test

#Response
{
    "id": 0,
    "sessiondId": "1be646c0-50cb-4c0a-968d-2a512775f5e8",
    "userName": "guest",
    "roleName": "guest",
    "creationTime": null,
    "activeTime": null
}
```



