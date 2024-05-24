<#
    .SYNOPSIS
        This PowerShell script is designed to interact with the KnowBe4 PhishER API.     
        Its key features are extracting the BCL value from the message headers and 
        confidence levels from the PhishML report.
    .DESCRIPTION
        The script contains a function `Get-PhisherMessagesAll` returns phishing messages that match Threat or Spam.
        It then iterates over each node returned by the API call. For each node, it creates a custom object with properties
        BCL, Category, ThreatConfidence, SpamConfidence, ReportedBy, From, and Subject. The ThreatConfidence and SpamConfidence
        values are extracted from the PhishML report. The BCL value is extracted from the message headers. The custom objects
        are added to a hashset and the script continues to fetch and process messages. Finally, the script outputs the hashset
        of custom objects as a report.
#>

# Functions
function Get-PhisherMessagesAll {
    <#
        .SYNOPSIS
            This function makes an API call to the KnowBe4 PhishER API.
            Pagination is kept at 50 to reduce timeout errors.
            Designed to return phishing messages that match the query.
        .PARAMETER token
            Your PhishER API token.
        .PARAMETER page
            The page number you want to receive (default is 1).
        .PARAMETER luceneQuery
            A Lucene query string (default is ‘category:threat OR category:spam’).
    #>
    
    param (
        [Parameter(Mandatory=$true)]
        [string]$token,

        [string]$luceneQuery = 'category:threat OR category:spam',

        [int]$page = 1
    )

    # api vars
    $url = 'https://training.knowbe4.com/graphql'
    $query = @"
    {
        phisherMessages(all: true, page: $page, per: 50, query: "$luceneQuery") {
            nodes {
                category
                phishmlReport {
                    confidenceClean
                    confidenceSpam
                    confidenceThreat
                }   
                reportedBy
                from
                subject
                id
                headers {
                    data
                }
            }
            pagination {
                page
                per
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
} #end function

# vars
$messages = [Collections.Generic.Hashset[PSCustomObject]]@()
$page = 1

# Iterate over each node returned by the API call 
do {
    $nodes = (Get-PhisherMessagesAll -token $token -page $page).data.phisherMessages.nodes
    foreach ($node in $nodes) {
        # create a custom object
        $obj = [PSCustomObject]@{
            BCL = ($node | Select-Object -expand headers | Where-Object {$_.data -like "BCL*"})[0].data[4]
            Category = $node.category
            ThreatConfidence = [math]::Round((($node | Select-Object -expand phishmlreport).confidenceThreat * 100), 1) 
            SpamConfidence = [math]::Round((($node | Select-Object -expand phishmlreport).confidenceSpam * 100), 1)
            ReportedBy = $node.reportedBy
            From = $node.from
            Subject = $node.subject
        }
        
        # add it to the hashset
        [void]$messages.Add($obj)
        $obj = $null
    }

    # then check for messages beyond page 1 (50 per)
    $page++
} while ($nodes.count -eq 50)

# output report
$messages | Out-GridView