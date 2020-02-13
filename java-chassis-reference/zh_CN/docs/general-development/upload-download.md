通过浏览器上传下载文件，是非常普遍的应用场景。java-chassis基于REST提供了上传下载功能：

* 在定义服务提供者的时候，只允许采用Spring MVC 或者 Jax RS模式。 开发服务消费者不受限制，可以使用透明RPC或者RestTemplate。
* 在定义通信模型的时候，只允许使用REST over Vert.x 或者 REST over Servlet，不能够使用HIGHWAY协议。
* 上传下载文件功能默认是关闭的。需要配置servicecomb.uploads.directory启用，如果通过边缘服务(Edge Service)转发请求，边缘服务也需要这个配置项。
* 通过HTTP FORM的方式上传文件（一般采用POST）；通过GET下载文件。

本章节包含如下内容：

* [文件上传开发指导](file-upload.md)
* [文件下载开发指导](file-download.md)

