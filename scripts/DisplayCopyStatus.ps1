<#
.SYNOPSIS
Monitors copy operations on ARM
.DESCRIPTION
This script provides the capability to monitor copy operations for ARM-based storage accounts.
.PARAMETER ResourceGroupName
The resource group name where the storage account is located.
.PARAMETER StorageAccountName
The storage account name of the storage account to monitor
.PARAMETER Continuous
This optional parameter takes an integer and continuously displays the status every N seconds.  If the parameter is 0 then the status is only displayed once.
.PARAMETER PendingOnly
If this switch is set then the command will only display those disk copy operations that are "Pending" (AKA "in progress).
#>

[CmdletBinding()]

param(
    [Parameter(Mandatory=$True)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$True)]
    [string]$StorageAccountName,

    [Parameter(Mandatory=$False)]
    [int64]$Continuous=0,

    [Parameter(Mandatory=$False)]
    [switch]$PendingOnly
)

$gKBCalc = 1024
$gMBCalc = $gKBCalc * 1024
$gGBCalc = $gMBCalc * 1024

function DisplayStatus {
    param (
        [Parameter(Mandatory=$True)]
        [PSObject[]]$blobs
    )

    $time = Get-Date

    Write-Host ("{0} - {1}::{2} storage account status" -f $time.ToString("HH:mm:ss"), $ResourceGroupName, $StorageAccountName)
    Write-Host "=============================================================="

    $somethingWritten = 0

    foreach ( $blob in $blobs ) {
        $blobCopyState = $blob | Get-AzureStorageBlobCopyState -ErrorAction SilentlyContinue

        if ( $blobCopyState -ne $null ) {
		    if ( $PendingOnly -eq $False -or ($PendingOnly -eq $True -and $blobCopyState.Status -eq "Pending") ) {
            	$somethingWritten++
            	Write-Host ("{0}: {1} {2:f2}% complete ({3:f2}GB of {4:f2}GB copied)" `
                	-f $blob.Name, `
                   	   $blobCopyState.Status, `
                   	   ($blobCopyState.BytesCopied/$blobCopyState.TotalBytes*100.0),
                   	   ($blobCopyState.BytesCopied/$gGBCalc),
                   	   ($blobCopyState.TotalBytes/$gGBCalc))
       		}
       }
    }

    if ( $somethingWritten -eq 0 ) {
        Write-Host "Nothing to report"
    }

    Write-Host ""

    return ""
}

$accountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Value[0]

$context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $accountKey

if ( $Continuous -gt 0 ) {
    do {
        $blobs = @(Get-AzureStorageBlob -Container vhds -Context $context)
        DisplayStatus $blobs
        sleep $Continuous
    }
    while ( $True -eq $True )
}
else {
    $blobs = @(Get-AzureStorageBlob -Container vhds -Context $context)
    DisplayStatus $blobs
}
