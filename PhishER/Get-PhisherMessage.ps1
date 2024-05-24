function Get-PhisherMessage {
    <#
        .SYNOPSIS
            This function makes an API call to the KnowBe4 PhishER API
            to retrieve individual message details.
        .PARAMETER token
            Your PhishER API token.
        .PARAMETER id
            This is the GUID assigned to the message by PhishER.
            This value may need to retrieved programatically.
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$token,

        [Parameter(Mandatory=$true)]
        [string]$id
    )
    # api vars
    $url = 'https://training.knowbe4.com/graphql'
    $query = @"
    {
        phisherMessage(id:"$id") {
            actionStatus
            phishmlReport {
                confidenceClean
                confidenceSpam
                confidenceThreat
            }
        }
    }
"@

    $body = @{
        "query" = $query
    } | ConvertTo-Json

    # API call
    $response = Invoke-RestMethod -Uri $url -Authentication Bearer -Token ($token | ConvertTo-SecureString -AsPlainText) -ContentType 'application/json' -Body $body -Method Post
    
    return $response
}