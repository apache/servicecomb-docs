# 安全认证设计

ServiceComb Fence 鉴权实现的主要框架参考了 [The OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749) 和 [OpenID Connect](https://openid.net/connect/) 。 项目参考 [Spring Security](https://spring.io/projects/spring-security) 给开发者提供了接口。

## 认证流程图

![](authentication.png)


## 鉴权流程图

![](authorization.png)

## 认证鉴权流程介绍

### 密码模式

* Client 输入用户名密码向 Authentication Server 请求 Token。

```
** HTTP Request **

POST http://localhost:9090/v1/token HTTP/1.1
Content-Type: application/x-www-form-urlencoded

grant_type=password&username=admin&password=changeMyPassword

** HTTP Response **

{
    "token_type": "bearer",
    "access_token": "SlAV32hkKG",
    "refresh_token": "8xLOxBtZp8",
    "id_token": "eyJ...hbGciOiJSU...zI1NiIsImtpZCI6Ij",
    "expires_in": 600,
    "scope": null,
    "additionalInformation": null
}
```

* Authentication Server 发送 Token 给 Client 。

* Client 携带  ID Token 请求 Edge Service 。

```
** HTTP Request **

POST http://localhost:9090/api/resource-server/v1/auth/handler/adminSayHello?name=Hi HTTP/1.1
Content-Type: application/x-www-form-urlencoded
Authorization: Bearer eyJ...hbGciOiJSU...zI1NiIsImtpZCI6Ij
```

* Edge Service 将 ID Token 转发给Resource Server。
* Resource Server 返回对应的资源给 Client 。

## 配置 Authentication Server

Authentication Server 主要提供认证和授权等接口。

```java
@Configuration
public class AuthenticationConfiguration {
  @Bean(name = CommonConstants.BEAN_AUTH_PASSWORD_ENCODER)
  public PasswordEncoder authPasswordEncoder() {
    return Pbkdf2PasswordEncoder.defaultsForSpringSecurity_v5_8();
  }

  @Bean(name = {CommonConstants.BEAN_AUTH_SIGNER, CommonConstants.BEAN_AUTH_SIGNATURE_VERIFIER})
  public SignerVerifier authSignerVerifier() {
    // If using RSA, need to configure authSigner and authSignatureVerifier separately. 
    // If using MacSigner, need to protect the shared key by properly encryption.
    return new MacSigner("Please change this key.");
  }

  @Bean(name = {CommonConstants.BEAN_AUTH_ID_TOKEN_STORE})
  public JWTTokenStore jwtTokenStore(@Autowired @Qualifier(CommonConstants.BEAN_AUTH_SIGNER) Signer signer,
      @Autowired @Qualifier(CommonConstants.BEAN_AUTH_SIGNATURE_VERIFIER) SignerVerifier signerVerifier) {
    return new JWTTokenStoreImpl(signer, signerVerifier);
  }

  @Bean(name = {CommonConstants.BEAN_AUTH_ACCESS_TOKEN_STORE,
      CommonConstants.BEAN_AUTH_REFRESH_TOKEN_STORE})
  public SessionTokenStore sessionTokenStore() {
    return new SessionTokenStore();
  }
}
```

* UserDetailsManager

获取用户详情，包括用户名称、角色等信息。包括 InMemoryUserDetailsManager 、 JDBCUserDetailsManager 等实现。JDBCUserDetailsManager。

* Signer 和  SignatureVerifier

生成 Token 和对 Token 进行校验。Singer 和  SignatureVerifier 是配套使用的， 在 Authentication Server ， 生成 Token 的时候，需要使用 Singer 。 验证 Token 的有效性 （比如查询 userDetails 等场景）， 需要使用  SignatureVerifier 。 通常有两种方式进行签名和校验， 一种是基于对称秘钥的机制，比如MacSigner，即是 Singer， 也是 SignatureVerifier （SignerVerifier）; 一种是基于非对称秘钥的机制， 比如 RsaSigner 和  RsaVerifier , 生成 Token 和校验 Token 的秘钥是不同的。

* AbstractOpenIDTokenStore
  在Authentication Server，TokenStore主要用来生成Access Token, Refresh Token和ID Token， 默认情况下， Access Token和Refresh Token都使用AbstractSessionIDTokenStore（本例子使用了InMemoryOpenIDTokenStore，业务代码通常需要换为JDBC、Redis等实现）， ID Token使用JWTTokenStore。 JWTTokenStore是一个无状态的会话机制，Authentication Server的任何一个实例都可以独立生成。支持Refresh Token认证的场景下，还需要实现通过Refresh Token读取其他信息的方法。

* PasswordEncoder

从 UserDetailsService 校验用户密码的时候需要使用。 开发者需要在加密性能和保密程度方面选择合适的算法。 常用的有 Pbkdf2PasswordEncoder , 它可以设置迭代次数，能够更好的保护密码不被暴力破解。

## 配置 Resource Server

Resource Server 对 Client 的访问进行认证， 并进行权限控制。

Resource Server 需要配置 Signer、SignerVerifier、TokenStore 等， 对用户会话进行认证。

```java
@Configuration
@EnableMethodSecurity
public class AuthenticationConfiguration {
  @Bean(name = {CommonConstants.BEAN_AUTH_SIGNER, CommonConstants.BEAN_AUTH_SIGNATURE_VERIFIER})
  public SignerVerifier authSignerVerifier() {
    // If using RSA, need to configure authSigner and authSignatureVerifier separately. 
    // If using MacSigner, need to protect the shared key by properly encryption.
    return new MacSigner("Please change this key.");
  }

  @Bean(name = CommonConstants.BEAN_AUTH_ID_TOKEN_STORE)
  public JWTTokenStore authIDTokenStore(@Autowired @Qualifier(CommonConstants.BEAN_AUTH_SIGNER) Signer signer,
      @Autowired @Qualifier(CommonConstants.BEAN_AUTH_SIGNATURE_VERIFIER) SignerVerifier signerVerifier) {
    return new JWTTokenStoreImpl(signer, signerVerifier);
  }

  @Bean
  public AuthenticationProviderFilter authenticationProviderFilter() {
    return new AuthenticationProviderFilter();
  }

  @Bean
  public GrantedAuthorityDefaults grantedAuthorityDefaults() {
    return new GrantedAuthorityDefaults("");
  }

  @Bean
  @Order(0)
  public AuthenticationAuthFilter authenticationAuthFilter() {
    return new AuthenticationAuthFilter();
  }

  @Bean
  @Order(100)
  public ConfigBasedAuthorizationAuthFilter configBasedAuthorizationAuthFilter() {
    return new ConfigBasedAuthorizationAuthFilter();
  }
}

```

* Signer、SignatureVerifier
  对Token进行校验需要，实际上Resource Server只需要使用SignatureVerifier。

* JWTTokenStore
  Edge Service将ID Token传递给Resource Server，所以只需要配置JWTTokenStore。基于会话认证的场景，需要提供AbstractOpenIDTokenStore。


* 权限配置

fence 提供了两种方式进行权限配置。 一种是基于配置文件的，一种是基于 Annotation 。

基于文件的配置, 在 microservice.yaml 中可以配置每个方法的访问权限。

```
servicecomb:
  authencation:
    access:
      needAuth: true
      HandlerAuthEndpoint:
        adminSayHello: 
          roles: ADMIN
        guestSayHello: 
          roles: GUEST
        guestOrAdminSayHello: 
          roles: ADMIN,GUEST
        # everyoneSayHello: all can
```

还可以统一配置Schema

```
servicecomb:
  authencation:
    access:
      needAuth: true
      roles:
        HandlerAuthEndpoint: ADMIN
```

或者所有

```
servicecomb:
  authencation:
    access:
      needAuth: true
      roles: ADMIN
```

基于 Annotation ， 可以使用 PreAuthorize 标签

```
@PreAuthorize("hasRole('ADMIN')")
```

Annotation 支持默认没有启用， 可以通过 EnableGlobalMethodSecurity 标签启用。

```
@Configuration
@EnableGlobalMethodSecurity(
    prePostEnabled = true)
public class MethodSecurityConfiguration extends GlobalMethodSecurityConfiguration {
  @Override
  protected MethodSecurityExpressionHandler createExpressionHandler() {
    DefaultMethodSecurityExpressionHandler h = (DefaultMethodSecurityExpressionHandler) super.createExpressionHandler();
    h.setDefaultRolePrefix("");
    return h;
  }
}
```


## 配置 Edge Service

Edge Service 是微服务接入层。 接入层在认证鉴权的功能包括透传 Authentication Server的请求， 对Token进行认证，控制内部接口和外部接口的隔离等功能。

Edge Service 需要配置 JWTTokenStore 等， 对用户会话进行认证。Edge Service 从HTTP头里面读取Id Token， 然后通过 JWTTokenStore检查ID Token是否有效，如果有效，将对应的 ID Token传递到 Resource Server。 在基于会话认证的场景下，需要使用 SessionTokenStore。

```
@Configuration
public class AuthenticationConfiguration {
  @Bean(name = {CommonConstants.BEAN_AUTH_SIGNER, CommonConstants.BEAN_AUTH_SIGNATURE_VERIFIER})
  public SignerVerifier authSignerVerifier() {
    // If using RSA, need to configure authSigner and authSignatureVerifier separately. 
    // If using MacSigner, need to protect the shared key by properly encryption.
    return new MacSigner("Please change this key.");
  }

  @Bean(name = CommonConstants.BEAN_AUTH_ID_TOKEN_STORE)
  public JWTTokenStore authIDTokenStore(@Autowired @Qualifier(CommonConstants.BEAN_AUTH_SIGNER) Signer signer,
      @Autowired @Qualifier(CommonConstants.BEAN_AUTH_SIGNATURE_VERIFIER) SignerVerifier signerVerifier) {
    return new JWTTokenStoreImpl(signer, signerVerifier);
  }

  @Bean(name = CommonConstants.BEAN_AUTH_OPEN_ID_TOKEN_STORE)
  public EdgeOpenIDTokenStore edgeOpenIDTokenStore() {
    return new EdgeOpenIDTokenStore();
  }

  @Bean(name = {CommonConstants.BEAN_AUTH_ACCESS_TOKEN_STORE,
      CommonConstants.BEAN_AUTH_REFRESH_TOKEN_STORE})
  public SessionTokenStore sessionTokenStore() {
    return new SessionTokenStore();
  }

  @Bean
  public AuthenticationEdgeFilter authenticationEdgeFilter() {
    return new AuthenticationEdgeFilter();
  }

  @Bean
  public InternalAccessEdgeFilter internalAccessEdgeFilter() {
    return new InternalAccessEdgeFilter();
  }
}
```

