## Packaged in standalone mode
A Standalone container that loads Spring with a simple Main method, because the service usually does not require the properties of a Web container such as Tomcat/JBoss, and there is no need to use the Web container to load the service. The microframework provides a standalone deployment run mode. The service container is just a simple Main method and loads a simple Spring container to expose the service.

## Packaged in WEB container mode
If you need to load the microservice into the web container to start the runtime, you need to create a new servlet project wrapper. The servlet project, if necessary, can not write or write a small amount of boot code.