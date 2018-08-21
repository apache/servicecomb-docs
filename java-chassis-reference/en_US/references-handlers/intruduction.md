## Handlers Reference
Handlers are the core components of ServiceComb, which form the basis of service operation and control. ServiceComb handles load balancing, fuse tolerance, flow control, and more through the Handlers.

## Development Handlers
The developer's custom handlers consists of the following steps. Since the core component of ServiceComb is the handlers, developers can refer to the implementation of the handlers directory to learn more about the Handlers. Here are a few key steps to summarize:

* Implement Handler interface
* Add *.handler.xml file, give handler a name
* Enable the newly added Handlers in microservice.yaml
