# Get the fuse and instance isolation alarm events

## Scene Description
* When the microservice is running or the instance isolation status changes, you need to listen to related events, get relevant information and process it.

## Use Reference

* Monitor blown events
```
Object receiveEvent = new Object() {
  @Subscribe
  public void onEvent(CircutBreakerEvent circutBreakerEvent) {
    //Get information from circutBreakerEvent
    }
  };
circutBreakerEventNotifier.eventBus.register(receiveEvent);
```
* Listen for instance isolation events
```
Object receiveEvent = new Object() {
  @Subscribe
  public void onEvent(IsolationServerEvent isolationServerEvent) {
    //Get information from isolationServerEvent
    }
  };
circutBreakerEventNotifier.eventBus.register(receiveEvent);
```
* Both events are monitored
```
Object receiveEvent = new Object() {
  @Subscribe
  public void onEvent(AlarmEvent alarmEvent) {
    //Get information from alarmEvent
    }
  };
circutBreakerEventNotifier.eventBus.register(receiveEvent);
```
