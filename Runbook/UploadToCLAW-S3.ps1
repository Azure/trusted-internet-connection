<#PSScriptInfo

.VERSION 
    1.8

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
    https://github.com/MicrosoftDocs/Trusted-Internet-Connection/blob/main/LICENSE

.PROJECTURI 
    https://github.com/MicrosoftDocs/Trusted-Internet-Connection

.ICONURI

.EXTERNALMODULEDEPENDENCIES 
    https://www.powershellgallery.com/packages/AWSPowerShell/

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES 
    https://github.com/MicrosoftDocs/Trusted-Internet-Connection

.LINK  
    https://github.com/MicrosoftDocs/Trusted-Internet-Connection
    
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
    
https://github.com/MicrosoftDocs/Trusted-Internet-Connection

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
    [switch]$logAzureFrontDoor

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
        Write-Error "Failed to query the Log Analytics Workspace for $logPurpose. Ensure SPN has `
        Reader access to the Log Analytics workspace, the SPN secret is valid, the Azure Firewall `
        is sending diagnostic logs to the Log Analytics workspace, or verify the the `
        Az.OperationalInsights module is installed in the Automation Account `
        Module section. This is a fatal error and will exit the script."
        Exit 0
    }
    
    try {
        Write-Output "Converting query results to JSON."
        $Global:jsonResults = $results.Results | convertto-json
    }
    catch {
        Write-Error "Failed to convert results to JSON. Sending logs in object `
        format."
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
        Write-Error "Failed to generate key. The key is the file in which the `
        stream of JSON data is stored in the S3 bucket. Please rerun the script `
        If the error continues, manually create a unique key name until issue is `
        resolved. This is a fatal error and will exit the script."
        Exit 0
    }
    
    try {
        Write-Output "Streaming/Uploading the results to the S3 bucket."
        Write-S3Object -BucketName $S3BucketName -stream $Global:jsonResults -key $key
    }
    catch {
        Write-Error "Failed to complete the stream/upload of the results `
        Please manually run the Runbook again or wait until the next scheduled `
        task to run the Runbook. If the problem continues verify `
        the S3BucketName exists and is correct, trouble connectivity to the S3 `
        bucket manually, or contact cloud administrator. This is a fatal error `
        and will exit the script."
        Exit 0
    }
    
    Write-Output "SUCCESS: Upload of $logPurpose to CLAW complete."
}

Write-Output "Collecting variables from Automation Account."

try {
    $TenantId = Get-AutomationVariable -Name TenantId
}
catch {
    Write-Error "Failed to collect TenantId, please verify variable exists `
    in the same Automation Account in which this script was run."
}

try {
    $EnterpriseApplicationId = Get-AutomationVariable -Name EnterpriseApplicationId
}
catch {
    Write-Error "Failed to collect EnterpriseApplicationId, please verify variable exists `
    in the same Automation Account in which this script was run."
}

try {
    $EnterpriseApplicationSecret = Get-AutomationVariable -Name EnterpriseApplicationSecret
}
catch {
    Write-Error "Failed to collect EnterpriseApplicationSecret, please verify variable exists `
    in the same Automation Account in which this script was run."
}

try {
    $LogAnalyticWorkspaceID = Get-AutomationVariable -Name LogAnalyticWorkspaceID
}
catch {
    Write-Error "Failed to collect LogAnalyticWorkspaceID, please verify variable exists `
    in the same Automation Account in which this script was run."
}

try {
    $AWSAccessKey = Get-AutomationVariable -Name AWSAccessKey
}
catch {
    Write-Error "Failed to collect AWSAccessKey, please verify variable exists `
    in the same Automation Account in which this script was run."
}

try {
    $AWSSecretKey = Get-AutomationVariable -Name AWSSecretKey
}
catch {
    Write-Error "Failed to collect AWSSecretKey, please verify variable exists `
    in the same Automation Account in which this script was run."
}

try {
    $S3BucketName = Get-AutomationVariable -Name S3BucketName
}
catch {
    Write-Error "Failed to collect S3BucketName, please verify variable exists `
    in the same Automation Account in which this script was run."
}

try {
    Write-Output "Generating Secure Password from variable."
    $SecurePassword = ConvertTo-SecureString -AsPlainText -Force -String $EnterpriseApplicationSecret
}
catch {
    Write-Error "Failed to convert `$EnterpriseApplicationSecret into a `
    Secure String. This is a fatal error and will exit the script. Ensure `
    the variable EnterpriseApplicationSecret exists and is not empty."
    Exit 0
}

try {
    Write-Output "Generating SPN Credential."
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($EnterpriseApplicationId, $SecurePassword)
}
catch {
    Write-Error "Failed to create credential to connect to Azure as the SPN. `
    This is a fatal error ad will exit the script. Ensure the variable `
    EnterpriseApplicationId exists and is not empty."
}

try {
    Write-Output "Disabling SPN credential autosave."
    Disable-AzContextAutosave | out-null
}
catch {
    Write-Error "Failed to disable SPN credential autosave to the following `
    location: 'C:\Users\username01\.Azure'. Please ensure that this `
    directory has appropriate protections."
}

try {
    Write-Output "Connecting to Azure Account as SPN."
    Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential | out-null
}
catch {
    Write-Error "Failed to connect to Azure. Verify credentials are valid, `
    the SPN is enabled, has access to the tenant, or verify the the `
    Az.Account module is installed in the Automation Account `
    Module section. This is a fatal error and will exit the script."
    Exit 0
}

