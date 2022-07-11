In some scenarios, the service uses http instead of https as the network transmission channel. To prevent the falsification or tampering request, consumer and the producer must be provided a method to signature the http stream.

The signature method is carried using the org.apache.servicecomb.common.rest.filter.HttpClientFilter and org.apache.servicecomb.common.rest.filter.HttpServerFilter interfaces. It is recommended that the http stream related logic use the Filter mechanism here, and the contract The parameter related logic uses the Handler mechanism.

About the use of the Filter interface, please reference [demo-signature] (https://github.com/ServiceComb/ServiceComb-Java-Chassis/tree/master/demo/demo-signature).



# 1 Overview

The Filter mechanism is loaded using the Java standard SPI mechanism.

Both HttpClientFilter and HttpServerFilter allow multiple loads:

* The order of execution between instances is determined by the return value of getOrder

* If getOrder returns the same value, the corresponding instance order is randomly determined

Whether it is request or response, read the body stream, use getBodyBytes\ (\), the return value may be null (such as scenario of getting an invocation), if not null, the corresponding stream length, Obtain through getBodyBytesLength\ (\ ).

>***Tips***: 
>The beforeSendRequest of HttpClientFilter is executed in the current thread of the interface call, and the afterReceiveResponse is executed in the business thread pool.
>
>The afterReceiveRequest of HttpServerFilter is executed in the business thread pool, beforeSendResponse and beforeSendResponseAsync may be executed in the business thread pool or the network thread pool. Make sure that blocking operations can not occur.
>
>The bottom layer of Java Chassis is an asynchronous framework, with frequent thread switching. When the business extends Filter, if it involves obtaining the thread context through ThreadLocal, the acquisition may be empty. For this scenario, it is recommended to use InhritableThreadLocal instead of ThreadLocal to store data, or to use extended Handler instead of Filter.

# 2.HttpClientFilter

The system has two built-in HttpClientFilter. Note that the order value does not conflict when extending the function:

* org.apache.servicecomb.provider.springmvc.reference.RestTemplateCopyHeaderFilter, order value is Integer.MIN\_VALUE

* org.apache.servicecomb.transport.rest.client.http.DefaultHttpClientFilter, order value is Integer.MAX\_VALUE

## 2.1 Prototype

```
public interface HttpClientFilter {
  int getOrder();

  void beforeSendRequest(Invocation invocation, HttpServletRequestEx requestEx);

  // if finished, then return a none null response
  // if return a null response, then sdk will call next filter.afterReceive
  Response afterReceiveResponse(Invocation invocation, HttpServletResponseEx responseEx);
}
```

## 2.2 beforeSendRequest

Used to send a request after the stream has been generated
calculate the signature based on url, header, query, and stream
then set to the header \ (requestEx.setHeader\).

From the invocation, you can get the various metadata and the object parameters of this call (the stream is generated according to these parameters).

## 2.3 afterReceiveResponse

Used to calculate the signature according to the header and the stream after receiving the response from the network, and compare it with the signature in the header. If the signature is incorrect, directly construct a Response.

As a return value, the framework will interrupt calls to other HttpClientFilters as long as it does not return NULL.

# 3 HttpServerFilter

## 3.1 Prototype

```
public interface HttpServerFilter {
  int getOrder();

  default boolean needCacheRequest(OperationMeta operationMeta) {
    return false;
  }

  // if finished, then return a none null response
  // if return a null response, then sdk will call next filter.afterReceiveRequest
  Response afterReceiveRequest(Invocation invocation, HttpServletRequestEx requestEx);

  // invocation maybe null
  void beforeSendResponse(Invocation invocation, HttpServletResponseEx responseEx);
}
```

## 3.2 needCacheRequest

Unlike HttpClientFilter, the ability to decide whether to cache requests is added.

This is because ServiceComb can not only run in standalone mode but also run in web container (such as Tomcat). In the implementation of a servlet, request stream can only be read once, and does not necessarily support reset (such as Tomcat), RESTful The framework needs to perform deserialization. It needs to read the body stream. The signature logic also needs to read the body stream. If the default processing is used, one of the functions cannot be implemented.

So when running in a web container scenario, all HttpServerFilters, as long as there is a return request that needs to be cached, the body stream will be copied and saved to support repeated reads.

The input parameter is the metadata corresponding to the request, and the service can decide whether the cache request is needed for the request.

## 3.3 afterReceiveRequest

After receiving the request, the signature is calculated according to the URL, header, query, and code stream, and compared with the signature in the header. If the signature is incorrect, a Response is directly constructed as the return value. As long as the NULL is not returned, the framework will interrupt the other HttpClientFilter Call.

## 3.4 beforeSendResponse

Before sending a response, the signature is calculated according to the header and the stream and set to the header.

Because the invocation has not yet been constructed, the call flow has gone wrong, so the invocation may be null.
