## Processing Chain Reference
Handlers are the core components of ServiceComb, which form the basis of service operation and control. ServiceComb handles load balancing, fuse tolerance, flow control, and more through the processing chain.

## Development Processing Chain
The developer's custom processing chain consists of the following steps. Since the core component of ServiceComb is the processing chain, developers can refer to the implementation of the handlers directory to learn more about the processing chain. Here are a few key steps to summarize:

* Implement Handler interface
* Add *.handler.xml file, give Handler a name
* Enable the newly added processing chain in microservice.yaml
