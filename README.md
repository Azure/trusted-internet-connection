# Trusted Internet Connection (TIC) 3.0 compliance for internet facing applications 
Deliver Trusted Internet Connection (TIC) 3.0 compliance and improve end user experience with your internet facing Azure applications and services. The architectures and resources provided guides government organizations towards TIC 3.0 compliance by directly deploying the required assets or show how to incorporate the solution into an existing architecture. End user performance will improve as users will directly access the Azure application or service instead of being routed to a TIC 2.0+ Managed Trusted Internet Protocol Service (MTIPS) device then to Azure.  

The common component for each of the solutions outlined in this article is an Azure Automation account leveraging a Service Principle to collect inbound traffic logs from the firewall and sending those logs to the Cybersecurity and Infrastructure Security Agency (CISA) provisioned Cloud Log Aggregation Warehouse (CLAW).

## Potential use cases

Federal organizations and government agencies are the most likely use case for implementing TIC 3.0 compliance solutions for the Azure applications and services. TIC 3.0 matures data collection from the on-premises only into a cloud forward approach that better supports how modern organization IT is utilized. The CISA CLAW is a maturation of the EINSTEIN on-premises data collection model geared towards cloud environments. CISA wants to "improve performance, reduce costs, and enhance threat discovery and incident  responsiveness for agencies". 

