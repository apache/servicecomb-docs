## Concept Description

To facilitate the management, using ServiceComb for development, the currently used ServiceComb version number will be reported to the service center, and the version number of other frameworks will be reported when other frameworks integrate ServiceComb.

## Sample Code


Step 1 First, implement the Versions interface of the open source framework ServiceComb, implement the loadVersion method under the interface, and return the version name and version number as key-value pairs.

```
public class MyVersion implements Versions{
  @override
  public Map<String, String> loadVersion() {
    Map<String, String> map = new HashMap<>();
    map.put("My", this.getClass().getPackage().getImplementationVersion());
    return map;
  }
}
```

Step 2 To use the SPI mechanism to make the returned object read by ServiceComb, you need to add the services folder in META-INF and add a file to it, with the name of the interface xxxVersions\ (with package name\). Take the concrete implementation class xxxCseVersion\ (with package name\) as the content

When the service is registered to the ServiceCenter, it will carry all version number information.

```
{
  "serviceId": "xxx",
  "appId": "xxx",
  "registerBy": "SDK",
  "framework": {
    "name": "servicecomb-java-chassis",
    "version": "My:x.x.x;ServiceComb:x.x.x"
  }
}
```

* Remarks

The reported version number can be customized, or it can be read from the MANIFEST.MF of the pom or jar package. If you use .class.getPackage\(\).getImplementationVersion\(\) to get the version number from MANIFEST.MF, you need to Set the maven-jar-plugin archive elements addDefaultImplementationEntries and addDefaultSpecificationEntries to true in the pom file.

```
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-jar-plugin</artifactId>
  <configuration>
    <archive>
      <manifest>
        <addDefaultImplementationEntries>true</addDefaultImplementationEntries>
        <addDefaultSpecificationEntries>true</addDefaultSpecificationEntries>
      </manifest>
    </archive>
  </configuration>
</plugin>
```
