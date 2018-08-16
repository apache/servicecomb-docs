# Shutdown gracefully
ServiceComb achieve graceful shutdown through JDK's ShutdownHook.

## Scenes

Graceful shutdown can solve the following scenes:
* KILL PID
* Application automatically exits unexpectedly（System.exit(n)）

Graceful shutdown can't solve the following scenes:
* KILL -9 PID or taskkill /f /pid

## Effect
When triggering graceful shutdown:
* Provider:
  * Mark the current service status as STOPPING, do not accept new client requests, the new request will report error directly on the client, and the client cooperates with the retry mechanism to retry other instances;
  * Wait for the currently running thread to finish executing. If the provider side has set timeout, will be forced to close after timeout;
* consumer:
  * Mark the current service state as STOPPING, do not send a new call request;
  * Waiting for the response of the currently sent request, if it exceeds the timeout period for the client to receive the response (default 30 seconds), it is forcibly closed;

## Principle
When an graceful shutdown is triggered, the following steps are performed in sequence:
1. Send a BEFORE_CLOSE event to all listeners, and notify the listener to handle the corresponding event;
2. Mark the current service status as STOPPING;
3. Log out the current microservice instance from the service center and close the vertx corresponding registry;
4. Waiting for all currently existing invocation calls to complete;
5. Close the vertx corresponding to config-center and transport;
6. Send an AFTER_CLOSE event to all listeners, and notify the listener to handle the corresponding event;
7. Mark the current service status as DOWN; graceful shutdown ends;
