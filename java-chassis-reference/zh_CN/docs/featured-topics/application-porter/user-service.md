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
  <groupId>org.mybatis</groupId>
  <artifactId>mybatis</artifactId>
  <version>3.4.5</version>
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
  <groupId>org.mybatis</groupId>
  <artifactId>mybatis-spring</artifactId>
  <version>1.3.0</version>
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

数据源使用DBCP2。SqlSessionFactory里面指定了dataSource和configLocation两个属性，并新增加了mybatis-config.xml文件，用于配置mapper文件的路径。 在本微服务场景中，只需要使用简单的数据库连接和简单事务管理，如果需要使用复杂的事务管理，还需要配置XA数据源和相关的事务管理器。 有关MyBatis的Configuration更加详细的信息可以参考：[http://www.mybatis.org/mybatis-3/configuration.html](http://www.mybatis.org/mybatis-3/configuration.html) 。

```
<bean id="dataSource" class="org.apache.commons.dbcp2.BasicDataSource" destroy-method="close">
  <property name="driverClassName" value="${db.url:com.mysql.jdbc.Driver}" />
  <property name="url" value="${db.url:jdbc:mysql://localhost/porter_user_db}" />
  <property name="username" value="${db.username:root}" />
  <property name="password" value="${db.password:}" />
</bean>

<bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
  <property name="dataSource" ref="dataSource" />
  <property name="configLocation" value="classpath:/config/mybatis-config.xml"></property>
</bean>
```

* 书写Mapper文件

涉及到JAVA的Mapper定义UserMapper，XML中定义SQL与JAVA的映射关系UserMapper.xml。定义完成后，需要将内容配置到Mybatis的扫描路径和Spring的扫描路径中，涉及文件mybatis-config.xml和user.bean.xml。

```
### mybatis-config.xml
<configuration>
    <mappers>
        <mapper resource="config/UserMapper.xml"/>
    </mappers>
</configuration>

### user.bean.xml
<bean id="userMapper" class="org.mybatis.spring.mapper.MapperFactoryBean">
    <property name="mapperInterface"
        value="org.apache.servicecomb.samples.porter.user.dao.UserMapper" />
    <property name="sqlSessionFactory" ref="sqlSessionFactory" />
</bean>
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



