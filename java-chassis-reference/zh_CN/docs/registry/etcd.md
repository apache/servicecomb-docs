# 使用 etcd

可以通过 [Etcd官网](https://etcd.io/docs/v3.5/install/) 下载和安装 Etcd。

使用Etcd需要确保下面的软件包引入：

```
<dependency>
  <groupId>org.apache.servicecomb</groupId>
  <artifactId>registry-etcd</artifactId>
  <version>x.x.x</version>
</dependency>
```

* 表1-1 访问Etcd常用的配置项

| 配置项                                               | 默认值            | 是否必选 | 含义                                 |
|:--------------------------------------------------|:---------------|:-----|:-----------------------------------|
| servicecomb.registry.etcd.enabled                   | true           | 是    | 是否启用。                              |
| servicecomb.registry.etcd.connectString             | http://127.0.0.1:2379 | 是    | etcd的地址信息，可以配置多个，用逗号分隔。            |
| servicecomb.registry.etcd.authenticationInfo        | 空              | 否    | etcd认证，配置用户名密码信息，比如: user:password |
| servicecomb.registry.etcd.enableSwaggerRegistration | false          | 否    | 是否注册契约                             |

## etcd使用认证

在 etcd 中启用和配置认证需要进行以下步骤：

#### 1. 启用 etcd 认证

首先需要确保 etcd 已经正常运行，然后按以下步骤启用认证功能：

#####  1.1 启动 etcd 服务

确保 etcd 服务已启动，监听所需的端口（如 2379 和 2380）。可以使用 etcdctl 进行操作。

---

#### 2. 添加用户

使用 etcdctl 添加一个用户并设置密码。例如，添加一个用户 root：

etcdctl user add root

执行上述命令后，会提示输入并确认密码。

---

#### 3. 为用户分配角色

为用户分配一个角色，可以是已有角色，也可以新建一个。以下是新建角色并分配权限的示例：

##### 3.1 创建角色

etcdctl role add rootrole

##### 3.2 分配权限

为 rootrole 分配对所有键的读写权限：

etcdctl role grant-permission rootrole readwrite /

##### 3.3 关联用户和角色

将用户 root 与角色 rootrole 关联：

etcdctl user grant-role root rootrole

---

#### 4. 启用认证

完成用户和角色的配置后，启用 etcd 认证：

etcdctl auth enable

注意：启用认证后，所有的 etcd 操作都需要进行认证，包括通过 API 或客户端命令。

---

#### 5. 使用认证进行操作

认证启用后，所有 etcdctl 命令都需要指定用户名和密码。例如：

etcdctl --user=root:yourpassword put foo bar
etcdctl --user=root:yourpassword get foo

---

#### 6. 其他用户与角色管理

添加新用户

etcdctl user add newuser

创建新角色

etcdctl role add newrole

分配权限给新角色

etcdctl role grant-permission newrole readwrite /example-prefix

将用户与角色关联

etcdctl user grant-role newuser newrole

7. 注意事项

   1.	安全性：为保证安全，避免在生产中使用默认用户 root，可以创建其他用户并分配特定权限。
   2.	TLS 加密：推荐在启用认证的同时启用 TLS，以加密数据传输。
   3.	高可用场景：如果使用 etcd 集群，确保所有节点的认证配置保持一致。

示例配置 (全流程)

以下是完整操作流程的一个示例：

###### 添加用户 root
etcdctl user add root

###### 创建角色 rootrole
etcdctl role add rootrole

###### 分配读写权限给 rootrole
etcdctl role grant-permission rootrole readwrite /

###### 将 root 用户关联到 rootrole
etcdctl user grant-role root rootrole

###### 启用认证
etcdctl auth enable

###### 使用认证操作
etcdctl --user=root:yourpassword put foo bar
etcdctl --user=root:yourpassword get foo
