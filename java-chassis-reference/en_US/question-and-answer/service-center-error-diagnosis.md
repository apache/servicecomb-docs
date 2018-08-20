Developers can directly use the service center provided by Huawei Public Cloud for development work. To use the service center, the developer needs to register the Huawei cloud account and generate AK/SK information in "My Credentials" for access to the authentication control. For details on how to access Huawei cloud, see "[Huawei Public Cloud Deployment] (/start/deployment-on-cloud.md)."

This chapter focuses on some common anomalies in the Connection Service Center and their Troubleshooting method.

# \#1

* Exception message

{"errorCode":"401002","errorMessage":"Request unauthorized","detail":"Invalid request, header is invalid, ak sk or project is empty."}

* Reason of problem

AK, SK is not set correctly and carried into the request header.

* Troubleshooting method

Check if the following authentication modules are used in the project. (Indirect dependencies are also possible, such as relying on cse-solution-service-engine\)

```
<groupId>com.huawei.paas.cse</groupId>
<artifactId>foundation-auth</artifactId>
```

Check if the ak/sk configuration in microservice.yaml is correct, whether the accessKey and secretKey are filled in incorrectly, and the length of the secretKey is longer than the accessKey.

```
servicecomb:
  credentials:
    accessKey: your access key
    secretKey: your serect key
    akskCustomCipher: default
```

You can log in to Huawei Cloud and query the accessKey information in "My Credentials". The secretKey is saved by the user and cannot be queried. If you forget the relevant credentials, you can delete the voucher information and generate new voucher information.

# \#2

* Exception message

{"errorCode":"401002","errorMessage":"Request unauthorized","detail":"Get service token from iam proxy failed,{\"error\":\"validate ak sk error\"}"}

* Reason of problem

AK, SK are not correct.

* Troubleshooting method

Check if the ak/sk configuration in microservice.yaml is correct. You can log in to Huawei Cloud and query the accessKey information in "My Credentials". The secretKey is saved by the user and cannot be queried. If you forget the relevant credentials, you can delete the voucher information and generate new voucher information.

# \#3

* Exception message

{"errorCode":"401002","errorMessage":"Request unauthorized","detail":"Get service token from iam proxy failed,{\"error\":\"get project token from iam failed. error:http post failed, statuscode: 400\"}"}

* Reason of problem

The Project name is incorrect.

* Troubleshooting method

Check if the value of the configuration item servicecomb.credentials.project is correct, and query the correct Project name in "My Credentials". If there is no such configuration item, the default will be based on the domain name of the service center. When the domain name does not contain a legal Project name, you need to add this configuration item to ensure that its name is the legal Project name in "My Credentials".

# \#4

* Exception message

{"errorCode":"400001","errorMessage":"Invalid parameter\(s\)","detail":"Version validate failed, rule: {Length: 64,Length: ^\[a-zA-Z0-9\_

[\\-.\]\*$}](\\-.]*$})

"}

* Reason of problem

Use the new version of the SDK to connect to an older version of the Service Center.

* Troubleshooting method

Check the version of the service center. You can download the latest version of the service center from the Huawei Cloud official website, or download the latest version of the service center from ServiceComb's official website.