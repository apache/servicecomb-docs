传统的WEB容器都提供了会话管理，在微服务架构下，这些会话管理存在很多的限制，如果需要做到弹性扩缩容，则需要做大量的定制。 在porter中，我们使用user-service做会话管理，可以通过login和session两个接口创建和获取会话信息。会话信息持久化到数据库中，从而实现微服务本身的无状态，微服务可以弹性扩缩容。在更大规模并发或者高性能要求的情况下，可以考虑将会话信息存储到高速缓存。

```
@PostMapping(path = "/login", produces = MediaType.APPLICATION_JSON_VALUE)

public SessionInfo login(@RequestParam(name = "userName") String userName,

@RequestParam(name = "password") String password)



@GetMapping(path = "/session", produces = MediaType.APPLICATION_JSON_VALUE)

public SessionInfo getSession(@RequestParam(name = "sessionId") String sessionId)
```

同时新增了会话管理的数据表设计：

    CREATE TABLE `T_SESSION` (
      `ID`  INTEGER(8) NOT NULL AUTO_INCREMENT COMMENT '唯一标识',
      `SESSION_ID`  VARCHAR(64) NOT NULL COMMENT '临时会话ID',
      `USER_NAME`  VARCHAR(64) NOT NULL COMMENT '用户名称',
      `ROLE_NAME`  VARCHAR(64) NOT NULL COMMENT '角色名称',
      `CREATION_TIME`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
      `ACTIVE_TIME`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最近活跃时间',
      PRIMARY KEY (`ID`)
    );

会话管理和认证都在gateway-service进行，鉴权则需要使用到用户信息。为了让微服务获取用户信息的时候，不至于再查询user-service，我们利用了Context机制，在Context里面存储了session信息，所有的微服务都可以直接从Context里面取到session信息，非常方便和灵活。完成这个功能有如下几个关键步骤：

* gateway-service进行HTTP协议到Invocation的转换

这个通过重载EdgeInvocation的createInvocation实现。将会话ID通过Context传递给handler。如果开发者需要实现诸如增加响应头，设计Cookie等操作，则可以通过重载sendResponse来实现。

```
EdgeInvocation invoker = new EdgeInvocation() {
  // 认证鉴权：构造Invocation的时候，设置会话信息。如果是认证请求，则添加Cookie。
  protected void createInvocation(Object[] args) {
    super.createInvocation(args);
    // 既从cookie里面读取会话ID，也从header里面读取，方便各种独立的测试工具联调
    String sessionId = context.request().getHeader("session-id");
    if (sessionId != null) {
      this.invocation.addContext("session-id", sessionId);
    } else {
      Cookie sessionCookie = context.getCookie("session-id");
      if (sessionCookie != null) {
        this.invocation.addContext("session-id", sessionCookie.getValue());
      }
    }
  }
};
```

* 通过handler来进行认证和会话管理

对于ui界面，不提供认证，用户可以直接访问。对于REST接口需要进行认证，因此我们将认证和会话管理的功能在Hanlder中实现。下面的代码对user-service的login接口直接转发请求，其他请求先经过会话校验，再进行转发。

***注意***: 在网关执行的Hanlder逻辑，是reactive模式的，不能使用阻塞调用，否则会导致线程阻塞。

