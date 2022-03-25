<#PSScriptInfo

.VERSION 
    1.11

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
        Write-Error "Failed to query the Log Analytics Workspace for $logPurpose. If, within last 90 minutes, you deployed this runbook to a newly configured firewall and Log Analytics workspace, please wait up to 90 minutes. If you still have errors, ensure Managed Identity has Reader access to the Log Analytics workspace, the Azure Firewall is sending diagnostic logs to the Log Analytics workspace, or verify the the Az.OperationalInsights module is installed in the Automation Account Module section. This is a fatal error and will exit the script."
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
    Write-Output "Connecting to Azure Account as Automation Account Managed Identity."
    Connect-AzAccount -Identity -TenantId $TenantId | out-null
}
catch {
    Write-Error "Failed to connect to Azure. Verify Managed Identity for Automation Account is assigned Log Analytics Reader to your Log Analytics workspace, or verify the the Az.Account module is installed in the Automation Account Module section. This is a fatal error and will exit the script."
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
    $query = "Syslog | where TimeGenerated > ago(30m)"
    Get-LogAnalyticsData $purpose $query
    If($Global:jsonResults){
        Send-LogsToCLAW $purpose
        $collectedLogs = $true
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 30 minutes to upload."
        $collectedLogs = $true
    }
}

if ($logAzureADAuth){
    $purpose = "Azure AD Auth Logs"
    $query = "SigninLogs 
    | where TimeGenerated > ago(30m) 
    | project 
        Category,
        TimeGenerated,
        OperationName,
        UserDisplayName,
        Identity,
        UserPrincipalName,
        AppDisplayName,
        AppId,
        ResourceDisplayName,
        AuthenticationDetails,
        AuthenticationProcessingDetails,
        ConditionalAccessPolicies,
        DeviceDetail"
    Get-LogAnalyticsData $purpose $query
    If($Global:jsonResults){
        Send-LogsToCLAW $purpose
        $collectedLogs = $true
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 30 minutes to upload."
        $collectedLogs = $true
    }
}

if ($logNetflow){
    $purpose = "Netflow Logs"
    $query = "let Category = 'NetFlow';
    AzureNetworkAnalytics_CL
    | where SubType_s == 'FlowLog'
        and (FASchemaVersion_s == '1' or FASchemaVersion_s == '2')
    | where TimeGenerated > ago(30m) 
    | extend VMFields  = split(VM1_s, '/')
    | extend VMName  = tostring(VMFields[1]) 
    | extend FlowType = tostring(FlowType_s), 
        SourceIP = tostring(SrcIP_s),
        TargetIP = tostring(DestIP_s),
        TartgetPort = tostring(DestPort_d),
        L4Protocol = tostring(L4Protocol_s),
        L7Protocol = tostring(L7Protocol_s),
        FlowDirection = tostring(FlowDirection_s),
        AllowedOutFlows = tostring(AllowedOutFlows_d),
        DeniedOutFlows = tostring(DeniedOutFlows_d),
        OutboundBytes = tostring(OutboundBytes_d),
        InboundBytes = tostring(InboundBytes_d),
        OutboundPackets = tostring(OutboundPackets_d),
        InboundPackets = tostring(InboundPackets_d),
        AzureRegion = tostring(AzureRegion_s),
        Region = tostring(Region1_s)
    | project
        Category,
        TimeGenerated,
        VMName,
        FlowDirection,
        FlowType,
        SourceIP,
        TargetIP,
        TartgetPort,
        L4Protocol,
        L7Protocol,
        AllowedOutFlows,
        DeniedOutFlows,
        OutboundBytes,
        InboundBytes,
        OutboundPackets,
        InboundPackets,
        AzureRegion,
        Region"
    Get-LogAnalyticsData $purpose $query
    If($Global:jsonResults){
        Send-LogsToCLAW $purpose
        $collectedLogs = $true
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 30 minutes to upload."
        $collectedLogs = $true
    }
}

if ($logAzureFrontDoor){
    $purpose = "Azure Front Door Logs"
    $query = "AzureDiagnostics 
    | where ResourceType == 'FRONTDOORS'
        and (isnotempty(details_matches_s))
        and Category == 'FrontdoorWebApplicationFirewallLog' or Category == 'FrontdoorAccessLog'
    | where TimeGenerated > ago(30m)
    | parse requestUri_s with Proto '://' TargetIP ':' TargetPort '/' Info
    | extend Protocol = tostring(requestProtocol_s), 
        SourceIP = tostring(clientIp_s),
        SourcePort = tostring(clientPort_s)
    | extend 
        Action = 
            iff(isempty(action_s),
                tostring(httpStatusCode_s),
                tostring(action_s)
            ),
        Protocol = 
            iif(isnotempty(Proto), 
                tostring(Proto), 
                tostring(requestProtocol_s)
            ),
        SourceIP = 
            iif(isnotempty(clientIP_s), 
                tostring(clientIP_s), 
                tostring(clientIp_s)
            )
    | project 
        Category,
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
        $collectedLogs = $true
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 30 minutes to upload."
        $collectedLogs = $true
    }
}

