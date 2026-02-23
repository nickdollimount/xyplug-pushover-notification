<#
.SYNOPSIS
	xyOps Pushover notification plugin - Sends a Pushover notification via API.

.NOTES
	Author:         Nick Dollimount
	Copyright:      2026

	Please see the README.md file for full documentation.
#>

# MARK: Send-PushoverMessage
function Send-PushoverMessage {
    param(
        [Parameter(Mandatory = $true)][string]$UserKey,
        [Parameter(Mandatory = $true)][string]$APIKey,
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $false)][string]$Uri
    )

    $requestSplat = @{
        Uri = "https://api.pushover.net/1/messages.json"
        Method = "POST"
        ContentType = "application/json"
        Body = @{
            user = $UserKey
            token = $APIKey
            message = $Text
            title = $Title
            url = $Uri
        } | ConvertTo-Json -Depth 100
    }

    try {
        $results = Invoke-RestMethod @requestSplat | ConvertTo-Json -Depth 100 -Compress
        Write-Information -MessageData ([PSCustomObject]@{
            xy = 1
            code = 0
            description = "Pushover notification sent successfull!"
            details = $results
        } | ConvertTo-Json -Depth 100 -Compress) -InformationAction Continue
    }
    catch {
        Write-Information -MessageData ([PSCustomObject]@{
            xy = 1
            code = 9
            description = "Pushover notification failed!"
            details = $results
        } | ConvertTo-Json -Depth 100 -Compress) -InformationAction Continue
    }
}


# MARK: Begin

[PSCustomObject]$xyOps = ConvertFrom-Json -Depth 100 (Read-Host)

$pushoverUserKey = $xyOps.secrets."$($xyOps.params.userkeyvariable)"
$pushoverApiKey = $xyOps.secrets."$($xyOps.params.apikeyvariable)"

if (-not [string]::IsNullOrEmpty($xyOps.params.pushovernotificationtext)) {
    $pushoverNotificationText = $xyOps.params.pushovernotificationtext
}
else {
    $pushoverNotificationText = $xyOps.text -replace '(http[s]?|[s]?ftp[s]?)(:\/\/)([^\s,]+)',''
    $pushoverNotificationText += "`n"
    $pushoverNotificationText += $xyOps.job.output
}

if (-not [string]::IsNullOrEmpty($xyOps.params.pushovernotificationtitle)) {
    $pushoverNotificationTitle = $xyOps.params.pushovernotificationtitle
}
else {
    $pushoverNotificationTitle = "xyOps Alert"
}

if (-not [string]::IsNullOrEmpty($xyOps.params.pushovernotificationuri)) {
    $pushoverNotificationUri = $xyOps.params.pushovernotificationuri
}
else {
    $pushoverNotificationUri = $xyOps.links.job_details
}

Send-PushoverMessage -UserKey $pushoverUserKey -APIKey $pushoverApiKey -Title $pushoverNotificationTitle -Text $pushoverNotificationText -Uri $pushoverNotificationUri