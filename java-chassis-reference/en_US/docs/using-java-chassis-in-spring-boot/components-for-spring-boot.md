# spring boot starter for java-chassis

java-chassis provide different starters for spring boot. 

## java-chassis 2.0.0 and above with spring boot 2.0 and above [example](https://github.com/apache/servicecomb-samples/tree/master/porter_springboot)

* java-chassis-spring-boot-starter-standalone

For standalone applications:

POM dependency：

```
  <dependencies>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>java-chassis-spring-boot-starter-standalone</artifactId>
    </dependency>
  </dependencies>
```

* java-chassis-spring-boot-starter-servlet

For web applications:

POM dependency：

```
  <dependencies>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>java-chassis-spring-boot-starter-servlet</artifactId>
    </dependency>
  </dependencies>
```

dependency management for applications：

```
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.apache.servicecomb</groupId>
        <artifactId>java-chassis-dependencies</artifactId>
        <version>2.0.0-SNAPSHOT</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
```

## java-chassis 1.3.0 and above with spring boot 2.0 and above [example](https://github.com/apache/servicecomb-samples/tree/1.3.0/dependency_management/springboot2)

* spring-boot2-starter-standalone

For standalone applications:

POM dependency：

```
  <dependencies>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>spring-boot2-starter-standalone</artifactId>
    </dependency>
  </dependencies>
```

* spring-boot2-starter-servlet

For web applications:

POM dependency：

```
  <dependencies>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>spring-boot2-starter-servlet</artifactId>
    </dependency>
  </dependencies>
```

dependency management for applications：

```
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.apache.servicecomb</groupId>
        <artifactId>java-chassis-dependencies-springboot2</artifactId>
        <version>1.3.0</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
```

## java-chassis 1.3.0 and above with spring boot 1.0 and above [example](https://github.com/apache/servicecomb-samples/tree/1.3.0/dependency_management/springboot1)

* spring-boot-starter-provider

For standalone applications:

POM dependency：

```
  <dependencies>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>spring-boot-starter-provider</artifactId>
    </dependency>
  </dependencies>
```

* spring-boot-starter-transport

For web applications:

POM dependency：

```
  <dependencies>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>spring-boot-starter-transport</artifactId>
    </dependency>
  </dependencies>
```

dependency management for applications：

```
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.apache.servicecomb</groupId>
        <artifactId>java-chassis-dependencies-springboot1</artifactId>
        <version>1.3.0</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
      <!-- spring boot 1.5.14.RELEASE use a low version of validation-api, must override it -->
      <dependency>
        <groupId>javax.validation</groupId>
        <artifactId>validation-api</artifactId>
        <version>2.0.0.Final</version>
      </dependency>
    </dependencies>
  </dependencyManagement>
```

