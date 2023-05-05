# TIC 3.0 Deployment Scenarios for Azure Application Gateway
The following solution integrates an Application Gateway with Web Application Firewall (WAF) to manage the traffic into your Azure application environment. The solution includes all resources to generate, collect, and deliver logs to the CLAW. It also includes an app service to highlight the types of telemetry collected by the firewall.



### Requirements
The following must be performed before using this deployment scenario:
- None, solution will deploy as an isolated resource from existing Azure resources.

### Deploys and Updates
- The solution includes:

  - A virtual network with a subnet for the firewall and servers.
  - A Log Analytics workspace.
  - An Application Gateway v2 with Web Application Firewall with Bot and Microsoft managed policies.
  - An Application Gateway v2 diagnostic settings that send logs to the Log Analytics workspace.
  - A registered application
  - An Event Hub
  - An alert rule that sends an email if a job fails.

[![Deploy to Azure](C:\Users\paull\OneDrive\Pictures\Typora\README\trusted-internet-connection-deploy-to-azure-1683287548353-5.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure-Application-Gateway%2FComplete%2Fazuredeploy.json)

[![Deploy to Azure Gov](C:\Users\paull\OneDrive\Pictures\Typora\README\trusted-internet-connection-deploy-to-azure-gov-1683287548353-6.png)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure-Application-Gateway%2FComplete%2Fazuredeploy.json)

![trusted-internet-connections-architecture-AppGwWAF](./Images/trusted-internet-connections-architecture-AppGwWAF.png)
