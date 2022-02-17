# Prerequisite Tasks

There are a few tasks that must be performed before deploying your TIC 3.0 compliant solution. Some of the tasks are local to your environment while others require engaging with CISA to request access to a CLAW resource.

NOTE: Updates to the deployment scenarios migrated the solutions from using app registrations to managed identities! Now the deployment scenarios handle assigning permissions. 

## Requirements for all Architecture Solutions

You must have the following before deployment:

#### Complete and Network+Log Analytic+Automation Solutions

- [Resource group](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Prerequisite%20Tasks#create-resource-group)
  - Must have contributor permissions to the resource group
  - If you have appropriate permissions, you can create this during the deployment process.

#### All Solutions

- [Request CISA provide S3 Bucket Access Key, Secret, and S3 Bucket Name](https://github.com/Azure/trusted-internet-connection/tree/main/Architecture/Prerequisite%20Tasks#request-claw-access)

### Create resource group

Some organizations control resource group creation while others provide permissions to subscription owners to create them. This can be performed manually or using CI/CD methodology. 

You can create the resource group during the deployment process too.

### Request CLAW access

Your organization will need to contact your CISA representative to request CLAW access. When a formal process is published, this section will be updated with a link.

## Ready to Deploy

Now you are ready to deploy your solution. Return to the main Readme.

[TIC 3.0 Solutions](https://github.com/Azure/trusted-internet-connection#deploy-this-scenario)

## Related Resources

- [Manage resource groups - Azure portal - Azure Resource Manager | Microsoft Docs](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#create-resource-groups)
- [Register your app with the Azure AD v2.0 endpoint - Microsoft Graph | Microsoft Docs](https://docs.microsoft.com/en-us/graph/auth-register-app-v2)
- [Create an Azure AD app and service principal in the portal - Microsoft identity platform | Microsoft Docs](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
- [How to find your tenant ID - Azure Active Directory | Microsoft Docs](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-to-find-tenant)
