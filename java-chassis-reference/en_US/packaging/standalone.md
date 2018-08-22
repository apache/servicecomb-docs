## Concept Description

A Standalone container that loads Spring with a simple Main, because the service usually does not require the properties of a Web container such as Tomcat/JBoss, and there is no need to use the Web container to load the service. The microframework provides a standalone deployment run mode. The service container is just a simple Main method and loads a simple Spring container to expose the service.

## Operation steps

* **Step 1** Write the Main function, initialize the log and load the service configuration as follows:

```java
import org.apache.servicecomb.foundation.common.utils.BeanUtils;
import org.apache.servicecomb.foundation.common.utils.Log4jUtils;

public class MainServer {
public static void main(String[] args) throws Exception {
　Log4jUtils.init(); # Log initialization
　BeanUtils.init();  # Spring bean initialization
 }
}
```

* **Step 2** Run the MainServer to start the microservice process and expose the service.

## Notes

If you are using the rest network channel, you need to change the transport in the pom to use the cse-transport-rest-vertx package.
