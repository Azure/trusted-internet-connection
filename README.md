# Trusted Internet Connection (TIC) 3.0 compliance for internet facing applications

## Introduction
This repo supports an article on the Azure Architecture Center (AAC) - [Trusted Internet Connection (TIC) 3.0 compliance - Azure Example Scenarios | Microsoft Docs](https://docs.microsoft.com/en-us/azure/architecture/example-scenario/security/trusted-internet-connections), it contains lots of great information on using the content of this repo. Please visit the article in the AAC before proceeding.

## Details of the Repository
- Architecture
  - Azure Firewall
  - Third-party Firewall
  - Azure Front Door
  - Azure Application Gateway
  - Event Hub
  - Service Principle (Registered Application)
  - Post Deployment Tasks
  - Visio

### Architecture
**Azure Active Directory**
- Deploy an automated service to deliver Azure Active Directory logs to CISA CLAW. This supports the TIC 3.0 compliance for authentication and sign-in logs.
  - AuditLogs
  - SignInLogs
  - AADNonInteractiveUserSignInLogs
  - AADServicePrincipalSignInLogs
  - ManagedIdentitySignInLogs
  - ProvisioningLogs
  - ADFSSignInLogs
  - RiskyUsers
  - UserRiskEvents
  - NetworkAccessTrafficLogs
  - RiskyServicePrincipals
  - ServicePrincipalRiskEvents


**Azure Application Gateway**
- Deploy a suite of services that leverage Azure Application Gateway, regional load balancer with a Web Application Firewall, to provide direct access to an Azure-based application. 
- Meet TIC 3.0 telemetry compliance with the automated service to deliver application connection logs and layer 7 firewall logs to CISA CLAW. 

**Azure Firewall**
- Deploy a suite of services that leverage Azure Firewall, scalable layer 4 firewall, to provide direct access to an Azure-based application. 
- Meet TIC 3.0 telemetry compliance with the automated service to deliver connection logs and layer 3 firewall logs to CISA CLAW.

**Azure Front Door**

- Deploy a suite of services that leverage Azure Front Door, global load balancer with a Web Application Firewall, to provide direct access to an Azure-based application. 
- Meet TIC 3.0 telemetry compliance with the automated service to deliver application connection logs and layer 7 firewall logs to CISA CLAW. 

**Event Hub**

- Event Hub Standard is a modern big data streaming platform and event ingestion service.

**Service Principle**

- Service Principle (Registered Application) is an entity that defines the access policy and permissions for the user/application in the Azure AD tenant.

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

## Logging Details

The following Kusto queries can be run against the Log Analytics workspace to review the type of logs collected by CISA and to leverage for your organizations security requirements.

App Gateway
```
AzureDiagnostics 
| where TimeGenerated > ago(15m)
| where ResourceProvider == 'MICROSOFT.NETWORK'
    and (isnotempty(requestUri_s))
    and Category == 'ApplicationGatewayFirewallLog' or Category == 'ApplicationGatewayAccessLog'
```

Azure Firewall
```
AzureDiagnostics 
| where TimeGenerated > ago(15m) 
| where Category == 'AzureFirewallNetworkRule' or Category == 'AzureFirewallApplicationRule'
```

Azure Front Door
```
AzureDiagnostics 
| where TimeGenerated > ago(15m)
| where ResourceType == 'FRONTDOORS'
    and (isnotempty(details_matches_s))
    and Category == 'FrontdoorWebApplicationFirewallLog' or Category == 'FrontdoorAccessLog'
```

Third-party Firewall (aka NVA)
```
Syslog 
| where TimeGenerated > ago(15m)
```

Azure AD
```
AuditLogs
| union SigninLogs
| union AADNonInteractiveUserSignInLogs
| union AADServicePrincipalSignInLogs
| union AADManagedIdentitySignInLogs
| union AADProvisioningLogs
| union ADFSSignInLogs
| union AADRiskyUsers
| union AADUserRiskEvents
| union AADRiskyServicePrincipals
| union AADServicePrincipalRiskEvents
| where TimeGenerated > ago(15m)
```

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

### Alerting
An Azure alert is deployed and configured to send an failure email notification, to the email(s) defined at deployment. The notification informs the organization when the runbook fails. Administrators can review the runbook history for more details on why the runbook failed.


## Related Resources
- [Firewall, App Gateway for virtual networks - Azure Example Scenarios | Microsoft Docs](https://docs.microsoft.com/en-us/azure/architecture/example-scenario/gateway/firewall-application-gateway)
- [azure-docs/quickstart-arm-template.md at master · MicrosoftDocs/azure-docs (github.com)](https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/app-service/quickstart-arm-template.md)
- [Quickstart: Assign an Azure role using an Azure Resource Manager template - Azure RBAC | Microsoft Docs](https://docs.microsoft.com/en-us/azure/role-based-access-control/quickstart-role-assignments-template)
- [Microsoft.Automation/automationAccounts/schedules - Bicep & ARM template reference | Microsoft Docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.automation/automationaccounts/schedules?tabs=json)
- [Microsoft.Automation/automationAccounts/jobSchedules - Bicep & ARM template reference | Microsoft Docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.automation/automationaccounts/jobschedules?tabs=json)