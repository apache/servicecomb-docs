# Consumer's common configuration

* Request timed out  
  * Configuration  
    servicecomb.request.timeout  
  * Default  
    30000，unit is milliseconds    
  * Description  
    When the Consumer transport layer starts transmitting, it starts timing. If the response is not received within the specified time, the processing is timeout.    
* Designated transmission channel  
  * Configuration  
    servicecomb.references.${target microservice name}.transport  
    servicecomb.references.transport  
    Supports both global and micro-service level two-level control
  * Default  
    none
  * Description  
    If the target micro-service simultaneously opens the access capabilities of multiple transports, and the Consumer also deploys multiple transports at the same time, when the Consumer invokes the micro-service as a Consumer, you only want to use one of the transports, you can specify this configuration  
    If not configured, use multiple transports in turn  
* Specify the version rule for the target instance
  * Configuration  
    servicecomb.references.${target microservice name}.version-rule  
    servicecomb.references.version-rule
    Supports both global and micro-service level two-level control  
  * Default  
    latest
  * Description  
    The version rule for the target instance supports the following rules:  
    * The latest version of： latest  
    * Greater than the specified version, for example: 1.0.0+
    * Specify the version range, for example: 1.0.0-2.0.0, which means greater than or equal to version 1.0.0 and less than version 2.0.0
    * Exact version, for example: 1.0.0
  
