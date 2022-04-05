<#PSScriptInfo

.VERSION 
    1.14

.GUID 
    41e92ce1-3a88-49e0-9495-85fc261bf7ec

.AUTHOR 
    Paul Lizer, paullizer@microsoft.com

.COMPANYNAME 
    Microsoft

.COPYRIGHT 
    Creative Commons Attribution 4.0 International Public License

.TAGS

.LICENSEURI 
    https://github.com/Azure/trusted-internet-connection/blob/main/LICENSE

.PROJECTURI 
    https://github.com/Azure/trusted-internet-connection

.ICONURI

.EXTERNALMODULEDEPENDENCIES 
    https://www.powershellgallery.com/packages/AWSPowerShell/

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES 
    https://github.com/Azure/trusted-internet-connection

.LINK  
    https://github.com/Azure/trusted-internet-connection
    
.EXAMPLE  
    Runbook triggered by Azure Automation Account with Schedule that runs every 
    60 minutees (1 hour) to send logs to CLAW in Amazon S3 bucket

        UploadToCLAW-S3.ps1

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Using an Azure Automation Account Runbook, upload logs to CISA managed CLAW. 

#> 

<#***************************************************
                       Process
-----------------------------------------------------
    
https://github.com/Azure/trusted-internet-connection

***************************************************#>
    

<#***************************************************
                       Terminology
-----------------------------------------------------
N\A
***************************************************#>


<#***************************************************
                       Variables
***************************************************#>
Param(

    [Parameter(Mandatory=$false)]
    [switch]$logAzureFirewall,
    [Parameter(Mandatory=$false)]
    [switch]$logThirdpartyFirewall,
    [Parameter(Mandatory=$false)]
    [switch]$logAzureADAuth,
    [Parameter(Mandatory=$false)]
    [switch]$logNetflow,
    [Parameter(Mandatory=$false)]
    [switch]$logAzureFrontDoor,
    [Parameter(Mandatory=$false)]
    [switch]$logAzureAppGateway

    )

$errorActionPreference = "Stop"
# Write-output is used with Azure runbook to show what is happening, when returning
# a value the write-output in the function is added to the return value, causing
# errors.
$Global:jsonResults = ""
$collectedLogs = $false
<#***************************************************
                       Functions
***************************************************#>
function Get-LogAnalyticsData () {
    Param(

        [Parameter(Mandatory=$true)]
        $logPurpose,
        [Parameter(Mandatory=$true)]
        $logQuery
    
        )

    try {
        Write-Output "Querying Log Analytics Workspace for $logPurpose." 
        $results = Invoke-AzOperationalInsightsQuery -WorkspaceId $LogAnalyticWorkspaceID -Query $logQuery
    }
    catch {
        
        if ($logPurpose -eq "Azure AD Auth Logs"){
            Write-Error "Failed to query the Log Analytics Workspace for $logPurpose. Double-check if your Azure Active Directory Diagnostic Settings is enabled for ALL log types. New types were released and are expected. If, within last 90 minutes, you deployed this runbook to a newly configured firewall and Log Analytics workspace, please wait up to 90 minutes. If you still have errors, ensure Managed Identity has Reader access to the Log Analytics workspace, the Azure Firewall is sending diagnostic logs to the Log Analytics workspace, or verify the the Az.OperationalInsights module is installed in the Automation Account Module section. This is a fatal error and will exit the script."
        }
        else {
            Write-Error "Failed to query the Log Analytics Workspace for $logPurpose. Double-check if your the service's Diagnostic Settings is enabled for ALL log types. If, within last 90 minutes, you deployed this runbook to a newly configured firewall and Log Analytics workspace, please wait up to 90 minutes. If you still have errors, ensure Managed Identity has Reader access to the Log Analytics workspace, the Azure Firewall is sending diagnostic logs to the Log Analytics workspace, or verify the the Az.OperationalInsights module is installed in the Automation Account Module section. This is a fatal error and will exit the script."
        }
        Exit 0
    }
    
    try {
        Write-Output "Converting query results to JSON."
        $Global:jsonResults = $results.Results | convertto-json
    }
    catch {
        Write-Error "Failed to convert results to JSON. Sending logs in object format."
    }
}

