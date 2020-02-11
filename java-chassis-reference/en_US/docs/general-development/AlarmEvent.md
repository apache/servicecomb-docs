# Get warning event from Circuit Breaker or Instance Isolation.

## Senario
* When the microservice is running, Circuit Breaker or the instance isolation status changes, you need to listen to related events, get relevant information and handle it.

## Use Reference

* Monitor CircuitBreaker events
```
Object receiveEvent = new Object() {
  @Subscribe
  public void onEvent(CircutBreakerEvent circutBreakerEvent) {
    //Get information from circutBreakerEvent
    }
  };
EventManager.getEventBus().register(receiveEvent);
```
* Listen for instance isolation events
```
Object receiveEvent = new Object() {
  @Subscribe
  public void onEvent(IsolationServerEvent isolationServerEvent) {
    //Get information from isolationServerEvent
    }
  };
EventManager.getEventBus().register(receiveEvent);
```
* Both events are monitored
```
Object receiveEvent = new Object() {
  @Subscribe
  public void onEvent(AlarmEvent alarmEvent) {
    //Get information from alarmEvent
    }
  };
EventManager.getEventBus().register(receiveEvent);
```
