# Using Contracts
## Scenario

When a consumer calls a service from a provider, the contract is required. The consumer can get the providers' contracts in 2 ways: get the providers' contract from off-line, then manually configure it in the  project. Or, download the contract from the service center.

## Configuration

> NOTE
>
> Users can get the contract in either way, regardless of the consumers' development mode.

## Configure the Dependencies

In the microservice.yaml file, configure a provider for the consumer. The following is an example of the configuration:

```yaml
servicecomb:
  # other configurations omitted
  references:
    springmvc:
      version-rule: 0.0.1
```

> The version-rule field is the rules to match the version, there are 4 version-rule formats:
>
> * Accurate version: such as `version-rule: 0.0.1`, it indicates that only those  providers with version 0.0.1 are matched.
> * Later versions: such as `version-rule: 1.0.0+`, it indicates that those providers with version greater than 1.0.0 are matched.
> * Latest version: `version-rule: latest`, it indicates that only  those providers with the latest are matched.
> * Version range: such as`1.0.0-2.0.2`,  it indicates that those provider with versions between 1.0.0 and 2.0.2 are matched, including 1.0.0 and 2.0.2
>
> The default version matching rule is `latest`.

### Manually Configure Contracts

When providers' contracts are obtained from off-line,  they should be put into the specific directory of the consumer project. The directory is the one mentioned in the configuration description [Service Contract](../build-provider/define-contract.md).

Each directory under the microservices directory indicates a microservice, and each yaml file under the microservice directory represents a contract schema. The file name is the schemaId. The contracts stored in application folder should specify the appId for cross application access. The directory tree is as follows:

```txt
resources
  - microservices
      - serviceName            # Microservice name
          - schemaId.yaml      # The contract schemaId
  - applications
      - appId                  # Application ID
          - serviceName        # Microservice name
              - schemaId.yaml  # The contract schemaId
```

### Automatically Download Contract from Service Center

If a consumer does not explicitly store the contract in the project, when the application starts, ServiceComb framework automatically downloads contracts from the service center based on the providers' microservices name and version configured in microservice.yaml.