function Send-LogsToCLAW () {
    Param(

        [Parameter(Mandatory=$true)]
        $logPurpose
    
        )

    try {
        Write-Output "Generating unique key name with json extension."
        $key = ($logPurpose.replace(" ","")) + (get-date -Format u).replace("-","").replace(" ","").replace(":","").replace("Z","").toString() + (".json")
    }
    catch {
        Write-Error "Failed to generate key. The key is the file in which the stream of JSON data is stored in the S3 bucket. Please rerun the script. If the error continues, manually create a unique key name until issue is resolved. This is a fatal error and will exit the script."
        Exit 0
    }
    
    try {
        Write-Output "Streaming/Uploading the results to the S3 bucket."
        Write-S3Object -BucketName $S3BucketName -stream $Global:jsonResults -key $key
    }
    catch {
        Write-Error "Failed to complete the stream/upload of the results, please manually run the Runbook again or wait until the next scheduled task to run the Runbook. If the problem continues verify the S3BucketName exists and is correct, trouble connectivity to the S3 bucket manually, or contact cloud administrator. This is a fatal error and will exit the script."
        Exit 0
    }
    
    Write-Output "SUCCESS: Upload of $logPurpose to CLAW complete."
}

Write-Output "Collecting variables from Automation Account."

try {
    $TenantId = Get-AutomationVariable -Name TenantId
}
catch {
    Write-Error "Failed to collect TenantId, please verify variable exists in the same Automation Account in which this script was run."
}

try {
    $LogAnalyticWorkspaceID = Get-AutomationVariable -Name LogAnalyticWorkspaceID
}
catch {
    Write-Error "Failed to collect LogAnalyticWorkspaceID, please verify variable exists in the same Automation Account in which this script was run."
}

try {
    $AWSAccessKey = Get-AutomationVariable -Name AWSAccessKey
}
catch {
    Write-Error "Failed to collect AWSAccessKey, please verify variable exists in the same Automation Account in which this script was run."
}

try {
    $AWSSecretKey = Get-AutomationVariable -Name AWSSecretKey
}
catch {
    Write-Error "Failed to collect AWSSecretKey, please verify variable exists in the same Automation Account in which this script was run."
}

try {
    $S3BucketName = Get-AutomationVariable -Name S3BucketName
}
catch {
    Write-Error "Failed to collect S3BucketName, please verify variable exists in the same Automation Account in which this script was run."
}

try {
    $AWSRegion = Get-AutomationVariable -Name AWSRegion
}
catch {
    Write-Error "Failed to collect S3BucketName, please verify variable exists in the same Automation Account in which this script was run."
}

try {
    Write-Output "Connecting to Azure Account as Automation Account Managed Identity."
    Connect-AzAccount -Identity -TenantId $TenantId | out-null
}
catch {
    Write-Error "Failed to connect to Azure. Verify Managed Identity for Automation Account is assigned Log Analytics Reader to your Log Analytics workspace, or verify the the Az.Account module is installed in the Automation Account Module section. This is a fatal error and will exit the script."
    Exit 0
}

try {
    Write-Output ("Setting AWS Region to" + $AWSRegion)
    Set-DefaultAWSRegion -Region $AWSRegion | out-null
}
catch {
    Write-Error "Failed to set AWS Region. Please verify there is a value in the varible AWSRegion and that it is the correct region. This is a fatal error and will exit the script."
    Exit 0
}

try {
    Write-Output "Connecting to AWS Account."
    Set-AWSCredential -AccessKey $AWSAccessKey -SecretKey $AWSSecretKey -StoreAs default
}
catch {
    Write-Error "Failed to connect to AWS account. Verify the AccessKey and AccessSecret are valid and make sure the AWSPowerShell module is installed in the Automation Account Module section. This is a fatal error and will exit the script."
    Exit 0
}

if ($logThirdpartyFirewall){
    $purpose = "Third-party Firewall Logs"
    $query = "Syslog | where TimeGenerated > ago(15m)"
    Get-LogAnalyticsData $purpose $query
    If($Global:jsonResults){
        Send-LogsToCLAW $purpose
        $collectedLogs = $true
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 15 minutes to upload."
        $collectedLogs = $true
    }
}

