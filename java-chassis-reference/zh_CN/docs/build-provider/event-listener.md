# 服务启动事件

java chassis 启动过程中，会广播事件。 业务可以在服务启动的不同阶段执行一些初始化逻辑。 事件类型在 `BootListener` 
里面定义：

```java
public interface BootListener {
  enum EventType {
    BEFORE_HANDLER,
    AFTER_HANDLER,
    BEFORE_PRODUCER_PROVIDER,
    AFTER_PRODUCER_PROVIDER,
    BEFORE_CONSUMER_PROVIDER,
    AFTER_CONSUMER_PROVIDER,
    BEFORE_TRANSPORT,
    AFTER_TRANSPORT,
    BEFORE_REGISTRY,
    AFTER_REGISTRY,
    BEFORE_CLOSE,
    AFTER_CLOSE
  }
}
```

自定义事件处理器只需要实现 `BootListener` 的接口，并且声明为 `Component` 即可。

```java
@Component
public class AuthHandlerBoot implements BootListener {
  @Override
  public void onBootEvent(BootEvent event) {
    if (EventType.BEFORE_REGISTRY.equals(event.getEventType())) {
      RSAKeyPairEntry rsaKeyPairEntry = RSAUtils.generateRSAKeyPair();
      RSAKeypair4Auth.INSTANCE.setPrivateKey(rsaKeyPairEntry.getPrivateKey());
      RSAKeypair4Auth.INSTANCE.setPublicKey(rsaKeyPairEntry.getPublicKey());
      RSAKeypair4Auth.INSTANCE.setPublicKeyEncoded(rsaKeyPairEntry.getPublicKeyEncoded());
      RegistryUtils.getMicroserviceInstance().getProperties().put(Const.INSTANCE_PUBKEY_PRO,
          rsaKeyPairEntry.getPublicKeyEncoded());
    }
  }
}
```

比如，通过事件处理器，可以在服务注册完成或者服务注册之前进行一些初始化操作。
