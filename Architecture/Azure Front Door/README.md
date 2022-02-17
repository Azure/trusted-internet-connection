# TIC 3.0 Deployment Scenarios for Azure Front Door
## Log Analytics + Automation account (most common deployment scenario)
This is good if you already have applications, VNETs, and an Azure Front Door. This will deploy a Log Analytics workspace and the appropriate automation to send logs to CLAW.

### Requirements
The following must be performed before using this deployment scenario:
- Deployed Azure Front Door
- Deployed Web Application Firewall (WAF) policy
- Associated WAF with Azure Front Door
- Application running in Azure
- Configured restricted access for the Azure Front Door's service.tag using Front Door ID
- Azure Front Door routes traffic to the application so that users must use the Azure Front Door URL or custom FQDN associated with the Azure Front Door to connect to the application

### Deploys and Updates
This deployment scenario will deploy and update the following:
- Deploy Log Analytics workspace
- Deploy Automation Account
- Assign Automation Account's Managed Identity with Log Analytics Reader role to Log Analytics workspace
- Deploy Alert
- Updates Azure Front Door Diagnostic Settings to send logs and metrics to Log Analytics workspace

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Front%2520Door%2FLog%2520Analytics%2520and%2520Automation%2520Account%2Fazuredeploy.json)

![Log Analytics + Automation account](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/149368776-27f1ec73-01e8-4d08-b557-edeff6a3f04e.png)

## Automation account only (common deployment scenario)
This is good if you already have an application, VNET, an Azure Azure Front Door, and are using a Log Analytics workspace for Azure Azure Front Door logs. 

### Requirements
The following must be performed before using this deployment scenario:
- Deployed Virtual Network with subnets for application and an Azure Front Door
- Deployed Azure Front Door
- Deployed Web Application Firewall (WAF) policy
- Associated WAF with Azure Front Door
- Application running in Azure
- Configured restricted access for the Azure Front Door's service.tag using Front Door ID
- Azure Front Door routes traffic to the application so that users must use the Azure Front Door URL or custom FQDN associated with the Azure Front Door to connect to the application
- Deployed Log Analytics workspace
- Configured Azure Front Doors Diagnostic Settings to send logs and metrics to Log Analytics workspace

### Deploys and Updates
This deployment scenario will deploy and update the following:
- Deploy Automation Account
- Assign Automation Account's Managed Identity with Log Analytics Reader role to Log Analytics workspace
- Deploy Alert

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Front%2520Door%2FAutomation%2520Account%2520Only%2Fazuredeploy.json)

![Automation account Only](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/149368956-072ca735-1bb3-4a5a-b429-40f6715f45ae.png)

## Network + Log Analytics + Automation account
This is good if you have an application in Azure and you want to configure it so users can route do it directly in Azure instead from on-premesis through MTIPS/TIC 2.0 solution.

### Requirements
The following must be performed before using this deployment scenario:
- Available IP address in existing Virtual Network
- Defined IP range for Azure Front Door, at minimum /26
- Application running in Azure

### Deploys and Updates
This deployment scenario will deploy and update the following:
- Deploy Azure Front Door
- Deploy Web Application Firewall (WAF) policy
- Associate WAF with Azure Front Door
- Configure restricted access for the Azure Front Door's service.tag using Front Door ID
- Configure Azure Front Door to route traffic to the application so that users must use the Azure Front Door URL to connect to the application. 
-- Custom FQDN must be manually configured and associated with the Azure Front Door, post deployment.
- Deploy Log Analytics workspace
- Configure Azure Front Doors Diagnostic Settings to send logs and metrics to Log Analytics workspace
- Deploy Automation Account
- Assign Automation Account's Managed Identity with Log Analytics Reader role to Log Analytics workspace
- Deploy Alert

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Front%2520Door%2FNetwork%2520with%2520Log%2520Analytics%2520and%2520Automation%2Fazuredeploy.json)

![Network + Log Analytics + Automation](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/149368518-8bdd635d-9e44-4c34-b666-d3d2ad11dd21.png)

## Complete
This is good to for a POC, testing, or to test CISA provided CLAW credentials.

### Requirements
The following must be performed before using this deployment scenario:
- None, solution will deploy as an isolated resource from existing Azure resources.

### Deploys and Updates
This deployment scenario will deploy and update the following:
- Deploy Azure Front Door
- Deploy Web Application Firewall (WAF) policy
- Associate WAF with Azure Front Door
- Deploy App service with default template
- Configure App service with restricted access for the Azure Front Door's service.tag using Front Door ID
- Configure Azure Front Door to route traffic to the application so that users must use the Azure Front Door URL to connect to the application. 
-- Custom FQDN must be manually configured and associated with the Azure Front Door, post deployment.
- Deploy Log Analytics workspace
- Configure Azure Front Doors Diagnostic Settings to send logs and metrics to Log Analytics workspace
- Deploy Automation Account
- Assign Automation Account's Managed Identity with Log Analytics Reader role to Log Analytics workspace
- Deploy Alert

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Front%2520Door%2FComplete%2Fazuredeploy.json)

![Complete Solution](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/149368081-3db55d08-9b04-4ab8-ab12-8b69cd3692c6.png)
