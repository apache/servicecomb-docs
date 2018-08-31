## Scenario

Due to the non-security of the HTTP protocol, data transmitted over the network can be easily monitored by various packet capture tools. In practical applications, services have high security requirements for sensitive data transmitted between applications or services. Such data requires special encryption protection (different services have different algorithm requirements) so that even if the content is intercepted, it can protect. Sensitive data is not easily obtained.

## Solution

The communication between services leaves unserialized and deserialized. For the above scenario, the @JsonSerialize and @JsonDeserialize annotation functions provided by the jackson class library are used to customize the serialization and deserialization methods for sensitive data, and in a customized method. Implement encryption and decryption functions.

Annotation descriptive reference: Find the corresponding version of Javadocs in [https://github.com/FasterXML/jackson-databind/wiki] (https://github.com/FasterXML/jackson-databind/wiki)

##example

1. Use the specific serialization and deserialization methods for annotations by setting the name property in the Person object. Note: This shows how to use it, not related to encryption and decryption.

```
public class Person {
  private int usrId;

  // Specify data name using a specific serialization and deserialization method
  @JsonSerialize(using = SecretSerialize.class)
  @JsonDeserialize(using = SecretDeserialize.class)
  private String name;

  public int getUsrId() {
    return usrId;
  }

  public void setUsrId(int usrId) {
    this.usrId = usrId;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  @Override
  public String toString() {
    return "Person{" +
        "usrId=" + usrId +
        ", name='" + name + '\'' +
        '}';
  }
}
```

2. Define the SecretSerialize class and the SecretDeserialize class and override their methods

```
public class SecretSerialize extends JsonSerializer<String> {

  // Rewrite the serialization method of a name, where you can implement custom encryption or decryption or other operations
  @Override
  public void serialize(String value, JsonGenerator gen, SerializerProvider serializers)
      throws IOException, JsonProcessingException {
    // Add 4 specific characters after the data name
    value = value + " &#@";

    // Perform serialization operations
    gen.writeString(value);
  }
}

public class SecretDeserialize extends JsonDeserializer<String> {

  // Rewrite the deserialization method of a name, match the serialize serialization method, get the real data according to the rules customized by the user
  @Override
  public String deserialize(JsonParser p, DeserializationContext ctxt) throws IOException, JsonProcessingException {
    // Get the deserialized data, remove 4 specific characters, get the real name
    String value = p.getValueAsString();
    value = value.substring(0, value.length() - 4);
    return value;
  }
}
```
