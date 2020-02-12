# java-chassis 提供的spring boot starter说明

java-chassis提供了spring-boot-starter，方便在spring boot中集成java-chassis。由于早期命名没考虑规范性，在使用这些starter之前，需要注意区分使用的java-chassis版本和spring boot版本。

## java-chassis 2.0.0 以上 + spring boot 2.0以上 [例子](https://github.com/apache/servicecomb-samples/tree/master/porter_springboot)

* java-chassis-spring-boot-starter-standalone

"JAVA应用方式"使用。

POM依赖：

```
  <dependencies>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>java-chassis-spring-boot-starter-standalone</artifactId>
    </dependency>
  </dependencies>
```

* java-chassis-spring-boot-starter-servlet

"Web开发方式"使用。

POM依赖：

```
  <dependencies>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>java-chassis-spring-boot-starter-servlet</artifactId>
    </dependency>
  </dependencies>
```

两种方式的dependency management配置如下：

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

## java-chassis 1.3.x + spring boot 2.0 [例子](https://github.com/apache/servicecomb-samples/tree/1.3.0/dependency_management/springboot2)

* spring-boot2-starter-standalone

"JAVA应用方式"使用。

POM依赖：

```
  <dependencies>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>spring-boot2-starter-standalone</artifactId>
    </dependency>
  </dependencies>
```

* spring-boot2-starter-servlet

"Web开发方式"使用。

POM依赖：

```
  <dependencies>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>spring-boot2-starter-servlet</artifactId>
    </dependency>
  </dependencies>
```

两种方式的dependency management配置如下：

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

## java-chassis 1.3.x + spring boot 1.0 [例子](https://github.com/apache/servicecomb-samples/tree/1.3.0/dependency_management/springboot1)

* spring-boot-starter-provider

"JAVA应用方式"使用。

POM依赖：

```
  <dependencies>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>spring-boot-starter-provider</artifactId>
    </dependency>
  </dependencies>
```

* spring-boot-starter-transport

"Web开发方式"使用。

POM依赖：

```
  <dependencies>
    <dependency>
      <groupId>org.apache.servicecomb</groupId>
      <artifactId>spring-boot-starter-transport</artifactId>
    </dependency>
  </dependencies>
```

两种方式的dependency management配置如下：

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

