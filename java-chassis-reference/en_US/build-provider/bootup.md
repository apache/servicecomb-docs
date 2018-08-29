# Application Boot-up Process  

The startup process of a service provider includes initializing Log4j, loading bean(including its parameters), and registering service.

* Initialize Log4j:

   By default, Log4jUtils merges the log4j configurations from classpath\*:config/base/log4j.properties and classpath\*:config/log4j.properties, then transfer them to log4j's PropertyConfigurator method to initialize it. If the configuration file with the highest priority is stored on the disk directory with write permission, the combined configuration will be saved to this location to view which parameters take effect during maintenance.

* Load the bean.

   By default `BeanUtils`  loads the configuration file from the `classpath\*:META-INF/spring/\*.bean.xml` Path and transfer the configuration to `ClassPathXmlApplicationContext` of the Spring framework to load the context. In this process, ```BeanUtils``` loads the bean of the foundation-config module.

* Register the microservice.

     When Spring context is loaded, 'org.apache.servicecomb.core.CseApplicationListener' will load the handlers configurations and providers' schema info, then register the microservice in the Service Center.

> **NOTE:**
> ServiceComb have three level of configuration items: configuration center, environment variables, and local files, listed in descending order by priority. If configuration items with the same name exist, the one in the highest level overwrites others. Configuration items stored in the configuration center can be modified during running.
