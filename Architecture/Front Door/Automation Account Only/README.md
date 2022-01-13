#### Automation account only

This is good if you already have networks, an Azure Front Door, and are using a centralized Log Analytics workspace. 

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMicrosoftDocs%2FTrusted-Internet-Connection%2Fmain%2FArchitecture%2FFront%2520Door%2FAutomation%2520Account%2520Only%2Fazuredeploy.json)

Solution includes the following

- Configures Azure firewall diagnostic settings to send logs to Log Analytics workspace.
- Automation account with published runbook, schedule, and required AWSPowerShell module.
- Alert on failed jobs will trigger email.
- Storage account.
