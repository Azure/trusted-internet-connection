# UploadToCLAW-S3
    PowerShell script used as a Runbook for an Azure Automation Account.

## SYNOPSIS  
    Upload logs to CISA managed CLAW in Amazon S3.

## REQUIREMENTS
1. CISA Provided S3 Bucket with Access Key and Access Secret
2. Azure Log Analytics Workspace
4. Firewall (native, third-party, or Web App) sending diagnostic logs and metrics to Log Analytics Workspace
5. Azure Automation Account, with managed identity assigned Log Analytics reader role on Log Analytics Workspace
    1. With Encrypted Variables
        1. AWSAccessKey (ENCRYPTED)
        2. AWSSecretKey (ENCRYPTED)
        3. LogAnalyticWorkspaceID
        4. S3BucketName (ENCRYPTED)
        5. TenantId
    2. With additional PowerShell Modules
        1. AWSPowerShell
  
# NOTES  
    File Name       :   UploadToCLAW-S3.ps1  
    Author          :   Paul Lizer, paullizer@microsoft.com
    Version         :   1.10 (2022 02 11)     

## EXAMPLE  
    Runbook triggered by Azure Automation Account with Schedules that runs every 
    30 minutes to send logs to CLAW in Amazon S3 bucket
    
        UploadToCLAW-S3.ps1 

