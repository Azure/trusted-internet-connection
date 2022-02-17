# Post Deployment Tasks

The following tasks needs to be performed. These are the tasks that an ARM template cannot perform and requires manual effort. 

NOTE: Updates to the deployment scenarios migrated the solutions from using app registrations to managed identities! Now the deployment scenarios handle assigning permissions. 

## All Deployment Scenarios

- [Update Automation account variables with your unique values](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#update-automation-account-variables) 
  - CISA provided CLAW S3 access key
  - CISA provided CLAW S3 access secret
  - CISA provided CLAW S3 bucket name
  - LAW ID
    - This is automatically updated by the deployment scenario, if it is incorrect - then update.
  - Tenant ID
    - This is automatically updated by the deployment scenario, if it is incorrect - then update.

## Specific Deployment Scenario Tasks

- Azure Firewall Scenario
- Azure Application Gateway Scenario
- Azure Front Door Scenario

### Azure Firewall Scenario

For the solutions that deploy an Azure Firewall, you must associate Azure Firewall Public IP with a FQDN. This can be performed by updating a publicly accessible A record, creating an internally accessible A record, or updating local host file. The Azure Firewall creates a NAT rule that allows you to access the application on port 5443.

NOTE: You MUST access the Azure PaaS applications through the Firewall using a FQDN in the browser, IP addresses in the browser will fail.

#### Get the public IP of your Azure Firewall

![image-20220217135450240](C:\Users\paullizer\AppData\Roaming\Typora\typora-user-images\image-20220217135450240.png)

![image-20220217142101414](C:\Users\paullizer\AppData\Roaming\Typora\typora-user-images\image-20220217142101414.png)

1. Navigate to the Azure Firewall.
2. Select the URL associated with the Firewall public IP value.
3. Document/copy the public IP address.

#### OPTION 1 - Update Local Host File

This is good for the solutions you are testing or to quickly validate the Azure Firewall configuration. 

![img](file:///C:/Users/PAULLI~1/AppData/Local/Temp/SNAGHTML656d3e8.PNG)

![image-20220217140354570](C:\Users\paullizer\AppData\Roaming\Typora\typora-user-images\image-20220217140354570.png)

1. Navigate to C:\Windows\Systems32\drivers\etc
2. Open the hosts file
3. Add the public IP address
4. Enter a space or a tab, then add the FQDN

#### OPTION 2 - Create Public A record

If you are using Azure DNS, then follow this URL to create a new A record using the Public IP of your Firewall

[Manage DNS record sets and records with Azure DNS | Microsoft Docs](https://docs.microsoft.com/en-us/azure/dns/dns-operations-recordsets-portal#:~:text=Update a record 1 On the Record set,the notification that the record has been saved.)

#### OPTION 3 - Create Internal A record

Coordinate with administration team that manages your enterprise DNS and request they associate your Azure Firewall's public IP with some FQDN.

#### Navigate to application in browser

Open a browser and use the URL

"https://" + FQDN + ":5443"

![image-20220217140905712](C:\Users\paullizer\AppData\Roaming\Typora\typora-user-images\image-20220217140905712.png)



### Azure Application Gateway Scenario

The Application Gateway scenario does not require creating an A record to access the application. All you need to do is collect the public IP of the Application Gateway and use it in the browser to access the application.

#### Get the public IP of your Azure Application Gateway

![img](file:///C:/Users/PAULLI~1/AppData/Local/Temp/SNAGHTML66854ce.PNG)

1. Navigate to the Azure Application Gateway.
2. Document/copy the public IP address.

#### Navigate to application in browser

Open a browser and use the URL

"https://" + Public_IP_Address

![image-20220217141651264](C:\Users\paullizer\AppData\Roaming\Typora\typora-user-images\image-20220217141651264.png)

### Azure Front Door Scenario

The Front Door scenario does not require creating an A record to access the application. All you need to do is collect the URL of the Front Door and use it in the browser to access the application.

#### Get the public IP of your Azure Application Gateway

![image-20220217141928680](C:\Users\paullizer\AppData\Roaming\Typora\typora-user-images\image-20220217141928680.png)

1. Navigate to the Azure Application Gateway.
2. Document/copy the public IP address.

#### Navigate to application in browser

Open a browser and use the URL

"https://" + Public_IP_Address

![image-20220217142014115](C:\Users\paullizer\AppData\Roaming\Typora\typora-user-images\image-20220217142014115.png)

## Update Automation account variables

The ARM template created variables that are used by the runbook to access the Log Analytics workspace using the application's service principle. Some variables will need to be updated over time. The CLAW secrets will expire. It is important to coordinate receipt of a new CLAW secret before it expires.

The variables are encrypted. This means that you or anyone cannot view them from portal or consoles. They can only be decrypted from within a runbook. When you update a variable because a secret is expiring or you want to use a different Log Analytics workspace, you just edit the value which overwrite the existing when you save it.

This example walks through updating the AWSAccessKey, repeat the steps for each Variable. 

![Edit variable](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145062874-d1aa76c1-30ac-45f0-a0e0-db86124229b0.PNG)

![Save variable](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145062937-8a6eb0d8-2108-4a54-8bcb-0fd0e151a556.png)

1. Go to the Automation account used in the previous step (same account created during deployment)
2. Select **Variables** from the left hand menu, you will have to scroll down to view it
3. Select **AWSAccessKey**,
   1. You will start with this variable but you must update each variable
4. Select **Edit value**
5. Enter the AWS Access Key provided to you by CISA
   1. Not all values are provided by CISA
   2. Some values you will have collected during the [Prerequisite Tasks](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Prerequisite%20Tasks)
6. Select **Save**

## Ready for uploading logs to CLAW

Logs from your deployed scenario will be uploaded to the CLAW started 1 hour after the deployed scenario and then every 30 minutes.

## Related Resources

- [Assign Azure roles using the Azure portal - Azure RBAC | Microsoft Docs](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal?tabs=current)
- [Manage runbooks in Azure Automation | Microsoft Docs](https://docs.microsoft.com/en-us/azure/automation/manage-runbooks#schedule-a-runbook-in-the-azure-portal)
- [Manage variables in Azure Automation | Microsoft Docs](https://docs.microsoft.com/en-us/azure/automation/shared-resources/variables?tabs=azure-powershell)
