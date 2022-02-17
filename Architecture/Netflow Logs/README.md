# TIC 3.0 Complaince for Netflow Logs
## Automation account only (most common deployment scenario)
### Requirements
The following must be performed before using this deployment scenario:
- Deployed Network Security Groups (NSG).
- Associate NSG with priviate endpoints, subnets, or a virutal network.
- Enabled NetFlow log collection on the Network Security Groups.
- Configured NSG Diagnostic Settings to send logs and metrics to a Log Analytics workspace. 

### Deploys and Updates
This deployment scenario will deploy and update the following:
- Deploy Automation Account
- Assign Automation Account's Managed Identity with Log Analytics Reader role to Log Analytics workspace
- Deploy Alert

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Ftrusted-internet-connection%2Fmain%2FArchitecture%2FNetflow%2520Logs%2FAutomation%2520Account%2520Only%2Fazuredeploy.json)

![Automation account Only](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/149368956-072ca735-1bb3-4a5a-b429-40f6715f45ae.png)