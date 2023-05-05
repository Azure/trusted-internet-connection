# Post-deployment tasks

This repo supports an article on the Azure Architecture Center (AAC) - [Trusted Internet Connection (TIC) 3.0 compliance - Azure Example Scenarios | Microsoft Docs](https://docs.microsoft.com/en-us/azure/architecture/example-scenario/security/trusted-internet-connections), it contains lots of great information on using the content of this repo. Please visit the article in the AAC before proceeding.

Up to now your environment is performing the firewall capabilities and logging connections. To be TIC 3.0 compliant for Network Telemetry collection, those logs must make it to CISA CLAW. The post-deployment steps finish the tasks towards compliance. These steps require coordination with CISA because you will need a certificate from CISA to associate with your Service Principle. 

The following tasks must be performed after deployment is complete. They are manual tasks—an ARM template can't do them.

- Obtain a public key certificate from CISA. 
- Create a Service Principle (App Registration).
- Add the CISA-provided certificate to the App Registration.
- Assign the application with the Azure Event Hubs Data Receiver role to the Event Hub Namespace.

## Detailed Steps

### Obtain a public key certificate from CISA. 

Contact your organizations CISA POC to begin TIC 3.0 compliance.

### Create a Service Principle (App Registration)

[Create an Azure AD app and service principal in the portal - Microsoft Entra | Microsoft Learn](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)

![image-20230505081406197](C:\Users\paull\OneDrive\Pictures\Typora\README\CreateSP-001.png)

1. Select App registrations
2. Select + New registration

![image-20230505081723070](C:\Users\paull\OneDrive\Pictures\Typora\README\image-20230505081723070.png)

3. Provide name for the application, this demo uses TalonReader
4. Select Register

### Add the CISA-provided certificate to the App Registration

![image-20230505082019913](C:\Users\paull\OneDrive\Pictures\Typora\README\image-20230505082019913.png)

1. Select Certificates & secrets
2. Select Certificates
3. Select Upload certificate

![image-20230505082232343](C:\Users\paull\OneDrive\Pictures\Typora\README\image-20230505082232343.png)

4. Select the Browse folder button, use file explorer to find the certificate, and select it
5. Select Add, you will see a status in the upper right of the browser showing when the upload is complete. 

![image-20230505082357990](C:\Users\paull\OneDrive\Pictures\Typora\README\image-20230505082357990.png)

### Assign the application with the Azure Event Hubs Data Receiver role to the Event Hub Namespace

![image-20230505082712131](C:\Users\paull\OneDrive\Pictures\Typora\README\image-20230505082712131.png)

1. Navigate to your Event Hub Namespace used for TIC 3.0 TALON access.
2. Select Access control (IAM)
3. Select + Add
4. Select Add role assignment

![image-20230505082940366](C:\Users\paull\OneDrive\Pictures\Typora\README\image-20230505082940366.png)

5. Search for Azure Event Hubs Data Receiver
6. Select Azure Event Hubs Data Receiver
7. Select Next

![image-20230505083150288](C:\Users\paull\OneDrive\Pictures\Typora\README\image-20230505083150288.png)

8. Select User, group, or service principal
9. Select + Select members
10. Search for TalonReader, or which ever name you used when you created the service principal in previous step
11. Select TalonReader
12. Select Select

![image-20230505083358905](C:\Users\paull\OneDrive\Pictures\Typora\README\image-20230505083358905.png)

13. Select Review + assign, twice

### Azure Complete

All Azure tasks are complete.

## Feed Activation

Send the following information to CISA:

1. Azure tenant ID
2. Application (client) ID of TalonReader or which ever application you created
3. Event Hub Namespace name
4. Event Hub name
5. Consumer group name
   1. For this guide, the name of the consumer group is $Default

CISA will confirm when TALON is ready. CISA will confirm successful receipt of the logs or initiate troubleshooting steps.