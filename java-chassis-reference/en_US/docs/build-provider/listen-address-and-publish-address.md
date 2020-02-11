# Service listening address and publishing address

### Concept Description

In JavaChassis, the listening address and publishing address of the service are two independent concepts that can be configured independently:

* Listening address: refers to the address that the microservice instance listens to when it starts. This configuration item determines which IPs can be accessed by this IP.
* Publish Address: refers to the address where the microservice instance is registered to the service center. Other microservice instances will obtain information about this instance through the service center and access the service instance based on the publication address, so this configuration item determines which IP other services actually use to access the service.

### Scene Description

The user determines the IP address that the service instance listens to and the IP address requested by other service instances when accessing the instance by configuring the listening address and the publishing address of the service.

### Configuration instructions

The configuration items of the service listening address are `servicecomb.rest.address` and `servicecomb.highway.address`, which respectively correspond to the listening address of the rest transmission mode and the highway transmission mode. The configuration rules for both are the same. The following only uses `servicecomb.rest.address` as an explanation.
The configuration item of the service publishing address is `servicecomb.service.publishAddress`, which can be configured without **. When this item is not configured, JavaChassis will select the publishing address according to the specific rules.

**Table 1 Service Release Address Effective Rules**

| Rule Number | Listening Address Configuration | Publishing Address Configuration | Effective Delivery Address |
| :--- | :--- | :--- | :--- |
| 1 | 127.0.0.1 | - | 127.0.0.1 |
| 2 | 0.0.0.0 | - | Select the IP address of a network card as the publishing address. Require that the address cannot be a wildcard address, loopback address, or broadcast address |
| 3 | Specific IP | - | Consistent with the listening address |
| 4 | * | Specific IP | Consistent with the published address configuration item |
| 5 | * | "{NIC name}" | Specify the IP of the NIC name, note the need to put quotation marks and brackets |
> **Note: **
> - The address actually listened to by the service instance is always consistent with the listening address configuration item.
> - When using the NIC name to configure the publishing address, you need to use double quotation marks to wrap the NIC name placeholder, otherwise the parsing configuration will be reported.
> - The NIC name must be the NIC that the host exists.

### Sample Code

An example of the configuration of the microservice.yaml file is as follows:
```yaml
servicecomb:
  service:
    publishAddress: "{eth0}" # The publishing address, registered to the service center, will be the IP of the eth0 network card
  rest:
    address: 0.0.0.0:8080 # Monitor all NIC IPs of the hos
  highway:
    address: 0.0.0.0:7070 # Listen to all NIC IPs of the host
```