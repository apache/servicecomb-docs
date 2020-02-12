# verticle-count

## name and default value
* Version prior to 1.2.0  
  Named thread-count, and the default value is 1, which has the following problems:  
  * The name is ambiguous  
    The underlying ServiceComb is based on vertx. The communication layer logic is hosted by verticle, running in the eventloop thread, and no separate threads are created.
    So thread-count actually represents the number of verticle instances created, not the number of threads.
  * The default value is too small  
    Because there is no best configuration in all scenarios, the old version chose the most conservative default value, which leads to the adjustment of these parameters in most scenarios.
* 1.2.0 and later versions  
  Renamed to verticle-count  
  At the same time, the old thread-count is allowed, but the warning log is printed, reminding to switch to the new configuration.  
  Default rule：  
  * If the number of CPUs is less than 8, the number of CPUs is taken.
  * 8 if the number of CPUs is greater than or equal to 8.
  
## The relationship between Eventloop and verticle instances:  
Assuming the CPU is 2, vertx creates 2 * CPU by default, ie 4 Eventloop threads.  
Assuming the configuration server verticle count and client verticle count are both 3, then:  
![](../assets/eventloop-and-verticle.png)  
Because it is not allowed to perform any blocking action in the Eventloop, combined with the above figure, we can know that when the CPU is fully utilized, it is meaningless to add the verticle instance.  
Users are advised to combine their actual scenarios to test and summarize the appropriate configuration values.