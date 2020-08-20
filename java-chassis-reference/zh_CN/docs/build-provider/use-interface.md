# 只发布interface的方法为服务接口

不管采用 `JAX RS`, `Spring MVC`， 还是采用 `透明RPC` 开发， java-chassis 默认会扫描实现类的所有方法，
将 `public` 方法发布为服务接口。 从 2.1.1 版本开始， 增加了 `schemaInterface` 属性， 实现类可以通过
实现 `schemaInterface` 对应的接口， 最终只有 `schemaInterface` 的方法发布为服务接口。 

## JAX RS 的例子

首先定义接口：

```java
@Path("/jaxrs/schemaInterface")
@Produces(MediaType.APPLICATION_JSON)
public interface SchemeInterfaceJaxrs {
  @Path("/add")
  @GET
  public int add(@Min(1) @RequestParam("a") int a, @Min(1) @RequestParam("b") int b);

  @Path("/interfaceModel")
  @GET
  Page<String> interfaceModel(Page<String> model);
}
```

实现类指定 `schemaInterface`:

```java
@RestSchema(schemaId = "SchemeInterfaceJaxrs", schemaInterface = SchemeInterfaceJaxrs.class)
public class SchemeInterfaceJaxrsImpl implements SchemeInterfaceJaxrs {
  @Override
  public int add(@Min(1) int a, @Min(1) int b) {
    return a + b;
  }

  public int reduce(int a, int b) {
    return a - b;
  }

  @Override
  public Page<String> interfaceModel(Page<String> model) {
    return model;
  }
}
```

上面的例子中，只有 `add` 和 `interfaceModel` 发布为服务接口， `reduce` 不会发布为服务接口。 客户端
通过透明 RPC 的方式访问：

```java
public interface SchemeInterfaceJaxrs {
  int add(int a, int b);

  int reduce(int a, int b);

  Page<String> interfaceModel(Page<String> model);
}


@RpcReference(schemaId = "SchemeInterfaceJaxrs", microserviceName = "jaxrs")
private SchemeInterfaceJaxrs jaxrs;

public void testAllTransport() throws Exception {
    TestMgr.check(3, jaxrs.add(1, 2));
    
    try {
      jaxrs.reduce(1, 3);
      TestMgr.failed("should throw exception", new Exception());
    } catch (Exception e) {
      TestMgr.check(
          "Consumer method org.apache.servicecomb.demo.jaxrs.client.SchemeInterfaceJaxrs:reduce "
              + "not exist in contract, microserviceName=jaxrs, schemaId=SchemeInterfaceJaxrs; "
              + "new producer not running or not deployed.",
          e.getMessage());
    }
}
```

访问 `reduce` 会抛出异常， 访问 `add` 能够得到正确的结果。 


## Spring MVC 和 透明RPC

这两种方式和 JAX RS 类似，不详细举例了。 使用 @RestSchema， @RpcSchema 的时候， 相关的 Annotation 必须
在 schemaInterface 声明， 在实现类声明无效，这些 Annotation 包括 `JAX RS`, `Spring MVC` 
和 `Swagger 注解` 。 同时需要注意，由于 @Path, @RequestMapping 这些 Annotation 只能在 schemaInterface 声明,
每个接口的 URL 必须唯一，所以这个功能限制了一个接口只能定义一个实现类。 

