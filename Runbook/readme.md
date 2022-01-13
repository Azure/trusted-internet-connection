# UploadToCLAW-S3
    PowerShell script used as a Runbook for an Azure Automation Account.

## SYNOPSIS  
    Upload logs to CISA managed CLAW in Amazon S3.

## REQUIREMENTS
1. CISA Provided S3 Bucket with Access Key and Access Secret
2. Azure Log Analytics Workspace (LAW)
3. Enterprise Application with rights to the LAW and secret key
4. Azure Firewall sending diagnostic logs and metrics to LAW
5. Azure Automation Account
    1. With Encrypted Variables
        1. AWSAccessKey (ENCRYPTED)
        2. AWSSecretKey (ENCRYPTED)
        3. EnterpriseApplicationId (ENCRYPTED)
        4. EnterpriseApplicationSecret (ENCRYPTED)
        5. LogAnalyticWorkspaceID (ENCRYPTED)
        6. S3BucketName (ENCRYPTED)
        7. TenantID (ENCRYPTED)
    2. With additional PowerShell Modules
        1. AWSPowerShell
        2. Az.Accounts
        3. Az.OperationalInsights    
# NOTES  
    File Name       :   UploadToCLAW-S3.ps1  
    Author          :   Paul Lizer, paullizer@microsoft.com
    Version         :   1.0 (2021 12 02)     

## EXAMPLE  
    Runbook triggered by Azure Automation Account with Schedule that runs every 
    60 minutees (1 hour) to send logs to CLAW in Amazon S3 bucket
    
        UploadToCLAW-S3.ps1 

