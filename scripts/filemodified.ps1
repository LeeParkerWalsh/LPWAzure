$storageAccountName = Get-AutomationVariable -Name storageaccountname
$fileshare = Get-AutomationVariable -Name fileshare

try {
    $connection = Connect-AzAccount -identity
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage
    $ErrorActionPreference = "Stop"
}

$startTimer = Get-Date
$ArrayOfFiles = @()

$context = New-AzStorageContext -StorageAccountName $storageAccountName -EnableFileBackupRequestIntent

#define function to list files in child dir
function listFiles([string]$path) { 
    $file1s = $null
    $file1s = Get-AzStorageFile -ShareName $fileShare -Context $context -Path $path | Get-AzStorageFile  
    foreach ($file1 in $file1s) {     
        if ($file1.GetType().name -eq "AzureStorageFile") {
            Write-Output ("Last Modified Date of the file $($file1.Name) is $($file1.LastModified.DateTime)") 
            $file1path = $file1.ShareFileClient.Path
            Write-Output ("it's path is: $($file1path)")
            $deadline = $startTimer - $file1.LastModified.DateTime
            Write-Output "it was last modified $([Math]::Floor([decimal]($deadline.TotalHours))) hours ago"
            #Using TotalHours for example. Math Floor always rounds down.
            if ($deadline.TotalHours -gt 10) {
                Remove-AzStorageFile -ShareName $fileshare -Context $context -path $file1path -WhatIf
                $global:ArrayOfFiles += $file1path
            }
        }
        elseif ($file1.GetType().Name -eq "AzureStorageFileDirectory") {          
            listFiles($file1.ShareDirectoryClient.Path)
        }
        else {
            Write-Output "Placeholder for weirdness"
        }
    }   
}

#list files in root dir, else path to function to handle directories
$files = Get-AzStorageFile -ShareName $fileShare -Context $context 
 
foreach ($file in $files) {
    if ($file.GetType().name -eq "AzureStorageFile") {  
        Write-Output ("Last Modified Date of the file $($file.Name) is $($file.LastModified.DateTime)")
        $filepath = $file.ShareFileClient.Path
        Write-Output ("it's path is: $($filepath)")
        $deadline = $startTimer - $file.LastModified.DateTime
        Write-Output "it was last modified $([Math]::Floor([decimal]($deadline.TotalHours))) hours ago"
        #Using TotalHours for example. Math Floor always rounds down.
        if ($deadline.TotalHours -gt 10) {
            Remove-AzStorageFile -ShareName $fileshare -Context $context -path $filepath -WhatIf
            $global:ArrayOfFiles += $filepath
        }
    }
    else {
    
        listFiles($file.Name)
    }
}

Write-Output ""
Write-Output "The following files would have been deleted:"
$ArrayOfFiles

#Variables for message sending function
$title = "$($MyInvocation.MyCommand.Name) results"
$summary = $MyInvocation.MyCommand.Name #Runbook Name
$webhook = Get-AutomationVariable -Name webhook
$text = ""

if ($ArrayOfFiles.Length -eq 0) {
    $text = "No files deleted this run"
}
else {
    $text = "The following files could have been deleted:"
    foreach ($output in $ArrayOfFiles) {
        $text += "\n\n $($output)"
    }
}

function sendMessage {

    param (
        $title,
        $summary,
        $uri,
        $text
    )

    $JSONBody = [PSCustomObject][Ordered]@{
        "@Type" = "MessageCard"
        "@Context" = "<http://schema.org/extensions>"
        "summary" = $summary
        "themeColor" = '0078D7'
        "title" = $title
        "text" = $text

    }

    $MessageBody = ConvertTo-Json $JSONBody
    $MessageBody = $MessageBody.Replace('\\n','\n') #Dealing with ConvertTo-Json and escape characters

    $parameters = @{
        "URI" = $uri
        "Method" = 'POST'
        "Body" = $MessageBody
        "ContentType" = 'application/json'
    }

Invoke-RestMethod @parameters
}

sendMessage -title $title -summary $summary -text $text -uri $webhook