# Trusted Internet Connection (TIC) 3.0 compliance for internet facing applications

## Introduction
This repo supports an article on the Azure Architecture Center (AAC) [INSERT LINK], it contains lots of great information on using the content of this repo. Please visit the article in the AAC before proceeding.

## Details of the Repository
- Architecture
  - Prerequisite Tasks
  - Azure Firewall
  - Third-party Firewall
  - Azure Front Door
  - Azure Application Gateway
  - Post Deployment Tasks
  - Visio
- Runbook
  - Kusto Queries
  - UploadToCLAW-S3.ps1
  - UploadToCLAW-AzSA.ps1

### Architecture
**Azure Active Directory**
- Deploy an automated service to deliver Azure Active Directory logs to CISA CLAW. This supports the TIC 3.0 compliance for authentication and sign-in logs.

**Azure Application Gateway**
- Deploy a suite of services that leverage Azure Application Gateway, regional load balancer with a Web Application Firewall, to provide direct access to an Azure-based application. 
- Meet TIC 3.0 telemetry compliance with the automated service to deliver application connection logs and layer 7 firewall logs to CISA CLAW. 

**Azure Firewall**
- Deploy a suite of services that leverage Azure Firewall, scalable layer 4 firewall, to provide direct access to an Azure-based application. 
- Meet TIC 3.0 telemetry compliance with the automated service to deliver connection logs and layer 4 firewall logs to CISA CLAW.

**Azure Front Door**
- Deploy a suite of services that leverage Azure Front Door, global load balancer with a Web Application Firewall, to provide direct access to an Azure-based application. 
- Meet TIC 3.0 telemetry compliance with the automated service to deliver application connection logs and layer 7 firewall logs to CISA CLAW. 

**Images**
- Contains images used throughout the articles in this repo.

**NetFlow Logs**
- Deploy an automated service to deliver NetFlow logs to CISA CLAW. This supports the TIC 3.0 compliance for NetFlow logs.

**Post Deployment Tasks**
- Article that defines list of tasks following deployment of scenarios.

**Prerequisite Tasks**
- Article that defines list of tasks that need to happen before deployment of scenarios.

**Third-party Firewall**
- Deploy an automated service to deliver third-party firewalls, layer 4 firewall, to provide direct access to an Azure-based application. 
- Meet TIC 3.0 telemetry compliance with the automated service to deliver connection logs and layer 4 firewall logs to CISA CLAW.

**Visio**
- Architecture for all scenarios and solutions in Visio document.

### Runbook
**UploadToCLAW-S3.ps1**
- This is the primary runbook as CLAW is currently using S3 as their storage solution. 
- Runbook is automatically deployed and published as part of each azuredeploy.json found across the different scenarios. 

**Kusto Queries**
- List of queries that are used to collect the data from a Log Analytics workspace.

## Deployment Instructions
### Azure Firewall vs. Front Door vs. Application Gateway
Azure Firewall functions as a router and a firewall with more policies

### Azure Resource Management (ARM) Templates
ARM templates are used to lay the ground work for you to deploy the resources necessary to support TIC 3.0 compliance. The templates are the "azuredeploy.json" files within the Architecture folder structure. The ARM templates use a combination of linked and nested templates to simplify code maintenance and provide consistency during deployment. If you want to modify any of the code, please fork the repo and update accordingly. 

#### Azure Firewall
- Deploy a suite of services that leverage Azure Firewall, scalable layer 4 firewall, to provide direct access to an Azure-based application. 
- Meet TIC 3.0 telemetry compliance with the automated service to deliver connection logs and layer 4 firewall logs to CISA CLAW.

#### Azure Front Door
- Deploy a suite of services that leverage Azure Front Door, global load balancer with a Web Application Firewall, to provide direct access to an Azure-based application. 
- Meet TIC 3.0 telemetry compliance with the automated service to deliver application connection logs and layer 7 firewall logs to CISA CLAW. 

#### Azure Application Gateway
- Deploy a suite of services that leverage Azure Application Gateway, regional load balancer with a Web Application Firewall, to provide direct access to an Azure-based application. 
- Meet TIC 3.0 telemetry compliance with the automated service to deliver application connection logs and layer 7 firewall logs to CISA CLAW. 

### Log Analytics workspace
If multiple Log Analytics workspaces are used, then multiple Automation Accounts must be deployed, one Automation Account per Log Analytics workspace. If your organization has a Log Analytics workspace for Identity, then deploy an Automation Account and update runbook variables to access the Identity Log Analytics workspace and update parameters when setting up the scheduled task so that LogAzureAD is set to true. Deploy another Automation Account to connect to the Log Analytics workspace for network logs.

### Azure Automation Account
An Azure Automation Account is required as it will be used to execute the runbook. CISA has requested logs be sent in no longer than 30 minute intervals. So it is important to link a schedule with the runbook to meet this requirement. AWSPowerShell must be installed as a module in the Azure Automation Account. I have seen older automation accounts fail to properly install modules, so it may be necessary to create a new automation account instead of using an existing account. 

### CLAW runbook execution
The Automation account runs a PowerShell-based Runbook to query the Log Analytics workspace, format the data into a JSON, and stream it to the CLAW. The reason for using stream is to break it down into small chunks to reduce the performance impact of reading large files at once. Reading the data from a 250 mb file before uploading it may cause the process to fail. AWSPowerShell tools are used to connect to the S3 bucket and upload the JSON data into a datatime.json file.

The runbook uses encrypted Automation account variables to simplify initial configuration and ongoing maintenance. Once the organization deploys the Automation account, the runbook will not need modification. Administrators will perform the initial configuration by updating the values of each variable. When the CLAW S3 secret and registered application secret is rotated, the administrators only need to update the appropriate variable. 

### Alerting
An Azure alert is deployed and configured to send an failure email notification, to the email(s) defined at deployment. The notification informs the organization when the runbook fails. Administrators can review the runbook history for more details on why the runbook failed.

## Related Resources
- [Firewall, App Gateway for virtual networks - Azure Example Scenarios | Microsoft Docs](https://docs.microsoft.com/en-us/azure/architecture/example-scenario/gateway/firewall-application-gateway)
- [azure-docs/quickstart-arm-template.md at master · MicrosoftDocs/azure-docs (github.com)](https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/app-service/quickstart-arm-template.md)
- [Quickstart: Assign an Azure role using an Azure Resource Manager template - Azure RBAC | Microsoft Docs](https://docs.microsoft.com/en-us/azure/role-based-access-control/quickstart-role-assignments-template)
- [Microsoft.Automation/automationAccounts/schedules - Bicep & ARM template reference | Microsoft Docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.automation/automationaccounts/schedules?tabs=json)
- [Microsoft.Automation/automationAccounts/jobSchedules - Bicep & ARM template reference | Microsoft Docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.automation/automationaccounts/jobschedules?tabs=json)