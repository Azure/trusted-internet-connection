#### Automation account only

Use this Automation account only deployment, if you already have an Azure Front Door, and are using a centralized Log Analytics workspace. 

![Azure Front Door with WAF - Automation Account Only](https://user-images.githubusercontent.com/34814295/149374055-497a0a8c-1ad6-4a53-9b66-2739ba81083a.png)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FAzure%2520Front%2520Door%2FAutomation%2520Account%2520Only%2Fazuredeploy.json)

Solution includes the following

- Configures Azure firewall diagnostic settings to send logs to Log Analytics workspace.
- Automation account with published runbook, schedule, and required AWSPowerShell module.
- Alert on failed jobs will trigger email.
- Storage account.
