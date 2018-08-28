＃设置SSL / TLS

##要求
服务中心（SC）需要多个SSL / TLS相关文件。

1.环境变量'SSL_ROOT'：该目录包含证书。如果未设置，则使用SC工作目录下的“etc / ssl”。
1. $ SSL_ROOT / trust.cer：可信证书颁发机构。
1. $ SSL_ROOT / server.cer：用于与SC的SSL / TLS连接的证书。
1. $ SSL_ROOT / server_key.pem：证书的密钥。如果密钥已加密，则必须设置'cert_pwd'。
1. $ SSL_ROOT / cert_pwd（可选）：用于解密私钥的密码。

##配置
请在启动SC之前修改conf / app.conf

1. ssl_mode：启用SSL / TLS模式。 [0,1]
1. ssl_verify_client：是否验证SC客户端（包括etcd服务器）。 [0,1]
1. ssl_protocols：最小SSL / TLS协议版本。 [“TLSv1.0”，“TLSv1.1”，“TLSv1.2”]
1. ssl_ciphers：密码组列表。默认情况下，使用TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256，TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384，TLS_RSA_WITH_AES_256_GCM_SHA384，TLS_RSA_WITH_AES_128_GCM_SHA256