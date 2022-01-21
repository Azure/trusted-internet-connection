# Trusted Internet Connection (TIC) 3.0 compliance for internet facing applications

## Introduction

This repo supports an article on the Azure Architecture Center (AAC) [INSERT LINK], it contains lots of great information on using the content of this repo. Please visit the article in the AAC before proceeding.

## Details of the Repository

- Architecture
  - Prerequisite Tasks
  - Azure Firewall
  - Third-party Firewall
  - Azure Front Door
  - Post Deployment Tasks
  - Visio
- Runbook
  - Kusto Queries
  - UploadToCLAW-S3.ps1
  - UploadToCLAW-AzSA.ps1

### Prerequisite Tasks

Some tasks are not automated and must be manually performed. Review [Prerequisite tasks](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Prerequisite%20Tasks) to validate your environment is ready. The only contents of this directory is the README.md.

### Azure Firewall

Azure Firewall is a native azure solution for securely managing connections between networks or the internet. All Deploy to Azure buttons in the primary article in Azure Architecture Center reference ARM JSON files within this directory.

### Third-party Firewall

Azure supports many Network Virtual Appliance (NVA) also known as Third-party Firewalls. These firewalls run on virtual machines and are managed by their respective vendor's portal. NVA are supported and their logs are collected in syslog format. Some NVA may connected directly to Log Analytics workspace while others need an intermediate syslog forwarding server. This can run on Linux or Windows. This system will receive the logs from the NVA and send them to Log Analytics workspace. 

### Azure Front Door

Azure Front Door is another method for securing applications from the internet. Front Door supports Web Application Firewall (WAF) policies and will send WAF and traffic logs to Log Analytics workspace. Front Door also provides global load balancing. It is similar to an Application Gateway, where the App Gateway is regional. The solution provided in this directory will deploy the resources expecting an Azure Front Door to send logs to the Log Analytics workspace.

### Post Deployment Tasks

Additional tasks are required to complete integration of all components. Review [Post-deployment tasks](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks) to complete the scenario. The only contents of this directory is the README.md.

### Visio

This folder contains a copy of all Visio diagrams used in the articles and a few additional to assist with documentation and understanding.

### Kusto Queries

This folder contains copies of the Kusto queries used in the CLAW runbooks to retrieve information from the Log Analytics workspace. A Kusto query is a read-only request to process data and return results. The request is stated in plain text, using a data-flow model that is easy to read, author, and automate. Kusto queries are made of one or more query statements.

### UploadToCLAW-S3.ps1

This is the primary runbook as CLAW is currently using S3 as their storage solution. This runbook is automatically deployed and published as part of each azuredeploy.json found across the different scenarios. If an organization is attempting to use their own resources, please download this runbook and associate it with an automation account. It is PowerShell based and could be run locally but it is looking for variables that are only stored in an Azure Automation account.

### UploadToCLAW-AzSA.ps1

This is a runbook that is provided for custom solutions requiring TIC 3.0 logs to be sent to an Azure Storage Container instead of an AWS S3-based CLAW storage solution. If an organization is attempting to use their own resources, please download this runbook and associate it with an automation account. It is PowerShell based and could be run locally but it is looking for variables that are only stored in an Azure Automation account.

## Deployment Instructions

### Azure Resource Management (ARM) Templates

ARM templates are used to lay the ground work for you to deploy the resources necessary to support TIC 3.0 compliance. The templates are the "azuredeploy.json" files within the Architecture folder structure. The ARM templates use a combination of linked and nested templates to simplify code maintenance and provide consistency during deployment. If you want to modify any of the code, please fork the repo and update accordingly. The following figure shows which resources are deployed with each Azure Firewall scenario.

![ARM Template Structure for Azure Firewall Scenarios](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/150392354-e1a3eef5-2559-4660-8805-0b2d2e4ce093.png)

### Log Analytics workspace

If multiple Log Analytics workspaces are used, then multiple Automation Accounts must be deployed, one Automation Account per Log Analytics workspace. If your organization has a Log Analytics workspace for Identity, then deploy an Automation Account and update runbook variables to access the Identity Log Analytics workspace and update parameters when setting up the scheduled task so that LogAzureAD is set to true. Deploy another Automation Account to connect to the Log Analytics workspace for network logs.

### Azure Automation Account

An Azure Automation Account is required as it will be used to execute the runbook. CISA has requested logs be sent in no longer than 30 minute intervals. So it is important to link a schedule with the runbook to meet this requirement. AWSPowerShell must be installed as a module in the Azure Automation Account. I have seen older automation accounts fail to properly install modules, so it may be necessary to create a new automation account instead of using an existing account. 

### CLAW runbook execution

The Automation account runs a PowerShell-based Runbook to query the Log Analytics workspace, format the data into a JSON, and stream it to the CLAW. The reason for using stream is to break it down into small chunks to reduce the performance impact of reading large files at once. Reading the data from a 250 mb file before uploading it may cause the process to fail. AWSPowerShell tools are used to connect to the S3 bucket and upload the JSON data into a datatime.json file.

The runbook uses encrypted Automation account variables to simplify initial configuration and ongoing maintenance. Once the organization deploys the Automation account, the runbook will not need modification. Administrators will perform the initial configuration by updating the values of each variable. When the CLAW S3 secret and registered application secret is rotated, the administrators only need to update the appropriate variable. 

### Alerting

An Azure alert is deployed and configured to send an failure email notification, to the email(s) defined at deployment. The notification informs the organization when the runbook fails. Administrators can review the runbook history for more details on why the runbook failed.