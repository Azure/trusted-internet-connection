# Prerequisite Tasks

There are a few tasks that must be performed before deploying your TIC 3.0 compliant solution. Some of the tasks are local to your environment while others require engaging with CISA to request access to a CLAW resource.

## Requirements for all Architecture Solutions

You must have the following before deployment:

- [Resource group](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Prerequisite%20Tasks#create-resource-group)
  - If you have appropriate permissions, you can create this during the deployment process.

- [Register an enterprise application](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Prerequisite%20Tasks#register-an-enterprise-application)
  - This will be used to provide Reader Access to Log Analytics workspace (LAW).
- [Create secret for enterprise application](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Prerequisite%20Tasks#create-secret-for-enterprise-application)

Though you can deploy all of the Azure resources, to actually send log data to a CISA CLAW to support the TIC 3.0 compliance you will need the following: 

- [Request CISA provide S3 Bucket Access Key, Secret, and S3 Bucket Name](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Prerequisite%20Tasks#request-claw-access)
- [Collect Tenant ID](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Prerequisite%20Tasks#collect-tenant-id)

### Create resource group

Some organizations control resource group creation while others provide permissions to subscription owners to create them. This can be performed manually or using CI/CD methodology. 

You can create the resource group during the deployment process too.

[Manage resource groups - Azure portal - Azure Resource Manager | Microsoft Docs](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#create-resource-groups)

### Register an enterprise application

You will need to register an enterprise application, this provides the authorization and access mechanism for the runbook to connect to the Log Analytics workspace to perform the necessary queries. It is suggested that you create a new application for the purpose of this effort. While you can use an existing application, each one should fulfil only a single purpose. It is useful to name the application based on its purpose. This example will use the name "UploadToCLAW" as the application name.

![App registration](https://user-images.githubusercontent.com/34814295/145053553-92a21faf-01c7-43e0-8d79-5d2023ca0715.PNG)

![Register an application](https://user-images.githubusercontent.com/34814295/145053655-97a4c705-b96d-4e5c-9658-ffb708a2a6e2.PNG)

1. Visit your Azure Active Directory blade
2. Select **App registrations** on the left menu
3. Select **New registration**
4. Enter the name of your new application
   1. This example used, UploadToCLAW
5. Select **Register**

[Register your app with the Azure AD v2.0 endpoint - Microsoft Graph | Microsoft Docs](https://docs.microsoft.com/en-us/graph/auth-register-app-v2)

### Create secret for enterprise application

You will need to create a client secret as a means for the service principal associated with the enterprise application to authenticate. Once the secret value is created, it is only available to be copies for a short period of time, you may leave the screen and return. If you fail to copy the Value before it shows all "***************" wild cards, you should delete the secret and create a new one.

NOTE: Secrets expire, default is 6 months and the longest they can be configured to last is 24 months. You will need to create a new secret and update the variable in Azure Automation before the existing expires.

![Certificates & secrets](https://user-images.githubusercontent.com/34814295/145053755-e7d54fec-7f98-4297-89e7-0342021c7415.PNG)

![Add a client secret](https://user-images.githubusercontent.com/34814295/145053828-0f5be38e-5507-4f87-92fc-660a64490684.png)

![Copy secret value](https://user-images.githubusercontent.com/34814295/145053876-477f9cb8-be41-41c7-9a51-d4535551a043.png)

1. When you register a new application, it will automatically take you to the application blade, if not you can select it from Azure AD > App registration.
2. Select **Certificates & secrets** from the left menu
3. Select **Client secrets**
4. Select **New client secret**
5. Enter a description
   1. This example used, Query Log Analytics Workspace
6. Select Expiration length, default is 6 months
   1. Secrets expire, default is 6 months and the longest they can be configured to last is 24 months. You will need to create a new secret and update the variable in Azure Automation before the existing expires.
7. Select **Add**
8. Select the copy button
   1. Once the secret value is created, it is only available to be copies for a short period of time, you may leave the screen and return. If you fail to copy the Value before it shows all "***************" wild cards, you should delete the secret and create a new one.
9. Save the value in a secure location. You will enter it into a variable in the Automation account.

[Create an Azure AD app and service principal in the portal - Microsoft identity platform | Microsoft Docs](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)

### Request CLAW access

Your organization will need to contact your CISA representative to request CLAW access. When a formal process is published, this section will be updated with a link.

### Collect Tenant ID

You will need your Tenant ID. Please safeguard this information. 

[How to find your tenant ID - Azure Active Directory | Microsoft Docs](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-to-find-tenant)

# Ready to Deploy

Now you are ready to deploy your solution. Return to the main Readme.

[TIC 3.0 Solutions](https://github.com/Azure/trusted-internet-connection#deploy-this-scenario)
