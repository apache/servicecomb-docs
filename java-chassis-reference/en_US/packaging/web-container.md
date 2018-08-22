## Concept Description

If you need to load the microservice into the web container to start the runtime, you need to create a new servlet project wrapper, the servlet project, you just need to write few lines of code

## Development example

Refer to the "Development Service Provider" -> "Communication Protocol" -> "REST over Servlet" chapter.

## Notes

Restful calls should be isolated from other static resource calls (such as html, js, etc.) in the web container, so there should be a layer of keywords in the post after webroot, such as the example in web.xml above (/test/rest) In the rest.

Take tomcat as an example. By default, each war package has a different webroot. This webroot needs to be a basePath prefix. For example, if webroot is testing, all the contracts of the microservice must start with /test.

When the microservice is loaded in the web container and directly uses the http and https ports opened by the web container, it is necessary to satisfy the rules of the web container because it is the communication channel of the web container used.

##
