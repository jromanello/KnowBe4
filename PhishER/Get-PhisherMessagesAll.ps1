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
}