if ($logAzureADAuth){
    $purpose = "Azure AD Auth Logs"
    $query = "AuditLogs
    | union SigninLogs
    | union AADNonInteractiveUserSignInLogs
    | union AADServicePrincipalSignInLogs
    | union AADManagedIdentitySignInLogs
    | union AADProvisioningLogs
    | union ADFSSignInLogs
    | union AADRiskyUsers
    | union AADUserRiskEvents
    | union AADRiskyServicePrincipals
    | union AADServicePrincipalRiskEvents
    | where TimeGenerated > ago(15m)
        | extend ResourceId = replace_regex(ResourceId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?', 'REDACTED')
        | extend TenantId = replace_regex(TenantId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?', 'REDACTED')"
    Get-LogAnalyticsData $purpose $query
    If($Global:jsonResults){
        Send-LogsToCLAW $purpose
        $collectedLogs = $true
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 15 minutes to upload."
        $collectedLogs = $true
    }
}

if ($logNetflow){
    $purpose = "Netflow Logs"
    $query = "AzureNetworkAnalytics_CL
    | where TimeGenerated > ago(15m)
    | where SubType_s == 'FlowLog'
        | extend Subscription_g = replace_regex(Subscription_g, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?$', 'REDACTED')
        | extend Subscription1_g = replace_regex(Subscription1_g, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?$', 'REDACTED')
        | extend Subscription2_g = replace_regex(Subscription2_g, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?$', 'REDACTED')
        | extend _SubscriptionId = replace_regex(_SubscriptionId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?$', 'REDACTED')
        | extend SubscriptionName_s = replace_regex(SubscriptionName_s, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?$', 'REDACTED')
        | extend TenantId = replace_regex(TenantId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?$', 'REDACTED')
        | extend Type = replace_string(Type, 'AzureNetworkAnalytics_CL', 'NetFlow')
        | project-rename Category = Type"
    Get-LogAnalyticsData $purpose $query
    If($Global:jsonResults){
        Send-LogsToCLAW $purpose
        $collectedLogs = $true
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 15 minutes to upload."
        $collectedLogs = $true
    }
}

if ($logAzureFrontDoor){
    $purpose = "Azure Front Door Logs"
    $query = "AzureDiagnostics 
    | where TimeGenerated > ago(15m)
    | where ResourceType == 'FRONTDOORS'
        and (isnotempty(details_matches_s))
        and Category == 'FrontdoorWebApplicationFirewallLog' or Category == 'FrontdoorAccessLog'
        | extend SubscriptionId = replace_regex(SubscriptionId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?$', 'REDACTED')
        | extend _SubscriptionId = replace_regex(_SubscriptionId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?$', 'REDACTED')
        | extend ResourceId = replace_regex(ResourceId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?', 'REDACTED')
        | extend _ResourceId = replace_regex(_ResourceId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?', 'REDACTED')
        | extend TenantId = replace_regex(TenantId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?', 'REDACTED')"
    Get-LogAnalyticsData $purpose $query
    If($Global:jsonResults){
        Send-LogsToCLAW $purpose
        $collectedLogs = $true
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 15 minutes to upload."
        $collectedLogs = $true
    }
}

if ($logAzureAppGateway){
    $purpose = "Azure App Gateway Logs"
    $query = "AzureDiagnostics 
    | where TimeGenerated > ago(15m)
    | where ResourceProvider == 'MICROSOFT.NETWORK'
        and (isnotempty(requestUri_s))
        and Category == 'ApplicationGatewayFirewallLog' or Category == 'ApplicationGatewayAccessLog'
        | extend SubscriptionId = replace_regex(SubscriptionId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?$', 'REDACTED')
        | extend _SubscriptionId = replace_regex(_SubscriptionId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?$', 'REDACTED')
        | extend ResourceId = replace_regex(ResourceId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?', 'REDACTED')
        | extend _ResourceId = replace_regex(_ResourceId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?', 'REDACTED')
        | extend TenantId = replace_regex(TenantId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?', 'REDACTED')"
    Get-LogAnalyticsData $purpose $query
    If($Global:jsonResults){
        Send-LogsToCLAW $purpose
        $collectedLogs = $true
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 15 minutes to upload."
        $collectedLogs = $true
    }
}

if (($logAzureFirewall) -or (!$collectedLogs)){
    $purpose = "Azure Firewall Logs"
    $query = "AzureDiagnostics 
    | where TimeGenerated > ago(15m) 
    | where Category == 'AzureFirewallNetworkRule' or Category == 'AzureFirewallApplicationRule' 
        | extend SubscriptionId = replace_regex(SubscriptionId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?$', 'REDACTED')
        | extend _SubscriptionId = replace_regex(_SubscriptionId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?$', 'REDACTED')
        | extend ResourceId = replace_regex(ResourceId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?', 'REDACTED')
        | extend _ResourceId = replace_regex(_ResourceId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?', 'REDACTED')
        | extend TenantId = replace_regex(TenantId, @'([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?', 'REDACTED')"
    Get-LogAnalyticsData $purpose $query
    If($Global:jsonResults){
        Send-LogsToCLAW $purpose
        $collectedLogs = $true
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 15 minutes to upload."
    }
}