- [TIC 3.0 Core Guidance Documents | CISA](https://www.cisa.gov/publication/tic-30-core-guidance-documents)
- [National Cybersecurity Protection System Documents (NCPS) | CISA](https://www.cisa.gov/publication/national-cybersecurity-protection-system-documents)
- [EINSTEIN | CISA](https://www.cisa.gov/einstein)
- [Managed Trusted Internet Protocol Service (MTIPS) | GSA](https://www.gsa.gov/technology/technology-products-services/it-security/trusted-internet-connections-tics)

*Microsoft provides this information to Federal Civilian Executive Branch (FCEB) departments and agencies as part of a suggested configuration to facilitate participation in CISA’s CLAW capability. This suggested configuration is maintained by Microsoft and is subject to change.*

### Supported CLAW Destinations

CISA's initial CLAW destination leverages Amazon S3 as the storage mechanism. As such, this solution supports S3. When CISA deploys CLAW support running in Azure, this solution will update to send logs to Azure-based CLAW.

## Architecture

Architecture solutions are defined by three categories: Azure firewall and third-party firewalls. Azure firewall send logs to a Log Analytics workspace using the diagnostic settings configuration native to Azure. Third-party firewalls send logs using the vendors syslog export feature. For the purpose of this guide, the Palo Alto network virtual appliance (NVA), running in Azure, will be used for the tutorial on how to export logs in syslog format to the Log Analytics workspace.

*Figure 1. TIC 3.0 Compliant Architecture with Firewall Uploading Logs to CLAW*

![TIC 3.0 Compliance Architecture with Azure Firewall Uploading Logs to CLAW](https://user-images.githubusercontent.com/34814295/149363613-420efd44-bf76-41cd-8fd0-d597a1f3cf0d.png)

### Components

#### Azure Firewall

1. Firewall
   1. This can be a native Azure firewall or a third-party firewall appliance.
   2. The firewall will enforce policies, collect metrics, and log connection transactions between users and services accessing the web services.
   3. ARM template for native Azure firewall (premium) provided to simplify deployment.
      1. Premium is utilized as it provides Intrusion Detection System (IDS) capabilities.
2. Firewall Logs
   1. The Azure firewall will send logs using Azure Diagnostic settings to an Azure Log Analytics workspace.
      1. Azure Automation will collect and deliver Azure Firewall traffic and IDS logs.
   2. Third-party firewalls will send logs in syslog format to the Azure Log Analytics workspace.
      1. Azure Automation can collect and deliver third-party logs, instructions provided.
3. Log Analytics Workspace
   1. Repository for the collection of logs.
   2. Provides a service for the organization to perform their own analysis on the network traffic along side its delivery to the CLAW.
   3. ARM template provided to simplify deployment.
4. Azure Automation
   1. Executes every 60 minutes.
   2. Sends logs in json format to CLAW.
   3. Automation ARM template and script code provided to simplify deployment.
   4. Encrypted variables simplifies operational management of updating rotating secrets.
5. Cloud Log Aggregation Warehouse (CLAW)
   1. Supports AWS S3 bucket.
   2. Requires coordination with CISA for access key and secret key.
6. Azure Active Directory
   1. Authentication and Access Logs can be sent to the LAW using Diagnostic settings.
   2. Instructions on how to setup Azure AD Diagnostic settings logging provided.
   3. Azure Automation can collect and deliver Sign-in logs, [instructions provided](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#send-azure-ad-logs-to-log-analytics-workspace).
7. Application Gateway
   1. Logs can be sent to the LAW.
8. Load Balancer
   1. Logs can be sent to the LAW.
9. Network Security Groups
   1. NetFlow logs can be sent to the LAW.
   2. Diagnostic settings logs can be sent to the LAW.
   3. Instructions on how to setup NetFlow logging provided.
   4. Azure Automation can collect and deliver NetFlow logs, [instructions provided](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#send-netflow-logs-to-log-analytics-workspace).

### Alternatives

Instead of using an Automation Account to query Log Analytics workspace, format the data into JSON, and upload it to the S3 bucket, the organization could develop their own Azure Function to perform the same task. This may be useful for an organization with software developers integrated into operations and are more familiar with C# or are heavily utilizing Azure Functions today.

## Considerations

Deciding which architecture and resources to deploy, depends on what architecture the government organization has in place today. The following criteria may assist with deciding which solution to deploy.

### Firewalls

- If the organization wants to test using an Automation account, then deploy the [Complete](https://github.com/Azure/trusted-internet-connection#complete) solution to a test/dev environment.
- If the organization has an application in Azure that is routed back on-premises and have not deployed a firewall in Azure, then deploy the [Network + Log Analytics + Automation](https://github.com/Azure/trusted-internet-connection#network--log-analytics--automation-account).
- If the organization has an Azure firewall deployed and are routing the application through the Azure firewall back to on-premises, then deploy the [Log Analytics + Automation account](https://github.com/Azure/trusted-internet-connection#log-analytics--automation-account).
- If the organization is using a Log Analytics workspace, along with an Azure firewall deployed and are routing the application through the Azure firewall back to on-premises [Automation account only](https://github.com/Azure/trusted-internet-connection#automation-account-only).

## Deploy this scenario

### Requirements for all solutions

For step by step details visit [Prerequisite tasks](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Prerequisite%20Tasks)

You must have the following before deployment:

- Resource Group.
- Register an Enterprise application.
  - This will be used to provide reader access to Log Analytics workspace (LAW).
- Create Secret for Enterprise application.

Though you can deploy all of the Azure resources, to actually send log data to a CISA CLAW to support the TIC 3.0 compliance you will need the following: 

- Request CISA provide S3 bucket access key, secret, and S3 bucket name.
- Collect Tenant ID.

### Post deployment tasks for all solutions

For step by step details visit [Post deployment](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks) tasks

The following needs to be performed once deployment is complete. These are the tasks that an ARM template cannot perform and requires some manual effort. 

- Add enterprise application with reader role to Log Analytics workspace (LAW).
- Link schedule to runbook.
- Update Automation account variables with your unique values 
  - CISA provided CLAW S3 access key
  - CISA provided CLAW S3 access secret
  - Unique S3 bucket name
  - Log Analytics workspace ID
  - Tenant ID
  - Enterprise application ID
  - Enterprise application secret

### Upload to CLAW runbook

For more details and to view the runbook visit [UploadToCLAW-S3](https://github.com/Azure/trusted-internet-connection/blob/main/Runbook/UploadToCLAW-S3.ps1)

The Automation account runs a PowerShell-based Runbook to query the Log Analytics workspace, format the data into a JSON, and stream it to the CLAW. The reason for using stream is to break it down into small chunks to reduce the performance impact of reading large files at once. Reading the data from a 250 mb file before uploading it may cause the process to fail. AWSPowerShell tools are used to connect to the S3 bucket and upload the JSON data into a datatime.json file.

The runbook uses encrypted Automation account variables to simplify initial configuration and ongoing maintenance. Once the organziation deploys the Automation account, the runbook will not need modification. Administrators will perform the initial configuration by updating the values of each variable (See [Prerequisite tasks](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Prerequisite%20Tasks)). When the CLAW S3 secret and enterprise application secret are rotated, the administrators only need to update the appropriate variable. 

#### Alerting

An Azure alert is deployed and configured to send an failure email notification, to the email(s) defined at deployment. The notification informs the organization when the runbook fails. Administrators can dig into the runbook history for more details on why the runbook failed.


### Azure firewall supported solutions

The following solutions leverage the native Azure firewall for inbound traffic management into your Azure application environment. Select your solution based on the maturity of your Azure environment. Organizations with an Azure firewall and Log Analytics workspace should use Automation account Only solution.

1. [Complete](https://github.com/Azure/trusted-internet-connection#complete)
   1. Includes all resources and a virtual machine to generate internet-bound traffic.
2. [Network + Log Analytics + Automation](https://github.com/Azure/trusted-internet-connection#network--log-analytics--automation-account)
   1. This includes all Azure resources for the network, logging, automation, and alerting. Does NOT include a virtual machine.

3. [Log Analytics + Automation account](https://github.com/Azure/trusted-internet-connection#log-analytics--automation-account)
   1. This is good if you already have VNETs, firewalls, and route table/route server. Includes alerting.
4. [Automation account only](https://github.com/Azure/trusted-internet-connection#automation-account-only)
   1. This is good if you already have networks and are using a centralized Log Analytics workspace. Includes alerting.

#### Complete

Deploys all resources to generate, collect, and deliver logs to CLAW. Includes virtual machine to generate internet-bound traffic. 

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Firewall%2FComplete%2Fazuredeploy.json)

 Solution includes the following:

- VNET with subnet for firewall and servers.
- Log Analytics workspace.
- Azure firewall with network policy for internet access.
- Configures Azure firewall diagnostic settings to send logs to Log Analytics workspace.
- Route table to route servers to firewall for internet access.
- Automation account with published runbook, schedule, and required AWSPowerShell module.
- Alert on failed jobs will trigger email.
- Storage account.
- Virtual machine on the server subnet to generate internet-bound traffic.

![Complete Solution](https://user-images.githubusercontent.com/34814295/149368081-3db55d08-9b04-4ab8-ab12-8b69cd3692c6.png)

#### Network + Log Analytics + Automation account

Deploys all Azure resources for the network, logging, and automation. Does NOT include a virtual machine. You can complete this setup, tailor firewall policies for your envrionment, and have external users connecting to your Azure application or service. Application traffic will be collected and sent to the CLAW.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Firewall%2FNetwork%2520with%2520Log%2520Analytics%2520and%2520Automation%2Fazuredeploy.json)

 Solution includes the following:

- VNET with subnet for firewall and servers.
- Log Analytics workspace.
- Azure firewall with network policy for internet access.
- Configures Azure firewall diagnostic settings to send logs to Log Analytics workspace.
- Route table to route servers to firewall for internet access.
- Automation account with published runbook, schedule, and required AWSPowerShell module.
- Alert on failed jobs will trigger email.
- Storage account.

![Network + Log Analytics + Automation](https://user-images.githubusercontent.com/34814295/149368518-8bdd635d-9e44-4c34-b666-d3d2ad11dd21.png)

#### Log Analytics + Automation account

This is good if you already have VNETs, firewalls, and route table/route server. You may have the firewall in place today and traffic is routed from a TIC 2.0+ MTIPS device to your application gateway in azure. You can keep that solution in place while you confirm the Azure firewalls logs are collected and uploaded to the CLAW. Then update your routing so that your external users no longer utilized the MTIPS device but routed directly to the Azure firewall.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Firewall%2FLog%2520Analytics%2520and%2520Automation%2520Account%2Fazuredeploy.json)

Solution includes the following:

- Log Analytics workspace.
- Configures Azure firewall diagnostic settings to send logs to Log Analytics workspace.
- Automation account with published runbook, schedule, and required AWSPowerShell module.
- Alert on failed jobs will trigger email.
- Storage account.

![Log Analytics + Automation account](https://user-images.githubusercontent.com/34814295/149368776-27f1ec73-01e8-4d08-b557-edeff6a3f04e.png)

#### Automation account only

This is good if you already have networks, an Azure firewall, and are using a centralized Log Analytics workspace. 

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Firewall%2FAutomation%2520Account%2520Only%2Fazuredeploy.json)

Solution includes the following

- Configures Azure firewall diagnostic settings to send logs to Log Analytics workspace.
- Automation account with published runbook, schedule, and required AWSPowerShell module.
- Alert on failed jobs will trigger email.
- Storage account.

![Automation account Only](https://user-images.githubusercontent.com/34814295/149368956-072ca735-1bb3-4a5a-b429-40f6715f45ae.png)

## Pricing

The cost of each solution scales down as they leverage more existing resources. The following pricing is based on the default settings of the Complete solution. Altering the configuration may increase costs. Ingesting more logs with a pay-per-gb plan will increase costs.

- Complete
  - [Azure pricing calculator example scenario](https://azure.com/e/72ac82bc9b8d4073bb730b65aa372bc5)


NOTE: Consult [Azure Pricing calculator](https://azure.microsoft.com/en-us/pricing/calculator/) for up-to-date pricing based on the resources deployed for the selected solution.

## Next Steps

Evaluate your current architecture to determine which solution best upgrades what you have today to support your TIC 3.0 compliance. -

- Contact your CISA representative to request a CLAW storage solution. 
- Review the [prerequisite](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Prerequisite%20Tasks) and [post deployment](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks) tasks. 
- Use the Deploy the Azure button and deploy one or more of the solutions to a test environment to become familiar with the process and the deployed resources.
  - [Deploy this scenario](https://github.com/Azure/trusted-internet-connection#deploy-this-scenario)
- Evaluate Azure firewall routing 
  - [Deploy & configure Azure Firewall using the Azure portal | Microsoft Docs](https://docs.microsoft.com/en-us/azure/firewall/tutorial-firewall-deploy-portal)

## Related Resources

- [Azure Automation overview | Microsoft Docs](https://docs.microsoft.com/en-us/azure/automation/overview)
- [What is Azure Firewall? | Microsoft Docs](https://docs.microsoft.com/en-us/azure/firewall/overview)
- [Overview of Log Analytics in Azure Monitor - Azure Monitor | Microsoft Docs](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview)
- [Overview of alerting and notification monitoring in Azure - Azure Monitor | Microsoft Docs](https://docs.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview)
- [Apps & service principals in Azure AD - Microsoft identity platform | Microsoft Docs](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals)
- [Create an Azure AD app and service principal in the portal - Microsoft identity platform | Microsoft Docs](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-porta)
- [Register your app with the Azure AD v2.0 endpoint - Microsoft Graph | Microsoft Docs](https://docs.microsoft.com/en-us/graph/auth-register-app-v2)
- [Assign Azure roles using the Azure portal - Azure RBAC | Microsoft Docs](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)
- [Manage runbooks in Azure Automation | Microsoft Docs](https://docs.microsoft.com/en-us/azure/automation/manage-runbooks#schedule-a-runbook-in-the-azure-portal)
- [Manage resource groups - Azure portal - Azure Resource Manager | Microsoft Docs](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#create-resource-groups)
- [How to find your tenant ID - Azure Active Directory | Microsoft Docs](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-to-find-tenant)
- [Collect Syslog data sources with Log Analytics agent in Azure Monitor - Azure Monitor | Microsoft Docs](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/data-sources-syslog)
- [Parse text data in Azure Monitor logs - Azure Monitor | Microsoft Docs](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/parse-text)
- [Introduction to flow logging for NSGs - Azure Network Watcher | Microsoft Docs](https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview)

