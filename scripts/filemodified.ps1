$keyVault = Get-AutomationVariable -Name keyvault
$secretName = Get-AutomationVariable -Name secretname
$storageAccountName = Get-AutomationVariable -Name storageaccountname
$fileshare = Get-AutomationVariable -Name fileshare

try {
    # Read from Key Vault using managed identity
    $connection = Connect-AzAccount -identity
    $readSecret = Get-AzKeyVaultSecret -VaultName $keyVault -Name $secretName -AsPlainText
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage
    $ErrorActionPreference = "Stop"
}

$startTimer = Get-Date
$ArrayOfFiles = @()

$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $readSecret

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
            Write-Output "it was last modified $($deadline.Hours) hours ago"
            if ($deadline.Hours -gt 1) {
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
        Write-Output "it was last modified $($deadline.Hours) hours ago"
        if ($deadline.Hours -gt 1) {
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