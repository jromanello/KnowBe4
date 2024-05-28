# KnowBe4 API PowerShell Scripts

## Get-KB4Enrollments.ps1
### Synopsis
Retrieves and displays a list of training enrollments from the KnowBe4 API.
### Description
- Defines the base URL for the KnowBe4 API.
- Appends the endpoint for training enrollments.
- Constructs headers with the authorization token.
- Uses `curl.exe` to make a silent API call.
- Pipes the JSON response to `convertfrom-json` to parse it into a PowerShell object.
### Parameter
- `token`: Your KnowBe4 reporting API token.

## Format-PhisherInbox
### Synopsis
Interacts with the KnowBe4 PhishER API to extract BCL values from message headers and confidence levels from the PhishML report.
### Description
- Contains a function `Get-PhisherMessagesAll`.
- Iterates over each node returned by the API call.
- Creates a custom object with properties: BCL, Category, ThreatConfidence, SpamConfidence, ReportedBy, From, and Subject.
- Extracts values from the PhishML report and message headers.
- Adds custom objects to a hashset.
- Outputs the hashset of custom objects as a report.

## Get-PhisherMessage
### Synopsis
Makes an API call to retrieve individual message details from the KnowBe4 PhishER API.
### Parameters
- `token`: Your PhishER API token.
- `id`: The GUID assigned to the message by PhishER, may need to be retrieved programmatically.

## Get-PhisherMessagesAll
### Synopsis
Makes an API call to return phishing messages that match the query.
### Parameters
- `token`: Your PhishER API token.
- `page`: The page number you want to receive (default is 1).
- `luceneQuery`: A Lucene query string (default is 'category:threat OR category:spam').
