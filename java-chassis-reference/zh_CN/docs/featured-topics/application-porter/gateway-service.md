这个章节中，介绍如何通过网关转发请求。java-chassis提供了非常灵活的网关服务，开发者能够非常简单的实现微服务之间的转发，网关拥有客户端一样的服务治理能力。同时，开发者可以使用vert.x暴漏的HTTP API，实现非常灵活的转发控制。

网关服务由一系列的VertxHttpDispatcher组成，开发者通过继承AbstractEdgeDispatcher，来实现自己的转发机制。

为了实现gateway-service将请求转发到file-service，定义了如下规则：

* 直接请求file-service: DELETE [http://localhost:9091/delete](http://localhost:9091/delete)

* 通过网关：DELETE [http://localhost:9090/api/file-service/delete](http://localhost:9090/api/file-service/delete)

达到这个目的的代码如下，在请求处理的时候，使用EdgeInvocation，可以实现请求转发，并开启各种治理功能。下面代码的核心内容是定义转发规则regex。

```
public class ApiDispatcher extends AbstractEdgeDispatcher {
    @Override
    public int getOrder() {
        return 10002;
    }

    @Override
    public void init(Router router) {
        String regex = "/api/([^\\/]+)/(.*)";
        router.routeWithRegex(regex).handler(CookieHandler.create());
        router.routeWithRegex(regex).handler(createBodyHandler());
        router.routeWithRegex(regex).failureHandler(this::onFailure).handler(this::onRequest);
    }

    protected void onRequest(RoutingContext context) {
        Map<String, String> pathParams = context.pathParams();
        String microserviceName = pathParams.get("param0");
        String path = "/" + pathParams.get("param1");

        EdgeInvocation invoker = new EdgeInvocation();
        invoker.init(microserviceName, context, path, httpServerFilters);
        invoker.edgeInvoke();
    }
}
```

为了实现gateway-service将请求转发到porter-website，定义了如下规则：

* 直接请求porter-website: GET [http://localhost:9093/index.html](http://localhost:9093/index.html)

* 通过网关：GET [http://localhost:9090/ui/porter-website/index.html](http://localhost:9090/ui/porter-website/index.html)

UI静态页面信息不需要实现治理能力（服务治理能力需要契约，静态页面不存在接口契约），因此直接使用vert.x的API实现请求转发。在下面的代码中，还使用java chassis API做了服务发现，并实现了一个简单的RoundRobin负载均衡策略，从而允许porter-website也进行多实例部署。

```
public class UiDispatcher extends AbstractEdgeDispatcher {
    private static Logger LOGGER = LoggerFactory.getLogger(UiDispatcher.class);

    private static Vertx vertx = VertxUtils.getOrCreateVertxByName("web-client", null);

    private static HttpClient httpClient = vertx.createHttpClient(new HttpClientOptions());

    private Map<String, DiscoveryTree> discoveryTrees = new ConcurrentHashMapEx<>();

    private AtomicInteger counter = new AtomicInteger(0);

    @Override
    public int getOrder() {
        return 10001;
    }

    @Override
    public void init(Router router) {
        String regex = "/ui/([^\\/]+)/(.*)";
        router.routeWithRegex(regex).failureHandler(this::onFailure).handler(this::onRequest);
    }

    protected void onRequest(RoutingContext context) {
        Map<String, String> pathParams = context.pathParams();

        String microserviceName = pathParams.get("param0");
        String path = "/" + pathParams.get("param1");

        URI uri = chooseServer(microserviceName);

        if (uri == null) {
            context.response().setStatusCode(404);
            context.response().end();
            return;
        }

        // 使用HttpClient转发请求
        HttpClientRequest clietRequest =
            httpClient.request(context.request().method(),
                    uri.getPort(),
                    uri.getHost(),
                    "/" + path,
                    clientResponse -> {
                        context.request().response().setChunked(true);
                        context.request().response().setStatusCode(clientResponse.statusCode());
                        context.request().response().headers().setAll(clientResponse.headers());
                        clientResponse.handler(data -> {
                            context.request().response().write(data);
                        });
                        clientResponse.endHandler((v) -> context.request().response().end());
                    });
        clietRequest.setChunked(true);
        clietRequest.headers().setAll(context.request().headers());
        context.request().handler(data -> {
            clietRequest.write(data);
        });
        context.request().endHandler((v) -> clietRequest.end());
    }

    private URI chooseServer(String serviceName) {
        URI uri = null;

        DiscoveryContext context = new DiscoveryContext();
        context.setInputParameters(serviceName);
        DiscoveryTree discoveryTree = discoveryTrees.computeIfAbsent(serviceName, key -> {
            return new DiscoveryTree();
        });
        VersionedCache serversVersionedCache = discoveryTree.discovery(context,
                RegistryUtils.getAppId(),
                serviceName,
                DefinitionConst.VERSION_RULE_ALL);
        Map<String, MicroserviceInstance> servers = serversVersionedCache.data();
        String[] endpoints = asArray(servers);
        if (endpoints.length > 0) {
            int index = Math.abs(counter.getAndIncrement() % endpoints.length);
            String endpoint = endpoints[index];
            try {
                uri = new URI(endpoint);
            } catch (URISyntaxException e) {
                LOGGER.error("", e);
            }
        }
        return uri;
    }

    private String[] asArray(Map<String, MicroserviceInstance> servers) {
        List<String> endpoints = new LinkedList<>();
        for (MicroserviceInstance instance : servers.values()) {
            endpoints.addAll(instance.getEndpoints());
        }
        return endpoints.toArray(new String[endpoints.size()]);
    }
}
```

完成VertxHttpDispatcher开发后，需要通过SPI的方式加载到系统中，需要增加META-INF/services/org.apache.servicecomb.transport.rest.vertx.VertxHttpDispatcher配置文件，并将增加的两个实现写入该配置文件中。

网关服务开发完成后，所有的用户请求都可以通过网关来发送。开发者通过通过设置防火墙等机制，限制用户直接访问内部服务，保证内部服务的安全。

