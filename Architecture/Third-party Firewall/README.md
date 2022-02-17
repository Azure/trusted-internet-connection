# TIC 3.0 for Third-party Firewalls, aka Network Virtual Appliance (NVA)

## Automation account only (common deployment scenario)

### Requirements
The following must be performed before using this deployment scenario:
- Deployed Third-party firewall
- Deployed syslog forwarding server (usually running a Linux-based OS)
- Third-party firewall configured to send logs in syslog format to syslog forwarding server
- Log Analytics agent installed on syslog forwarding server
- Log Analytics agent configured to send syslogs to Log Analytics workspace

### Deploys and Updates
This deployment scenario will deploy and update the following:
- Deploy Automation Account
- Assign Automation Account's Managed Identity with Log Analytics Reader role to Log Analytics workspace
- Deploy Alert

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FThird-party%2520Firewall%2FAutomation%2520Account%2520Only%2Fazuredeploy.json)

![Automation account Only](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/149368956-072ca735-1bb3-4a5a-b429-40f6715f45ae.png)