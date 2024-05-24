function Get-KB4Enrollments.ps1 {
    <#
        .SYNOPSIS
            This function is designed to retrieve and display a list of training enrollments from the KnowBe4 API.
        .DESCRIPTION
            This function begins by defining the base URL for the KnowBe4 API and appending the specific endpoint for training enrollments.
            It then constructs the necessary headers for the API request, including the authorization token provided as a parameter.
            The function uses curl.exe to make a silent API call and pipes the JSON response to convertfrom-json to parse it into a PowerShell object.
        .PARAMETER token
            Your KnowBe4 reporting API token.
        .EXAMPLE
            PS> Get-KB4Enrollments -token 'your_reporting_token'
    #>
    
    param (
        [Parameter(Mandatory=$true)]
        [string]$token
    )

    # vars
    $baseURL = 'https://us.api.knowbe4.com'
    $uri = $baseURL + '/v1/training/enrollments'
    $hdrs = "Authorization: Bearer $token"

    # call API
    $response = curl.exe --url $uri --header $hdrs --silent | convertfrom-json

    # output
    $enrollments = $response | 
        Select-Object enrollment_id, module_name, campaign_name, enrollment_date,
        @{Name='First'; Expression={$_.User.first_name}}, @{Name='Last'; Expression={$_.User.last_name}}, @{Name='Email'; Expression={$_.User.email}},
        status, start_date, completion_date, time_spent

    return $enrollments
}