# Trusted Internet Connection (TIC) 3.0 compliance for internet facing applications 
Deliver Trusted Internet Connection (TIC) 3.0 compliance and improve end user experience with your internet facing Azure applications and services. The architectures and resources provided guides government organizations towards TIC 3.0 compliance by directly deploying the required assets or show how to incorporate the solution into an existing architecture. End user performance will improve as users will directly access the Azure application or service instead of being routed to a TIC 2.0+ Managed Trusted Internet Protocol Service (MTIPS) device then to Azure.  

The common component for each of the solutions outlined in this article is an Azure Automation account leveraging a Service Principle to collect inbound traffic logs from the firewall and sending those logs to the Cybersecurity and Infrastructure Security Agency (CISA) provisioned Cloud Log Aggregation Warehouse (CLAW).

## Potential use cases

Federal organizations and government agencies are the most likely use case for implementing TIC 3.0 compliance solutions for their web applications and API services deployed in Azure. TIC 3.0 matures data collection from the on-premises only into a cloud forward approach that better supports how modern organization IT is utilized. The CISA CLAW is a maturation of the EINSTEIN on-premises data collection model geared towards cloud environments. CISA aims to "improve performance, reduce costs, and enhance threat discovery and incident  responsiveness for agencies". 

- [TIC 3.0 Core Guidance Documents | CISA](https://www.cisa.gov/publication/tic-30-core-guidance-documents)
- [National Cybersecurity Protection System Documents (NCPS) | CISA](https://www.cisa.gov/publication/national-cybersecurity-protection-system-documents)
- [EINSTEIN | CISA](https://www.cisa.gov/einstein)
- [Managed Trusted Internet Protocol Service (MTIPS) | GSA](https://www.gsa.gov/technology/technology-products-services/it-security/trusted-internet-connections-tics)

*Microsoft provides this information to Federal Civilian Executive Branch (FCEB) departments and agencies as part of a suggested configuration to facilitate participation in CISA’s CLAW capability. This suggested configuration is maintained by Microsoft and is subject to change.*

### Supported CLAW Destinations

As of Q1 2022, CISA's CLAW only resides in an Amazon S3 bucket. This means that all TIC 3.0 compliant logs collected in Azure are transmitted to a CISA owned Amazon S3 bucket. This solution supports that storage destination. When an Azure-based CISA owned storage option is available, this solution will update to support saving TIC 3.0 compliant logs to the Azure storage destination.

## Architecture

Architecture solutions are defined by two categories, Azure Firewall and third-party firewalls. Azure Firewall is natively configured to send logs to a Log Analytics workspace while third-party firewalls typically send logs to a Log Analytics workspace using the vendors' syslog export feature. For the purpose of this guide, the Palo Alto network virtual appliance (NVA), running in Azure, will be used for the tutorial on how to export logs in syslog format to the Log Analytics workspace.

*Figure 1. TIC 3.0 Compliant Architecture with Firewall Uploading Logs to CLAW*

![TIC 3.0 Compliance Architecture with Azure Firewall Uploading Logs to CLAW](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/144664138-4aaf0edb-6679-448d-a6b8-b147edb10945.png)

### Components

#### Firewall

1. Firewall
   - This can be a native Azure Firewall or a third-party firewall appliance.
   - The firewall will enforce policies, collect metrics, and log connection transactions between users and services accessing the web services.
   - Firewall policy premium is utilized as it provides Intrusion Detection and Prevent System (IDPS) capabilities.
2. Firewall Logs
   - The Azure Firewall will send logs using Azure Diagnostic settings to an Azure Log Analytics workspace.
   - Third-party firewalls will send logs in syslog format to the Azure Log Analytics workspace.
3. Log Analytics Workspace
   - Repository for the collection of logs.
   - Provides a service for the organization to perform their own analysis on the network traffic along side its delivery to the CLAW.
4. Azure Automation
   - Executes every 60 minutes and queries Log Analytics workspace for Azure Firewall traffic and IDPS logs that were generated over the last 60 minutes.
   - Collected logs are uploaded to CLAW.
   - Leverages encrypted variables component of Azure Automation to store values for the runbook to  connect to the Log Analytics workspace and the CLAW storage.
5. Cloud Log Aggregation Warehouse (CLAW)
   - Supports AWS S3 bucket.
   - Requires coordination with CISA.
6. Azure Active Directory (AD)
   - Access and sign-in logs can be sent to the Log Analytics workspace using Azure Diagnostic settings in Azure AD.
7. Application Gateway, with access and web application firewall logs flowing to the shared Log Analytics workspace.
8. Load Balancer, with logs flowing to the shared Log Analytics workspace.
9. Network Security Groups, with logs flowing to the shared Log Analytics workspace.

### Alternatives

Instead of using an Automation Account to query Log Analytics workspace, format the data into JSON, and upload it to the S3 bucket, the organization could develop their own Azure Function to perform the same task. This may be useful for an organization with software developers integrated into operations and are more familiar with developer languages or are heavily utilizing Azure Functions today.

## Considerations

### Availability

### Operational excellence

- [Azure Alerts](https://docs.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview)  is built into the solution to notify the organization when an upload fails to deliver logs to the CLAW. It is up to the organization to determine the severity of this alert and how to respond. 
- Use ARM templates to speed up the deployment of additional TIC 3.0 architectures for new applications. 

### Performance

- Azure Firewall [performance](https://docs.microsoft.com/en-us/azure/firewall/firewall-performance) scales as usage increases. If additional performance is required , Azure Premium provides performance boost which increases single TCP connections and max bandwidth.

### Reliability

- Azure Firewall Standard and Premium integrate with availability zones to increase service level agreement percentages.
- Utilize regional services paired with load balancing services like Front Door to improve reliability and resiliency.

### Security

- Registering enterprise applications creates a service principle, follow naming schemes to quickly understand the purpose of your service principles.
- Perform audits to determine activity of service principles and status of service principle owners.
- Azure Firewall has standard policies, start with those and build organization policies over time based on industry requirements, best practices, and government regulations.

## Deploy this scenario

### Requirements for all solutions

For step by step details visit [Prerequisite tasks](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Prerequisite%20Tasks)

You must have the following before deployment:

- Resource Group.
- Register an application.
- Create secret for a registered application.

Though you can deploy all of the Azure resources, to actually send log data to a CISA CLAW to support the TIC 3.0 compliance you will need the following: 

- Request CISA provide S3 bucket access key, secret, S3 bucket name, and network line-of-sight.
- Collect Tenant ID.

### Post deployment tasks for all solutions

For step by step details visit [Post deployment](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks) tasks

The following needs to be performed once deployment is complete. These are the tasks that an ARM template cannot perform and requires some manual effort. 

- Register an application with reader role to Log Analytics workspace.
- Link schedule to runbook.
- Update Automation account variables.


### Azure Firewall supported solutions

The following solutions leverage the native Azure Firewall for inbound traffic management into your Azure application environment. Select your solution based on the topology of your Azure environment. Organizations with an Azure Firewall and Log Analytics workspace should use "Automation account only" solution.

1. [Complete](#complete). Includes all resources and a virtual machine to generate firewall traffic to highlight 
2. [Network + Log Analytics + Automation](#network--log-analytics--automation-account). This includes all Azure resources for the network, logging, automation, and alerting. Does NOT include a virtual machine.
   
3. [Log Analytics + Automation account](#log-analytics--automation-account). This is good if you already have VNETs, firewalls, and route table/route server. Includes alerting.
4. [Automation account only](#automation-account-only). This is good if you already have networks and are using a centralized Log Analytics workspace. Includes alerting.

#### Complete

Deploys all resources to generate, collect, and deliver logs to CLAW. Includes virtual machine to generate internet-bound traffic. 

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Firewall%2FComplete%2Fazuredeploy.json)

 Solution includes the following:

- VNET with subnet for firewall and servers.
- Log Analytics workspace.
- Azure Firewall with network policy for internet access.
- Configures Azure Firewall diagnostic settings to send logs to Log Analytics workspace.
- Route table associated with ServerSubnet to route VM to firewall to generate logs.
- Automation account with published runbook, schedule, and required AWSPowerShell module.
- Alert on failed jobs will trigger email.
- Virtual machine on the server subnet to generate internet-bound traffic.
- All resources are deployed to a single subscription and VNET for simplicity. Resources could be deployed in any combination or resource groups or across multiple VNETs.

![Complete Solution](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/149368081-3db55d08-9b04-4ab8-ab12-8b69cd3692c6.png)

#### Network + Log Analytics + Automation account

Deploys all Azure resources for the network, logging, and automation. Does NOT include a virtual machine. You can complete this setup, tailor firewall policies for your envrionment, and have external users connecting to your Azure application or service. Application traffic will be collected and sent to the CLAW.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Firewall%2FNetwork%2520with%2520Log%2520Analytics%2520and%2520Automation%2Fazuredeploy.json)

 Solution includes the following:

- VNET with subnet for firewall and servers.
- Log Analytics workspace.
- Azure Firewall with network policy for internet access.
- Configures Azure Firewall diagnostic settings to send logs to Log Analytics workspace.
- Route table to route servers to firewall for internet access.
- Automation account with published runbook, schedule, and required AWSPowerShell module.
- Alert on failed jobs will trigger email.

![Network + Log Analytics + Automation](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/149368518-8bdd635d-9e44-4c34-b666-d3d2ad11dd21.png)

#### Log Analytics + Automation account

This is good if you already have VNETs, firewalls, and route table/route server. You may have the firewall in place today and traffic is routed from a TIC 2.0+ MTIPS device to your application gateway in azure. You can keep that solution in place while you confirm the Azure Firewalls logs are collected and uploaded to the CLAW. Then update your routing so that your external users no longer utilized the MTIPS device but routed directly to the Azure Firewall.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Firewall%2FLog%2520Analytics%2520and%2520Automation%2520Account%2Fazuredeploy.json)

Solution includes the following:

- Log Analytics workspace.
- Configures Azure Firewall diagnostic settings to send logs to Log Analytics workspace.
- Automation account with published runbook, schedule, and required AWSPowerShell module.
- Alert on failed jobs will trigger email.

![Log Analytics + Automation account](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/149368776-27f1ec73-01e8-4d08-b557-edeff6a3f04e.png)

#### Automation account only

This is good if you already have networks, an Azure Firewall, and are using a centralized Log Analytics workspace. 

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Firewall%2FAutomation%2520Account%2520Only%2Fazuredeploy.json)

Solution includes the following

- Configures Azure Firewall diagnostic settings to send logs to Log Analytics workspace.
- Automation account with published runbook, schedule, and required AWSPowerShell module.
- Alert on failed jobs will trigger email.
- Storage account.

![Automation account Only](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/149368956-072ca735-1bb3-4a5a-b429-40f6715f45ae.png)

## Pricing

The cost of each solution scales down as they leverage more existing resources. The following pricing is based on the default settings of the Complete solution. Altering the configuration may increase costs. Ingesting more logs with a pay-per-gb plan will increase costs.

- Complete
  - [Azure pricing calculator example scenario](https://azure.com/e/72ac82bc9b8d4073bb730b65aa372bc5)


NOTE: Consult [Azure Pricing calculator](https://azure.microsoft.com/en-us/pricing/calculator/) for up-to-date pricing based on the resources deployed for the selected solution.

## Next Steps

Evaluate your current architecture to determine which solution best upgrades what you have today to support your TIC 3.0 compliance.

- Contact your CISA representative to request a CLAW storage solution. 
- Use the Deploy the Azure button and deploy one or more of the solutions to a test environment to become familiar with the process and the deployed resources.
  - [Deploy this scenario](#deploy-this-scenario)
- Evaluate Azure Firewall routing 
  - [Deploy & configure Azure Firewall using the Azure portal | Microsoft Docs](https://docs.microsoft.com/en-us/azure/firewall/tutorial-firewall-deploy-portal)
- Additional details the ARM templates to simplify deployment or information to assist with integrating existing resources into the solution, please visit the [Trusted Internet Connection 3.0 solutions for Azure](https://github.com/Azure/trusted-internet-connection) in GitHub.

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

