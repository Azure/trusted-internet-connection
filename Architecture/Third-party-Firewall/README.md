# TIC 3.0 Compliant Guidance using Third-party Firewall aka Network Virtual Appliance
> [!NOTE]
> This solution does not have a Deploy to Azure capability and is meant for guidance only.

The following solution defines how a Third-party firewall can be used to manage the traffic into your Azure application environment and support TIC 3.0 compliance. Third-party firewalls require use of a Syslog forwarder virtual machine, usually Linux-based, with its agents registered with the Log Analytics workspace. The Third-party firewall is configured to export its logs in syslog format to the Syslog forwarder virtual machine and the agent is configured to send its logs to the Log Analytics workspace. Once the logs are in the Log Analytics workspace they are sent to the Event hub and processed like the other solutions outlined in this article.

![TIC 3.0 compliance using Azure Firewall and Application Service](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/trusted-internet-connections-architecture-NVA.png)

### Post-deployment tasks for all solutions

Up to now your environment is performing the firewall capabilities and logging connections. To be TIC 3.0 compliant for Network Telemetry collection, those logs must make it to CISA CLAW. The post-deployment steps finish the tasks towards compliance. These steps require coordination with CISA because you will need a certificate from CISA to associate with your Service Principle. For step-by-step details see [Post Deployment Tasks](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post Deployment Tasks).

The following tasks must be performed after deployment is complete. They are manual tasks—an ARM template can't do them.

- Obtain a public key certificate from CISA. 
- Create a Service Principle (App Registration).
- Add the CISA-provided certificate to the App Registration.
- Assign the application with the Azure Event Hubs Data Receiver role to the Event Hub Namespace.