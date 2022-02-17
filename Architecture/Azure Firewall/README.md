# TIC 3.0 Deployment Scenarios for Azure Firewall
## Log Analytics + Automation account (most common deployment scenario)
This is good if you already have applications, VNETs, and an Azure Firewall. This will deploy a Log Analytics workspace and the appropriate automation to send logs to CLAW.

### Requirements
The following must be performed before using this deployment scenario:
- Deployed Virtual Network with subnets for application and an Azure Firewall
- Deployed Azure Firewall
- Deployed Firewall policy
- Associated Firewall policy with Azure Firewall
- Application running in Azure
- Azure Firewall routes traffic to the application so that users must use a URL associated with the public IP of the Azure Firewall to connect to the application

### Deploys and Updates
This deployment scenario will deploy and update the following:
- Deploy Log Analytics workspace
- Deploy Automation Account
- Assign Automation Account's Managed Identity with Log Analytics Reader role to Log Analytics workspace
- Deploy Alert
- Updates Azure Firewall Diagnostic Settings to send logs and metrics to Log Analytics workspace

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Firewall%2FLog%2520Analytics%2520and%2520Automation%2520Account%2Fazuredeploy.json)

![Log Analytics + Automation account](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/149368776-27f1ec73-01e8-4d08-b557-edeff6a3f04e.png)

## Automation account only (common deployment scenario)

### Requirements
The following must be performed before using this deployment scenario:
- Deployed Virtual Network with subnets for application and an Azure Firewall
- Deployed Azure Firewall
- Deployed Firewall policy
- Associated Firewall policy with Azure Firewall
- Application running in Azure
- Configured restricted access for the Azure Firewall's subnet
- Azure Firewall routes traffic to the application so that users must use a URL associated with the public IP of the Azure Firewall to connect to the application
- Configured Azure Firewall Diagnostic Settings to send logs and metrics to Log Analytics workspace

### Deploys and Updates
This deployment scenario will deploy and update the following:
- Deploy Automation Account
- Assign Automation Account's Managed Identity with Log Analytics Reader role to Log Analytics workspace
- Deploy Alert

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Firewall%2FAutomation%2520Account%2520Only%2Fazuredeploy.json)

![Automation account Only](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/149368956-072ca735-1bb3-4a5a-b429-40f6715f45ae.png)

## Network + Log Analytics + Automation account
This is good if you have an application in Azure and you want to configure it so users can route do it directly in Azure instead from on-premesis through MTIPS/TIC 2.0 solution.

### Requirements
The following must be performed before using this deployment scenario:
- Deployed Virtual Network with subnet for application
- Available IP address in existing Virtual Network
- Defined IP range for Azure Firewall, at minimum /26
- Application running in Azure

### Deploys and Updates
This deployment scenario will deploy and update the following:
- Deploy subnet for Azure Firewall
- Deploy Azure Firewall
- Deployed Firewall policy
- Associated Firewall policy with Azure Firewall
- Configure restricted access for the Azure Firewall's subnet
- Azure Firewall routes traffic to the application so that users must use a URL associated with the public IP of the Azure Firewall to connect to the application
- Deploy Log Analytics workspace
- Configure Azure Firewall Diagnostic Settings to send logs and metrics to Log Analytics workspace
- Deploy Automation Account
- Assign Automation Account's Managed Identity with Log Analytics Reader role to Log Analytics workspace
- Deploy Alert

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Firewall%2FNetwork%2520with%2520Log%2520Analytics%2520and%2520Automation%2Fazuredeploy.json)

![Network + Log Analytics + Automation](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/149368518-8bdd635d-9e44-4c34-b666-d3d2ad11dd21.png)

## Complete
This is good to for a POC, testing, or to test CISA provided CLAW credentials.

### Requirements
The following must be performed before using this deployment scenario:
- None, solution will deploy as an isolated resource from existing Azure resources.

### Deploys and Updates
This deployment scenario will deploy and update the following:
- Deploy Virtual Network with subnet for application and an Azure Firewall
- Deploy subnet for Azure Firewall
- Deploy Firewall policy
- Associate Firewall policy with Azure Firewall
- Associate WAF with Azure Firewall
- Deploy App service with default template
- Configure App service with restricted access for the Azure Firewall's subnet
- Configure Azure Firewall to route traffic to the application so that users must use a URL associated with the public IP of the Azure Firewall to connect to the application
- Deploy Log Analytics workspace
- Configure Azure Firewall Diagnostic Settings to send logs and metrics to Log Analytics workspace
- Deploy Automation Account
- Assign Automation Account's Managed Identity with Log Analytics Reader role to Log Analytics workspace
- Deploy Alert
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Firewall%2FComplete%2Fazuredeploy.json)

![Complete Solution](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/149368081-3db55d08-9b04-4ab8-ab12-8b69cd3692c6.png)