try {
    Write-Output "Connecting to AWS Account."
    Set-AWSCredential -AccessKey $AWSAccessKey -SecretKey $AWSSecretKey -StoreAs default
}
catch {
    Write-Error "Failed to connect to AWS account. Verify the AccessKey and `
    AccessSecret are valid and make sure the AWSPowerShell module is installed `
    in the Automation Account Module section. This is a fatal error and `
    will exit the script."
    Exit 0
}

if ($logThirdpartyFirewall){
    $purpose = "Third-party Firewall Logs"
    $query = "Syslog | where TimeGenerated > ago(60m)"
    Get-LogAnalyticsData $purpose $query
    If($Global:jsonResults){
        Send-LogsToCLAW $purpose
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 60 minutes to upload."
        $collectedLogs = $true
    }
}

if ($logAzureADAuth){
    $purpose = "Azure AD Auth Logs"
    $query = "SigninLogs 
    | where TimeGenerated > ago(60m) 
    | project 
        UserDisplayName,
        Identity,
        UserPrincipalName,
        AppDisplayName,
        AppId,
        ResourceDisplayName"
    Get-LogAnalyticsData $purpose $query
    If($Global:jsonResults){
        Send-LogsToCLAW $purpose
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 60 minutes to upload."
        $collectedLogs = $true
    }
}

if ($logNetflow){
    $purpose = "Netflow Logs"
    $query = "AzureNetworkAnalytics_CL
    | where SubType_s == 'FlowLog'
        and (FASchemaVersion_s == '1' or FASchemaVersion_s == '2')
    | where TimeGenerated > ago(60m)
    | extend VMFields  = split(VM1_s, '/')
    | extend VMName  = tostring(VMFields[1]) 
    | project
        TimeProcessed_t,
        SrcIP_s,
        Hostname,
        FlowDirection_s,
        L4Protocol_s,
        L7Protocol_s,
        DestPort_d,
        FlowType_s,
        AllowedOutFlows_d,
        DeniedOutFlows_d,
        OutboundBytes_d,
        InboundBytes_d,
        OutboundPackets_d,
        InboundPackets_d,
        AzureRegion_s,
        Region1_s"
    Get-LogAnalyticsData $purpose $query
    If($Global:jsonResults){
        Send-LogsToCLAW $purpose
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 60 minutes to upload."
        $collectedLogs = $true
    }
}

if ($logAzureFrontDoor){
    $purpose = "Azure Front Door Logs"
    $query = "AzureDiagnostics 
    | where ResourceType == 'FRONTDOORS'
        and (isnotempty(details_matches_s))
        and Category == 'FrontdoorWebApplicationFirewallLog' or Category == 'FrontdoorAccessLog'
    | where TimeGenerated > ago(60m)
    | parse requestUri_s with Proto '://' TargetIP ':' TargetPort '/' Info
    | extend Action = iff(isempty(action_s),tostring(httpStatusCode_s),action_s)
    | extend Protocol = tostring(requestProtocol_s), 
        SourceIP = tostring(clientIp_s),
        SourcePort = tostring(clientPort_s)
    | extend Protocol = case(Protocol == '', Proto,tostring(requestProtocol_s)),
        SourceIP = case(SourceIP == '', tostring(clientIP_s), tostring(clientIp_s))
    | project 
        TimeGenerated,
        Protocol,
        SourceIP,
        SourcePort,
        TargetIP,
        TargetPort,
        Action"
    Get-LogAnalyticsData $purpose $query
    If($Global:jsonResults){
        Send-LogsToCLAW $purpose
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 60 minutes to upload."
        $collectedLogs = $true
    }
}

if (($logAzureFirewall) -or (!$collectedLogs)){
    $purpose = "Azure Firewall Logs"
    $query = "AzureDiagnostics 
    | where Category == 'AzureFirewallNetworkRule' or Category == 'AzureFirewallApplicationRule' 
    | where TimeGenerated > ago(60m)
    | parse msg_s with Protocol ' request from ' SourceIP ':' SourcePortInt: int ' to ' TargetIP ':' TargetPortInt: int* 
    | parse msg_s with *'. Action: ' Action1a | parse msg_s with *' was ' Action1b ' to ' NatDestination 
    | parse msg_s with Protocol2 ' request from ' SourceIP2 ' to ' TargetIP2 '. Action: ' Action2 
    | extend SourcePort = tostring(SourcePortInt), TargetPort = tostring(TargetPortInt) 
    | extend Action = case(Action1a == '', 
        case(Action1b == '', Action2, Action1b), Action1a),
        Protocol = case(Protocol == '', Protocol2, Protocol),
        SourceIP = case(SourceIP == '', SourceIP2, SourceIP),
        TargetIP = case(TargetIP == '', TargetIP2, TargetIP),
        SourcePort = case(SourcePort == '', 'N/A', SourcePort),
        TargetPort = case(TargetPort == '', 'N/A', TargetPort)
    | project 
        TimeGenerated,
        Protocol,
        SourceIP,
        SourcePort,
        TargetIP,
        TargetPort,
        Action"
    Get-LogAnalyticsData $purpose $query
    If($Global:jsonResults){
        Send-LogsToCLAW $purpose
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 60 minutes to upload."
    }
}