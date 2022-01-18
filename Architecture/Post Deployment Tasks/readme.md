# Post Deployment Tasks

The following needs to be performed, for all solutions, once deployment is complete. These are the tasks that an ARM template cannot perform and requires manual effort. 

- [Add registered application with reader role to Log Analytics workspace (LAW)](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#add-reader-role)
- **OPTIONAL** - [Send Azure AD logs to Log Analytics workspace](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#send-azure-ad-logs-to-log-analytics-workspace)
  - Support the access/auth log control.

- **OPTIONAL** - [Send NetFlow logs to Log Analytics workspace](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#send-netflow-logs-to-log-analytics-workspace)
  - Supports NetFlow log control.

- [Link schedule to runbook](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#link-schedule-to-runbook)
- [Update Automation account variables with your unique values](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#update-automation-account-variables) 
  - CISA provided CLAW S3 access key
  - CISA provided CLAW S3 access secret
  - Unique S3 bucket name
  - LAW ID
  - Tenant ID
  - Registered app ID
  - Registered app secret 

## Add reader role

The Log Analytics workspace must be created before you can give the registered application the reader role. This role allows the registered application service principle read-only access to the resource like executing queries.

![Log Analytics workspace Access control](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145061916-48acf8e5-f3f5-473c-879e-2c34baacc7f2.PNG)

![Role assignment](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145061980-1dc67638-13c7-4c25-9f7a-120e1c01205e.PNG)

![Select members](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145062049-a22b2400-7406-44b3-a7f7-6176a31e161c.PNG)

![Description](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145062154-6a2b7f11-f876-45cb-83f3-570d6462fa21.PNG)

![Review and assign](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145062284-5ba8b1df-5a37-4456-b542-f345cbe1a0b0.png)

1. Go to the Log Analytics Workspace that will receive the Azure Firewall Diagnostic Settings logs.
2. Select **Access control (IAM)**
3. Select **+ Add**
4. Select **Add role assignment**
5. Select **Reader**
6. Select **Next**
7. Select **+ Select members**
8. Search for the Registered Application created earlier
   1. This example used, UploadToCLAW
9. Select the Application
10. Select **Select**
11. Enter a description
    1. This example used, Used to execute queries for firewall logs to upload to CLAW
12. Select **Review + assign**
13. Select **Review + assign**

## Send Azure AD logs to Log Analytics workspace

When proceeding through the steps in the following Guide, use the recently created or pre-existing Log Analytics workspace associated with the deployed resources.

![Azure AD Diagnostic settings](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/146437732-d820efc6-4673-4ca9-8dd5-08302fd50b5e.PNG)

![Configure Diagnostic settings](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/146437804-69bbb552-a1b7-4d58-8778-1c0895485e7c.png)

1. Visit your Azure Active Directory blade
2. Scroll down and select **Diagnostic settings** from the left menu
3. Select **+ Add diagnostic settings**
4. Check each box in Logs / Categories
5. Select the check box for **Send to Log Analytics workspace**
   1. Select the recently created or pre-existing Log Analytics workspace
6. Select **Save**

[Stream Azure Active Directory logs to Azure Monitor logs | Microsoft Docs](https://docs.microsoft.com/en-us/azure/active-directory/reports-monitoring/howto-integrate-activity-logs-with-log-analytics)

Once you setup Azure AD diagnostic settings, then you are ready to link a schedule to the Runbook so that it collects the logs and sends them to the CLAW.

- Use the [Link additional schedules with parameters](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#link-additional-schedules-with-parameter).

## Send NetFlow logs to Log Analytics workspace

This process is a little complicated but the following guide does a great job outlining the steps.

- [Azure traffic analytics | Microsoft Docs](https://docs.microsoft.com/en-us/azure/network-watcher/traffic-analytics)

Once you setup NetFlow logs with Network Security Groups, then you are ready to link a schedule to the Runbook so that it collects the logs and sends them to the CLAW.

- Use the [Link additional schedules with parameters](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#link-additional-schedules-with-parameter).

## Link schedule to runbook

The Runbook was created and published and the schedules were created with the ARM template; however, they need to be linked. The schedules are linked based on which logs to collect. Each schedule link will use a schedule and set a parameter to 'true'. 

- If you deployed a new or used a pre-existing Azure Firewall.
  - Use the [Default schedule Link](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#default-schedule-link)
- If you are using a Third-party Firewall like a Palo Alto NVA or Cisco NVA .
  - Use the [Link additional schedules with parameters](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#link-additional-schedules-with-parameter)
- If you setup Azure AD to send logs to the LAW ([Send Azure AD logs to Log Analytics workspace](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#send-azure-ad-logs-to-log-analytics-workspace)) then you want to also link an additional schedule that will send Azure AD logs to the CLAW.
  - Use the [Link additional schedules with parameters](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#link-additional-schedules-with-parameter)
- If you setup NetFlow to send logs to the LAW ([Send NetFlow logs to Log Analytics workspace](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#send-netflow-logs-to-log-analytics-workspace)) then you want to also link an additional schedule that will send NetFlow logs to the CLAW.
  - Use the [Link additional schedules with parameters](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Post%20Deployment%20Tasks#link-additional-schedules-with-parameter)

NOTE: Each schedule should only collect the logs for a single purpose, though it is possible to set multiple parameters to 'true', running them together adds complexity and failure to collect one of the logs would cause remaining logs to fail too.

### Default schedule link

![Runbooks](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145062436-0f99c019-e8be-466e-88e4-535a299dbf61.PNG)

![Link to schedule](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145062503-7cea21a0-fba3-4b75-9929-346e0dcff67f.png)

![Schedule runbook overview](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145062574-47e71285-a2aa-4d27-af66-6a963b11aab4.png)

![Select schedule](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145062630-1a4afe55-7fb2-415c-89f6-5d89e33bf501.png)

![Approve selection](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145062728-d0592fd3-0e82-43e8-9605-ad95d2d9eb1f.png)

![Verify](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145062809-6a9bdbc9-cc26-45aa-b489-85c5fdb2c9d9.PNG)

1. Go to the Automation account created during deployment
2. Select **Runbooks**
3. Select the runbook named **UploadToCLAWS3**
4. Select **Link to schedule**
5. Select **Link a schedule to your runbook**
6. Select **HourlyUploadsToCLAW**
7. Select **OK**
8. From within the UploadToCLAWS3 blade, select **Schedules** from the right hand menu
9. Verify the schedule exists
   1. Depending on how quick you select through the menus, you may need to wait a minute for the schedule to show up

### Link additional schedules with parameter

The parameters and run settings will be used to change which logs are collected and uploaded by the runbook.

NOTE: Each schedule should only collect the logs for a single purpose, though it is possible to set multiple parameters to 'true', running them together adds complexity and failure to collect one of the logs would cause remaining logs to fail too.

![Runbooks](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145062436-0f99c019-e8be-466e-88e4-535a299dbf61.PNG)

![Link to schedule](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145062503-7cea21a0-fba3-4b75-9929-346e0dcff67f.png)

![Schedule runbook overview](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145062574-47e71285-a2aa-4d27-af66-6a963b11aab4.png)

![Select schedule](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/145062630-1a4afe55-7fb2-415c-89f6-5d89e33bf501.png)

![Select Configure parameters and run settings](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/146452556-2f6db367-2ab0-4fcb-be98-00a4bc6af377.png)

![Set paramters](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/146452635-0ade8a0e-85cc-44c5-afd3-3fe1cb65d821.PNG)

![Select OK](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/146452678-12ab40b6-7c80-47da-978e-657205681ff4.png)

![Verify](https://raw.githubusercontent.com/Azure/trusted-internet-connection/main/Architecture/Images/146452720-2f6b64a9-e425-431d-b95d-2598a531e734.PNG)

1. Go to the Automation account created during deployment

2. Select **Runbooks**

3. Select the runbook named **UploadToCLAWS3**

4. Select **Link to schedule**

5. Select **Link a schedule to your runbook**

6. Select one of the HourlyUploadsToCLAW schedules available, five were deployed for you.

7. Select **Configure parameters and run settings**

8. You must fill in 'true' in only 1 of the parameters. You will link additional schedules for each of the parameters you want to set to 'true'. NOTE: 'true' MUST BE ALL LOWERCASE.

   A. If you are using a Third-party Firewall, then you will enter 'true' in this input box. 

   B. If you want to send Azure AD Auth logs to support Auth/Access logs to CLAW, then you will enter 'true' in this input box.

   C. If you want to send NetFlow logs to CLAW, then you will enter 'true' in this input box.

9. Select **OK**
10. Select **OK**
11. From within the UploadToCLAWS3 blade, select **Schedules** from the right hand menu
12. Verify that multiple schedules exist.
    1. There will be a schedule for each parameter that you set to 'true'

## Update Automation account variables

The ARM template created variables that are used by the runbook to access the Log Analytics workspace using the application's service principle. Some variables will need to be updated over time. The registered application secret and the CLAW secrets will expire. It is important to renew the registered application secret and coordinate receipt of a new CLAW secret before they expire.

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

If you used the complete solution, then you are generating logs on your Azure firewall. If you used another solution and have your application traversing your Azure firewall then you are generating logs.

In both scenarios, Azure firewall logs are sent to the Log Analytics workspace. Every 60 minutes, starting 1 hour after the deployment, Azure Automation will query the Log Analytics workspace and send the query in JSON format to the CLAW.

## Related Resources

- [Assign Azure roles using the Azure portal - Azure RBAC | Microsoft Docs](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal?tabs=current)
- [Manage runbooks in Azure Automation | Microsoft Docs](https://docs.microsoft.com/en-us/azure/automation/manage-runbooks#schedule-a-runbook-in-the-azure-portal)
- [Manage variables in Azure Automation | Microsoft Docs](https://docs.microsoft.com/en-us/azure/automation/shared-resources/variables?tabs=azure-powershell)
