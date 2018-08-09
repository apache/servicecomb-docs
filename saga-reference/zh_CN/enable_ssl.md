#  TLS 对 omega-alpha 开启TLS通信

Saga 现在支持在omega和alpha服务之间采用 TLS 通信.同样客户端方面的认证（双向认证）。

## 准备证书 （Certificates）

你可以用下面的命令去生成一个用于测试的自签名的证书。
如果你想采用双向认证的方式，只需要客户端证书。

```
# Changes these CN's to match your hosts in your environment if needed.
SERVER_CN=localhost
CLIENT_CN=localhost # Used when doing mutual TLS

echo Generate CA key:
openssl genrsa -passout pass:1111 -des3 -out ca.key 4096
echo Generate CA certificate:
# Generates ca.crt which is the trustCertCollectionFile
openssl req -passin pass:1111 -new -x509 -days 365 -key ca.key -out ca.crt -subj "/CN=${SERVER_CN}"
echo Generate server key:
openssl genrsa -passout pass:1111 -des3 -out server.key 4096
echo Generate server signing request:
openssl req -passin pass:1111 -new -key server.key -out server.csr -subj "/CN=${SERVER_CN}"
echo Self-signed server certificate:
# Generates server.crt which is the certChainFile for the server
openssl x509 -req -passin pass:1111 -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt 
echo Remove passphrase from server key:
openssl rsa -passin pass:1111 -in server.key -out server.key
echo Generate client key
openssl genrsa -passout pass:1111 -des3 -out client.key 4096
echo Generate client signing request:
openssl req -passin pass:1111 -new -key client.key -out client.csr -subj "/CN=${CLIENT_CN}"
echo Self-signed client certificate:
# Generates client.crt which is the clientCertChainFile for the client (need for mutual TLS only)
openssl x509 -passin pass:1111 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt
echo Remove passphrase from client key:
openssl rsa -passin pass:1111 -in client.key -out client.key
echo Converting the private keys to X.509:
# Generates client.pem which is the clientPrivateKeyFile for the Client (needed for mutual TLS only)
openssl pkcs8 -topk8 -nocrypt -in client.key -out client.pem
# Generates server.pem which is the privateKeyFile for the Server
openssl pkcs8 -topk8 -nocrypt -in server.key -out server.pem
```

## TLS为Alpha服务开启TLS

1.为alpha-server修改application.yaml文件，在`alpha.server`部门增加ssl配置。
```
alpha:
  server:
    ssl:
      enable: true
      cert: server.crt
      key: server.pem
      mutualAuth: true
      clientCert: client.crt
```

2. 将server.crt 和 server.pem 文件放到alpha-server的root 目录。如果你想双向认证，合并所有client证书到一个client.crt文件,并把client.crt文件放到root目录.

3. 重新启动alpha服务器.


## 为Omega启用TLS

1. 获取CA证书串(chain), 如果你是将alpha服务运行在集群中，你可能需要去合并多个CA证书到一个文件中.

2. 为客户端应用修改application.yaml文件, 在`alpha.cluster` 部分增加ssl配置.

```
alpha:
  cluster:
    address: alpha-server.servicecomb.io:8080
    ssl:
      enable: false
      certChain: ca.crt
      mutualAuth: false
      cert: client.crt
      key: client.pem
```
3. 把ca.crt文件放到客户端应用程序的root目录 file under the client application root directory.如果你想用双向认证，仍需要把client.crt和client.pem放到root目录下.

4. 重新启动客户端应用程序.

