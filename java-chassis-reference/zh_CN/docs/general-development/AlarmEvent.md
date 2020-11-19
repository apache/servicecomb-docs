# 监听告警事件

## 场景描述

Java-Chassis 会在运行期间抛出一些与微服务治理相关的告警事件，当前涉及的场景包括：

- 服务熔断
- 实例隔离

用户可以自行扩展告警事件监听器，获取相关事件。

## 告警事件列表

<table class="metrics-table">
  <tr>
    <th>事件</th>
    <th>事件属性</th>
    <th>属性说明</th>
  </tr>
  <!-- circuit breaker -->
  <tr>
    <td rowspan="11">CircutBreakerEvent<br/>服务熔断事件</td>
    <td>type</td>
    <td>事件类型，包含`OPEN`/`CLOSE`两个枚举值，分别表示事件发生和事件恢复</td>
  </tr>
  <tr>
    <td>role</td>
    <td>熔断事件发生时本服务实例的角色，有`CONSUMER`/`PRODUCER`两种取值</td>
  </tr>
  <tr>
    <td>microservice</td>
    <td>被熔断的服务名</td>
  </tr>
  <tr>
    <td>schema</td>
    <td>被熔断的服务的契约ID</td>
  </tr>
  <tr>
    <td>operation</td>
    <td>被熔断的服务的方法名</td>
  </tr>
  <tr>
    <td>currentTotalRequest</td>
    <td>当前总请求数</td>
  </tr>
  <tr>
    <td>currentErrorCount</td>
    <td>当前请求出错计数</td>
  </tr>
  <tr>
    <td>currentErrorPercentage</td>
    <td>当前请求出错百分比</td>
  </tr>
  <tr>
    <td>requestVolumeThreshold</td>
    <td>10s内请求数需要大于等于这个参数值，才开始计算错误率和判断是否进行熔断</td>
  </tr>
  <tr>
    <td>sleepWindowInMilliseconds</td>
    <td>熔断效果维持时间</td>
  </tr>
  <tr>
    <td>errorThresholdPercentage</td>
    <td>错误率阈值，达到此阈值则触发熔断</td>
  </tr>
  <!-- isolation -->
  <tr>
    <td rowspan="12">IsolationServerEvent<br/>实例隔离事件</td>
    <td>type</td>
    <td>事件类型，包含`OPEN`/`CLOSE`两个枚举值，分别表示事件发生和事件恢复</td>
  </tr>
  <tr>
    <td>microserviceName</td>
    <td>被隔离实例的微服务名</td>
  </tr>
  <tr>
    <td>endpoint</td>
    <td>被隔离实例的endpoint信息</td>
  </tr>
  <tr>
    <td>instance</td>
    <td>被隔离实例的实例信息，类型为<code>org.apache.servicecomb.serviceregistry.api.registry.MicroserviceInstance</code></td>
  </tr>
  <tr>
    <td>currentTotalRequest</td>
    <td>当前实例总请求数</td>
  </tr>
  <tr>
    <td>currentCountinuousFailureCount</td>
    <td>当前实例连续出错次数</td>
  </tr>
  <tr>
    <td>currentErrorPercentage</td>
    <td>当前实例出错百分比</td>
  </tr>
  <tr>
    <td>minIsolationTime</td>
    <td>实例隔离效果维持的最短事件，单位为毫秒</td>
  </tr>
  <tr>
    <td>enableRequestThreshold</td>
    <td>开启实例隔离状态统计的阈值，总请求次数超过此阈值时开始计算请求失败情况，判断是否隔离实例</td>
  </tr>
  <tr>
    <td>continuousFailureThreshold</td>
    <td>连续请求失败阈值，在连续请求失败次数触发隔离的模式下，如果一个实例连续调用失败次数超过此阈值则被隔离</td>
  </tr>
  <tr>
    <td>errorThresholdPercentage</td>
    <td>请求错误率阈值，在请求错误率触发隔离的模式下，如果一个实例的请求失败率超过此阈值则被隔离</td>
  </tr>
  <tr>
    <td>singleTestTime</td>
    <td>实例隔离效果维持时间</td>
  </tr>
</table>

## 使用参考

- 定义告警事件监听器

```java
public class AlarmListener {
  @Subscribe
  public void onAllKindsOfEvent(AlarmEvent event) {
    // 监听告警事件的基类以获取所有种类的告警事件
  }

  @Subscribe
  public void onCircutBreakerEvent(CircutBreakerEvent event) {
    // 仅监听服务熔断事件
  }

  @Subscribe
  public void onIsolationServerEvent(IsolationServerEvent event) {
    // 仅监听实例隔离事件
  }
}
```

事件监听器示例如上所示，监听器里的三个方法分别用于监听全部告警事件、仅监听服务熔断事件、仅监听实例隔离事件。
注意，监听器里的三个方法不是必需的，使用者可以根据自身需要，自行决定需要在监听器中定义的方法。

- 在`EventBus`中注册事件监听器

```
EventManager.getEventBus().register(receiveEvent);
```