if ($logAzureAppGateway){
    $purpose = "Azure App Gateway Logs"
    $query = "AzureDiagnostics 
    | where ResourceProvider == 'MICROSOFT.NETWORK'
        and (isnotempty(requestUri_s))
        and Category == 'ApplicationGatewayFirewallLog' or Category == 'ApplicationGatewayAccessLog'
    | where TimeGenerated > ago(60m)
    | parse hostname_s with TargetIP ':' Port
    | parse serverRouted_s with InternalIP ':' Port2
    | extend 
        SourceIP = 
            iif(isnotempty(clientIP_s), 
                tostring(clientIP_s), 
                tostring(clientIp_s)
            ),
        SourcePort = 
            iif(isnotempty(clientPort_d), 
                trim('.0', tostring(clientPort_d)), 
                iif(isnotempty(Port), 
                    tostring(Port), 
                    iif(isnotempty(Port2), 
                        tostring(Port2), 
                        iif(isnotempty(sslEnabled_s), 
                            '443', 
                            '80'
                        )
                    )
                )
            ),
        TargetPort = 
            iif(isnotempty(Port), 
                tostring(Port), 
                iif(isnotempty(Port2), 
                    tostring(Port2), 
                    iif(isnotempty(sslEnabled_s), 
                        '443', 
                        '80'
                    )
                )
            ),
        TargetIP = 
            iif(isnotempty(hostname_s), 
                tostring(hostname_s),
                iif(isnotempty(originalHost_s), 
                    iif(tostring(originalHost_s) != '~.*' , 
                        tostring(originalHost_s),
                        tostring(Resource)
                    ),
                    tostring(Resource)
                )
            ),
        Protocol = 
            iif(isnotempty(httpVersion_s), 
                tostring(httpVersion_s), 
                iif(isnotempty(sslEnabled_s), 
                    'HTTPS', 
                    'HTTP'
                )
            ),
        Action = 
            iif(isnotempty(action_s), 
                tostring(action_s), 
                iif(isnotempty(WAFMode_s), 
                    tostring(WAFMode_s), 
                    iif(tostring(httpStatus_d) == '400' , 
                            'Bad Request', 
                            strcat('Http Status - ', replace_string(tostring(httpStatus_d), '.0',''))
                    )
                )
            )
    | project 
    Category,
    TimeGenerated,
    SourceIP,
    SourcePort,
    TargetIP,
    TargetPort,
    Message,
    Action"
    Get-LogAnalyticsData $purpose $query
    If($Global:jsonResults){
        Send-LogsToCLAW $purpose
        $collectedLogs = $true
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 30 minutes to upload."
        $collectedLogs = $true
    }
}

if (($logAzureFirewall) -or (!$collectedLogs)){
    $purpose = "Azure Firewall Logs"
    $query = "AzureDiagnostics 
    | where Category == 'AzureFirewallNetworkRule' or Category == 'AzureFirewallApplicationRule' 
    | where TimeGenerated > ago(30m) 
    | parse msg_s with Protocol1 ' request from ' SourceIP1 ':' SourcePortInt: int ' to ' TargetIP1 ':' TargetPortInt: int* 
    | parse msg_s with *'. Action: ' Action1a | parse msg_s with *' was ' Action1b ' to ' NatDestination 
    | parse msg_s with Protocol2 ' request from ' SourceIP2 ' to ' TargetIP2 '. Action: ' Action2 
    | extend
        SourceIP = 
            iif(isnotempty(SourceIP1), 
                tostring(SourceIP1), 
                tostring(SourceIP2)
            ),
        SourcePort = 
            iif(isnotempty(SourcePortInt), 
                tostring(SourcePortInt),
                'N/A'
            ),
        TargetPort = 
            iif(isnotempty(TargetPortInt), 
                 tostring(TargetPortInt),
                'N/A'
            ),
        TargetIP = 
            iif(isnotempty(TargetIP1), 
                tostring(TargetIP1), 
                tostring(TargetIP2)
            ),
        Protocol = 
            iif(isnotempty(Protocol1), 
                tostring(Protocol1), 
                tostring(Protocol2)
            ),
        Action = 
            iif(isnotempty(Action1a), 
                replace_string(tostring(Action1a), '.',''), 
                iif(isnotempty(Action1b), 
                    tostring(Action1b),
                    tostring(Action2)
                )
            )
    | project 
        Category,
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
        $collectedLogs = $true
    }
    else {
        Write-Output "COMPLETE: There are no $purpose within the last 30 minutes to upload."
    }
}