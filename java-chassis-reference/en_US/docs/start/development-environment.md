# Prepare the local development environment

JDK, Maven, Eclipse, and IDEA is required. If you already have these development tools installed, skip this section.

## JDK version and installation steps

1.JDK version

The JDK version requires 1.8 or higher.

2.JDK download

Please go to the official address of JDK version 1.8 to download.

3.JDK installation

After downloading the JDK installation package on the official website, select the appropriate installation path to install the JDK.

Here is the windows system as an example:

Set the JAVA\_HOME environment variable to point to the Java installation directory. Add %JAVA\_HOME%\bin to the system path path. After the environment variable is configured, use the java -version command to verify whether the installation is successful. The windows environment is echoed as follows:

```
C:\> java -version      
 java version "1.8.0_121"      
 Java(TM) SE Runtime Environment (build 1.8.0_121-b13)      
 Java HotSpot(TM) 64-Bit Server VM (build 25.121-b13, mixed mode)
```

## Maven installation steps

Maven is a development tool that integrates project management, code compilation and more.

### **Prerequisites**

The JDK has been installed successfully.

### **installation steps**

* Download the Maven installation package at the official address.
* Unzip the Maven installation package to the native path.
* Set environment variables：
  * Set the M2\_HOME environment variable to point to the Maven installation directory.
  * Add %M2\_HOME%\bin to the system path path.
* Verification

  Use the mvn -version command to verify that the installation is successful. The windows environment 
  is echoed as follows:

        C:\>mvn -version        
        Apache Maven 3.3.9

## Eclipse installation

### **Prerequisites**

a.JDK has been installed.

b.Maven is already installed.

### **installation steps**

a. Download the Eclipse installation package at the official address.

b. Install Eclipse to the machine.

c. (Optional) Extract the plugin m2eclipse described in the previous Maven installation to the plugins and features directory in the Eclipse installation directory. The latest Eclipse version

With the Maven plugin, don't do this

d. Start Eclipse, configure jre, maven settings, and the default encoding format is utf-8.



## IDEA installation

### **Prerequisites**

a.JDK has been installed.

b.Maven is already installed.

### **installation steps**

a. Download the IDEA installation package on the official website, the paid version or the community version according to individual needs.

b. Set the encoding format to utf-8.

Open IDEA and select File -> Settings -> Editor -> File Encoding
Change project Encoding and default encoding for properties files to utf-8.

c. Set up maven configuration

Open IDEA and select File -> Settings -> Build, Execution, Deployment -> Bulid Tools -> Maven
Note configuring Maven home directory and User settings file
