# return value serialization extension
## Concept Description

The current REST channel return value supports both application/json and text/plain formats, supports developer extensions and rewrites, service providers provide serialization capabilities through producer declarations, and service consumers specify return value serialization through the request's Accept header. By default, the data in application/json format is returned.

## Development Instructions

* ### extension

  Developers can extend the return value serialization method programmatically based on business needs. The implementation steps are as follows, taking the extended support application/xml format as an example:

  1. Implement the interface `ProduceProcessor`.

  > getName\(\) returns the current extended data type name
  >
  > getOrder\(\) returns the current data type priority. It has multiple implementation classes with the same name. It only loads the highest priority. The smaller the number, the higher the priority.
  >
  > doEncodeResponse\(OutputStream output, Object result\) encodes the result object into output, where the logic needs to be implemented by itself.
  >
  > doDecodeResponse\(InputStream input, JavaType type\) parses the input into the corresponding object, where the logic needs to be implemented by itself.

  ```java
  public class ProduceAppXmlProcessor implements ProduceProcessor {

    @Override
    public String getName() {
      return MediaType.APPLICATION_XML;
    }

    @Override
    public int getOrder() {
      return 0;
    }

    @Override
    public void doEncodeResponse(OutputStream output, Object result) throws Exception {
      output.write(JAXBUtils.convertToXml(result).getBytes());
    }

    @Override
    public Object doDecodeResponse(InputStream input, JavaType type) throws Exception {
      return JAXBUtils.convertToJavaBean(input, type);
    }
  }
  ```

  2. Add a configuration file

  In the META-INF/services/ folder under resources, create a new file xxx.ProduceProcessor (xxx is the package name of the interface), and fill in the content xxx.ProduceAppXmlProcessor (xxx is the package name of the implementation class).

* ### Rewrite

  Developers can rewrite the existing application/json and text/plain implementation logic, or rewrite the self-extended format to rewrite the xml serialization method as an example:

  1. Create a class named 'ProduceAppXmlProcessor` with the same name to implement the interface `ProduceProcessor`.

  2. Rewrite the codec logic in the `doEncodeResponse` and `doDecodeResponse` methods

  3. Change the return value in the getOrder method, which is smaller than the return value of the original method. For example, return -1, the original method return value of application/json and text/plain defaults to 0.

  4. In the META-INF/services/ folder under resources, create a new file xxx.ProduceProcessor (xxx is the package name of the interface), and fill in the content xxx.ProduceAppXmlProcessor (xxx is the package name of the implementation class).

* ### verification

  Service providers provide xml serialization capabilities through producer declarations

  ```java
    @RequestMapping(path = "/appXml", method = RequestMethod.POST, produces = MediaType.APPLICATION_XML_VALUE)
    public JAXBPerson appXml(@RequestBody JAXBPerson person) {
      return person;
    }
  ```

  The service consumer indicates the return value xml serialization mode through the request's Accept header.

  ```java
    private void testCodeFirstAppXml(RestTemplate template, String cseUrlPrefix) {
      JAXBPerson person = new JAXBPerson("jake", 22, "it", "60kg");
      person.setJob(new JAXBJob("developer", "coding"));
      HttpHeaders headers = new HttpHeaders();
      headers.add("Accept", MediaType.APPLICATION_XML_VALUE);
      HttpEntity<JAXBPerson> requestEntity = new HttpEntity<>(person, headers);
      ResponseEntity<JAXBPerson> resEntity = template.exchange(cseUrlPrefix + "appXml",
          HttpMethod.POST,
          requestEntity,
          JAXBPerson.class);
      TestMgr.check(person, resEntity.getBody());
    }
  ```
