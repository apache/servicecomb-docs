# 使用Context传递控制消息

Context 用于在微服务之间和微服务内部传递上下文数据。 Context 是 key/value 对，只能够使用 String 类型。
Context 会序列化为 json 格式并通过 HTTP Header 传递，因此也不支持 ASCII 之外的字符，其他字符需要开发者先自行编码再传递。
Context 在一次请求中，会在请求链上传递，不需要重新设置。[access log](../build-provider/access-log-configuration.md)的 trace id 等
功能都基于这个特性实现的。

Context 保存的内容分为 context 和 localContext。 localContext 在调用过程中，会在进程内部传递， 而 context 的内容会传递到调用过程中
远端服务。 这种传递是单向的。比如在一个 Provider 内部， 调用接口， 那么 localContext 的内容会复制给调用接口运行过程中的 localContext，
如果这个接口在调用过程中修改了 localContext， 接口返回后， Provider 后续的逻辑处理看不到对于 context 的修改。 

在 Handler 或者 Filter 中调用其他微服务， context 信息默认不会复制，需要开发者显示的将 context 信息传递过去。 使用 RestTemplate 或者
RPC 方式传递 context 的例子，请参考本文后面的案例。  

## 使用 Context 的场景

* 在认证场景，Edge Service 认证通过以后，需要将会话 ID、用户名称等信息传递给微服务，实现鉴权等逻辑。
* 灰度发布场景，需要结合自定义的 tag 实现引流，tag 信息需要传递给微服务。
* 开发 Handler 处理链的时候，一个 Handler 需要将计算结果传递给下一个 Handler。

## 使用参考

* 在 Hanlder 中获取和设置Context
    Handler 包含了 Invocation 对象，可以直接调用 invocation.addContext 和 invocation.getContext 。

* 在服务接口中获取Context

    通过接口注入
    
        ```
        public Response cseResponse(InvocationContext c1)
        ```
    或者
    
        ```
        ContextUtils.getInvocationContext()
        ```

* 在Edge Service中设置Context

    通过重载EdgeInvocation
    
        ```
        EdgeInvocation edgeInvocation = new EdgeInvocation() {
          protected void createInvocation() {
            super.createInvocation();
            this.invocation.addContext("hello", "world");
          }
        };
        ```
        
## 案例： 使用 Context 和 DiscoveryTree 实现轮询调用一个微服务的所有实例

通常微服务的调用，是将请求发送到一个实例，这个实例是根据负载均衡策略决定的，业务开发不可控制。为了实现轮询调用一个微服务的所有实例，
首先需要获取一个微服务的所有实例列表，然后逐个调用。 LoadBalance 模块支持通过 Context 传递 Endpoint 信息， 如果 Endpoint 已经
设置， 可以跳过负载均衡判断， 使用用户自己指定的 Endpoint。 

* 使用 DiscoveryTree 获取微服务实例列表

        ```java
        public class TestDateTimeSchema {
          private DiscoveryTree discoveryTree = new DiscoveryTree();
        
          public TestDateTimeSchema() {
            discoveryTree.addFilter(new CustomEndpointDiscoveryFilter());
            discoveryTree.sort();
          }
          
          private void testDateTimeSchemaMulticast() throws Exception {
            DiscoveryContext context = new DiscoveryContext();
            VersionedCache serversVersionedCache = discoveryTree.discovery(context, "springmvctest", "springmvc", "0+");
            List<String> enpoints = serversVersionedCache.data(); // 获取到实例列表，可以给下面的处理流程使用
          }
        }
        
        public class CustomEndpointDiscoveryFilter extends AbstractEndpointDiscoveryFilter {
          @Override
          protected String findTransportName(DiscoveryContext context, DiscoveryTreeNode parent) {
            //only need rest endpoints
            return "rest";
          }
        
          @Override
          protected Object createEndpoint(String transportName, String endpoint, MicroserviceInstance instance) {
            return endpoint;
          }
        
          @Override
          public int getOrder() {
            return 0;
          }
        }
        ```
    
    上面的代码通过 DiscoveryTree 发现实例列表， 并且实现了 CustomEndpointDiscoveryFilter ， 将发现的实例信息转换为 cache 的返回
    类型， 即 String。
    
* 通过 InvocationContext 传递 Endpoint 信息给 Load Balance, 每次调用访问用户指定的 Endpoint。
    访问 InvocationContext 分几种场景， 参考文章上面提到的情况。 在 Consumer 调用的场景下， 可能不在一个 Provider 的处理上下文中，
    这个时候系统中还没有 InvocationContext 实例， 这个时候可以新创建一个实例， 新创建的实例信息会复制到系统内部。 
    
    使用 RPC Consumer 传递 InvocationContext 的例子：
    
        ```java
          interface DateTimeSchemaWithContextInf {
            Date getDate(InvocationContext context, Date date);
          }
      
          @RpcReference(microserviceName = "springmvc", schemaId = "DateTimeSchema")
          private DateTimeSchemaWithContextInf dateTimeSchemaWithContextInf;
      
          // code slip
          for (String endpoint : enpoints) {
            InvocationContext invocationContext = new InvocationContext();
            invocationContext.addLocalContext(LoadbalanceHandler.SERVICECOMB_SERVER_ENDPOINT, parseEndpoint(endpoint));
            Date date = new Date();
            TestMgr.check(date.getTime(), dateTimeSchemaWithContextInf.getDate(invocationContext, date).getTime());
          }
      
          // code slip
          private Endpoint parseEndpoint(String endpointUri) throws Exception {
            URI formatUri = new URI(endpointUri);
            Transport transport = SCBEngine.getInstance().getTransportManager().findTransport(formatUri.getScheme());
            return new Endpoint(transport, endpointUri);
          }
        ``` 
     
     使用 RestTemplate 传递  InvocationContext 的例子：
        
        ```
        for (String endpoint : enpoints) {
          CseHttpEntity<?> entity = new CseHttpEntity<>(null);
          InvocationContext invocationContext = new InvocationContext();
          invocationContext.addLocalContext(LoadbalanceHandler.SERVICECOMB_SERVER_ENDPOINT, parseEndpoint(endpoint));
          entity.setContext(invocationContext);
    
          Date date = new Date();
          String dateValue = RestObjectMapperFactory.getRestObjectMapper().convertToString(date);
          TestMgr.check(date.getTime(),
              restTemplate
                  .exchange("cse://springmvc/dateTime/getDate?date={1}", HttpMethod.GET,
                      entity, Date.class, dateValue).getBody().getTime());
         ｝
         ```

    ***注意：*** 2.0.2 版本开始， LoadbalanceHandler.SERVICECOMB_SERVER_ENDPOINT 传递的类型是 Endpoint, 早期版本可以直接传递 String 类型， 
    LoadBalance 模块会将 String 类型转换为 Endpoint。 在有大量 Endpoint 的情况， 提前使用 Endpoint 类型能够减少类型转换，节省处理时间。
