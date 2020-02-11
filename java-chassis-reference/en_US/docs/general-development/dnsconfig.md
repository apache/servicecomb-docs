## Scenario
When a user uses a domain name to connect to a public cloud or a third-party system, you need to use the domain name resolution DNS system. The DNS used in different systems and different frameworks may be different. Therefore, it is necessary to provide a unified configuration entry so that development and operation personnel can customize the DNS resolution mechanism without being completely subject to system configuration.

## DNS Configuration

The DNS configuration item is written in the microservice.yaml file. It supports the unified development of certificates. It can also add tags for more fine-grained configuration. The tag configuration overrides the global configuration. The configuration format is as follows:

```
addressResolver.[tag].[property]
```

The common tags are as follows:

| Project | tag |
| :--- | :--- |
| Service Center | sc.consumer |
| Configuration Center | cc.consumer |
| User Defined | self.tag |

The detailed description of each property (Set Vertx DNS resolution)

``` yaml
addressResolver:
  servers: 8.8.8.8, 8.8.4.4 #corresponds to the nameserver of Linux /etc/resolv.conf, the DNS server address, supports multiple configurations, separated by commas
  ndots: 1 # corresponds to the options in linux /etc/resolv.conf: ndots, the role is that if the number of points contained in the domain name is less than the threshold, then DNS resolution will be added by default to the value of searchDomains. This must be used in conjunction with searchDomains.  
  searchDomains: a, b, c # Corresponding to the search in linux /etc/resolv.conf, and ndots, if the number of points in the current domain name is less than the set value, these values will be added to the domain name and parsed together when parsing, for example, the ndots is set to 4. The current domain name is servicecomb.cn-north-1.myhwclouds.com, only three points. Then the servicecomb.cn-north-1.myhwclouds.com.a will be automatically parsed when parsing, not parsed out. Servicecomb.cn-north-1.myhwclouds.com.b until it can be finally parsed
  optResourceEnabled: true #optional record is automatically included in DNS queries
  cacheMinTimeToLive: 0 #minimum cache time
  cacheMaxTimeToLive: 10000 #Maximum cache time
  cacheNegativeTimeToLive: 0 #DNS resolving failure time after the next retry
  queryTimeout: 5000 #Query timeout
  maxQueries: 4 #Query times
  rdFlag: true #Set DNS recursive query
  rotateServers: true #Set whether to support polling
```
##example

```java
VertxOptions vertxOptions = new VertxOptions();
vertxOptions.setAddressResolverOptions(AddressResolverConfig.getAddressResover("self.tag"));
Vertx vertx = VertxUtils.getOrCreateVertxByName("registry", vertxOptions);
// this has to set the client options
HttpClientOptions httpClientOptions = createHttpClientOptions();
ClientPoolManager<HttpClientWithContext> clientMgr = new ClientPoolManager<>(vertx, new HttpClientPoolFactory(httpClientOptions));
clientMgr.findThreadBindClientPool().runOnContext(httpClient -> {
    // do some http request
});
```