```
public class AuthHandler implements Handler {
  private UserServiceClient userServiceClient = BeanUtils.getBean("UserServiceClient");

  // session expires in 10 minutes, cache for 1 seconds to get rid of concurrent scenarios.
  private Cache<String, String> sessionCache = CacheBuilder.newBuilder()
      .expireAfterAccess(30, TimeUnit.SECONDS)
      .build();

  @Override
  public void handle(Invocation invocation, AsyncResponse asyncResponse) throws Exception {
    if (invocation.getMicroserviceName().equals("user-service")
        && (invocation.getOperationName().equals("login")
            || (invocation.getOperationName().equals("getSession")))) {
      // login：return session id, set cookie by javascript
      invocation.next(asyncResponse);
    } else {
      // check session
      String sessionId = invocation.getContext("session-id");
      if (sessionId == null) {
        throw new InvocationException(403, "", "session is not valid.");
      }

      String sessionInfo = sessionCache.getIfPresent(sessionId);
      if (sessionInfo != null) {
        try {
          // session info stored in InvocationContext. Microservices can get it. 
          invocation.addContext("session-id", sessionId);
          invocation.addContext("session-info", sessionInfo);
          invocation.next(asyncResponse);
        } catch (Exception e) {
          asyncResponse.complete(Response.failResp(new InvocationException(500, "", e.getMessage())));
        }
        return;
      }

      // In edge, handler is executed in reactively. Must have no blocking logic.
      CompletableFuture<SessionInfo> result = userServiceClient.getGetSessionOperation().getSession(sessionId);
      result.whenComplete((info, e) -> {
        if (result.isCompletedExceptionally()) {
          asyncResponse.complete(Response.failResp(new InvocationException(403, "", "session is not valid.")));
        } else {
          if (info == null) {
            asyncResponse.complete(Response.failResp(new InvocationException(403, "", "session is not valid.")));
            return;
          }
          try {
            // session info stored in InvocationContext. Microservices can get it. 
            invocation.addContext("session-id", sessionId);
            String sessionInfoStr = JsonUtils.writeValueAsString(info);
            invocation.addContext("session-info", sessionInfoStr);
            invocation.next(asyncResponse);
            sessionCache.put(sessionId, sessionInfoStr);
          } catch (Exception ee) {
            asyncResponse.complete(Response.failResp(new InvocationException(500, "", ee.getMessage())));
          }
        }
      });
    }
  }
}
```

启用该Hanlder，需要增加cse.handler.xml文件

```
<config>
  <handler id="auth"
    class="org.apache.servicecomb.samples.porter.gateway.AuthHandler" />
</config>
```

并且在microservice.yaml中启用auth，将新增加的auth处理链放到流控之后。

```
servicecomb:
  handler:
    chain:
      Consumer:
        default: internalAccess,auth,qps-flowcontrol-consumer,loadbalance
```

* 给删除文件增加鉴权

在上面的步骤中，已经将会话信息设置到Context里面，file-service可以方便的使用这些信息进行鉴权操作。

```
@DeleteMapping(path = "/delete", produces = MediaType.APPLICATION_JSON_VALUE)
public boolean deleteFile(@RequestParam(name = "id") String id) {
    String session = ContextUtils.getInvocationContext().getContext("session-info");
    if (session == null) {
        throw new InvocationException(403, "", "not allowed");
    } else {
        SessionInfo sessionInfo = null;
        try {
            sessionInfo = JsonUtils.readValue(session.getBytes("UTF-8"), SessionInfo.class);
        } catch (Exception e) {
            throw new InvocationException(403, "", "session not allowed");
        }
        if (sessionInfo == null || !sessionInfo.getRoleName().equals("admin")) {
            throw new InvocationException(403, "", "not allowed");
        }
    }
    return fileService.deleteFile(id);
}
```

到这里为止，认证、会话管理和鉴权的逻辑基本已经完成了。可以通过Postman等工具进行流程相关的测试。

```
#### 会话管理接口调用示例，调用删除文件接口。使用guest用户的会话的情况。

#Request
DELETE http://localhost:9090/api/file-service/delete?id=ba6bd8a2-d31a-42cd-a1be-9fb3d6ab4c82

session-id: 1be646c0-50cb-4c0a-968d-2a512775f5e8

#Response
{
    "message": "not allowed"
}
```



# 开发JS脚本管理会话

首先需要提供登陆框，让用户输入用户名密码：

```
<div class="form">
    <h2>登录</h2>
    <input id="username" type="text" name="Username" placeholder="Username">
    <input id="paasword" type="password" name="Password" placeholder="Password" >
    <input type="button" value="Login" onclick="loginAction()">
</div>
```

实现登陆逻辑。登陆首先调用后台登陆接口，登陆成功后设置会话cookie:

```
function loginAction() {
     var username = document.getElementById("username").value;
     var password = document.getElementById("paasword").value;
     var formData = {};
     formData.userName = username;
     formData.password = password;

     $.ajax({
        type: 'POST',
        url: "/api/user-service/login",
        data: formData,
        success: function (data) {
            setCookie("session-id", data.sessiondId, false);
            window.alert('登陆成功！');
        },
        error: function(data) {
            console.log(data);
            window.alert('登陆失败！' + data);
        },
        async: true
    });
}
```



