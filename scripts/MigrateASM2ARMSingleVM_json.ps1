<#
.SYNOPSIS
Copies a single 'classic' (or Azure Service Manager) virtual machine (vm) to the new Resource Manager virtual machine standard.

.DESCRIPTION
This command copies from ASM to ARM for a single specified virtual machine.  It will create any necessary Resource Manager resources, stop the source VM, copy the disks, build the new ARM VM, and restart the 'source' VM (if necessary).

.PARAMETER ASMUsername
The username (or email address) associated with the ASM account.

.PARAMETER ASMPassword
The password for the ASM account in plain text.

.PARAMETER ARMUsername
The username (or email address) associated with the ARM account

.PARAMETER ARMPassword
The password for the ARM account in plain text.

.PARAMETER ASMSubscription
The string name of the subscription where the VM to be migrated is associated.

.PARAMETER ASMServiceName
The string name of the cloud service associated with the ASM VM to migrate to ARM

.PARAMETER ASMVMName
The string name of the VM to migrate from ASM to ARM

.PARAMETER tgtLocation
The Azure data center location to create the new VM and resources.

.PARAMETER tgtResourceGroupName
The name of the ARM resource group where the VM will be created.  If the resource group does not exist then it will be created.

.PARAMETER tgtStorageAccountName
The name of the storage account in the target environment.  If it does not exist then it will be created.

.PARAMETER tgtStorageAccountType
The type of storage to create under the storage account (Premium_LRS, Standard_GRS, Standard_LRS, Standard_RAGRS, Standard_ZRS).

.PARAMETER tgtNetworkName
The name of the network to be used to create a new VM in the address space.

.PARAMETER tgtNetworkPrefix
The address CIDR in the form of "0.0.0.0/0".

.PARAMETER tgtSubnetName
The name of the network subnet to be used to create a new VM in the address space.

.PARAMETER tgtSubnetPrefix
The subnet address CIDR in the form of "0.0.0.0/0".

.PARAMETER tgtIPAddress
The IP address that the VM wants to preserve.

.PARAMETER tgtAvailabilitySetName
The name of the availability set to place the new VM into.  If this set doesn't exist then it will be created.

.PARAMETER RestartSourceVM
If this parameter is passed then the source VM will be restarted as soon as the new Resource Manager VM is ready for creation.

.NOTES
Authors:
    Mike Johnson - mike.johnson@coretekservices.com
    Richard Sedlak - richard.sedlak@coretekservices.com

This script requires Azure cmdlet version 1.4.0 (or higher)

.INPUTS
    String parameters

.OUTPUTS
    Status as strings
#>

[CmdletBinding()]

param(
    [Parameter(Mandatory=$True)]
    [string]$ASMUsername,

    [Parameter(Mandatory=$True)]
    [string]$ASMPassword,

    [Parameter(Mandatory=$True)]
    [string]$ARMUsername,

    [Parameter(Mandatory=$True)]
    [string]$ARMPassword,

    [Parameter(Mandatory=$True)]
    [string]$ASMSubscription,

    [Parameter(Mandatory=$True)]
    [string]$ASMServiceName,

    [Parameter(Mandatory=$True)]
    [string]$ASMVMName,

    [Parameter(Mandatory=$True)]
    [string]$tgtLocation,

    [Parameter(Mandatory=$True)]
    [string]$tgtResourceGroupName,

    [Parameter(Mandatory=$True)]
    [string]$tgtStorageAccountName,

    [Parameter(Mandatory=$False)]
    [string]$tgtStorageAccountType="Standard_LRS",

    [Parameter(Mandatory=$True)]
    [string]$tgtNetworkName,

    [Parameter(Mandatory=$True)]
    [string]$tgtNetworkPrefix,

    [Parameter(Mandatory=$True)]
    [string]$tgtSubnetName,

    [Parameter(Mandatory=$True)]
    [string]$tgtSubnetPrefix,

    [Parameter(Mandatory=$False)]
    [string]$tgtIPAddress="NONE",

    [Parameter(Mandatory=$False)]
    [string]$tgtAvailabilitySetName="",

    [Parameter(Mandatory=$False)]
    [switch]$RestartSourceVM=$False
)


#region global variables

$gTimeFormat = "HH:mm:ss"
$gKBCalc = 1024
$gMBCalc = $gKBCalc * 1024
$gGBCalc = $gMBCalc * 1024

#endregion


#region Functions
function CopyDisk {

    param(
        [Parameter(Mandatory=$True)]
        [PSObject] $disk,

        [Parameter(Mandatory=$True)]
        [PSObject]$DestinationContext
    )

    $srcStorageAccountName = $disk.MediaLink.Host.Split('.')[0]

    Write-Verbose ("srcStorageAccount = {0}" -f $srcStorageAccount)

    <#
        CLI:
            help:    List the keys for a storage account
help:
help:    Usage: storage account keys list [options] <name>
help:
help:    Options:
help:      -h, --help               output usage information
help:      -v, --verbose            use verbose output
help:      -vv                      more verbose with debug output
help:      --json                   use json output
help:      -s, --subscription <id>  the subscription id
help:
help:    Current Mode: asm (Azure Service Management)


************** Don't know exactly how the following command works since we've been doing them disk by disk... This appears to be the entire storage account ************************

help:    Prepare storage account migration api validates and prepares the given storage account for IaaS Classic to ARM migrat
ion.
help:
help:    Usage: storage account prepare-migration [options] <name>
help:
help:    Options:
help:      -h, --help                         output usage information
help:      -v, --verbose                      use verbose output
help:      -vv                                more verbose with debug output
help:      --json                             use json output
help:      -n, --name <name>                  name
help:      -s, --subscription <subscription>  The subscription identifier
    #>
    $SourceStorageAccountKey=(Get-AzureStorageKey -StorageAccountName $srcStorageAccountName).Primary
    $SourceContext = New-AzureStorageContext -StorageAccountName $srcStorageAccountName -StorageAccountKey $SourceStorageAccountKey

    $DestinationSystemDiskName = "{0}.vhd" -f $disk.DiskName

    $startTime = Get-Date
    Write-Verbose ("Copy start: {0}" -f $startTime.ToString($gTimeFormat))

<#
    CLI:
help:    Start to copy the resource to the specified storage blob which completes asynchronously
help:      storage blob copy start [options] [sourceUri] [destContainer]
help:
help:    Show the copy status
help:      storage blob copy show [options] [container] [blob]
help:
help:    Stop the copy operation
help:      storage blob copy stop [options] [container] [blob] [copyid]
help:
help:    Options:
help:      -h, --help  output usage information
#>
    $SystemBlob = Start-AzureStorageBlobCopy -Context $SourceContext -AbsoluteUri $disk.MediaLink.AbsoluteUri -DestContainer "vhds" -DestBlob $DestinationSystemDiskName -DestContext $DestinationContext 

    $SystemBlob | Get-AzureStorageBlobCopyState

    [int64]$lastByteCount = 0

    $checkDuration = 60

    do {

        sleep $checkDuration

        $BlobCopyStatus = $SystemBlob | Get-AzureStorageBlobCopyState

        $bytesCopied = $BlobCopyStatus.BytesCopied

        $xferRate = ( ( ($bytesCopied - $lastByteCount) / $checkDuration) / $gMBCalc )

#        Write-Host ("{0} - copied {1:f2} GB of {2:f2} GB ({3:f2}%) [{4:f1} MB/s]" -f (Get-Date).ToString($gTimeFormat), ($bytesCopied/$gGBCalc), ($BlobCopyStatus.TotalBytes/$gGBCalc), (($BlobCopyStatus.BytesCopied/$BlobCopyStatus.TotalBytes)*100), $xferRate)

        $lastByteCount = [int64]$bytesCopied
    }
    while ( $BlobCopyStatus.Status -ne "Success" )

    $endTime = Get-Date
    Write-Verbose ("Copy end: {0}" -f $endTime.ToString($gTimeFormat))
    write-Verbose ""
    Write-Verbose ("{0} -> {1}" -f $startTime.ToString($gTimeFormat),$endTime.ToString($gTimeFormat))

    $lTimeSpan = New-TimeSpan -Start $startTime -End $endTime

 #   Write-Host ("{2:f2} GB copied in {0}:{1} at a {3:f1} MB/s transfer rate" -f $lTimeSpan.Minutes.ToString("00"), $lTimeSpan.Seconds.ToString("00"), ($bytesCopied / $gGBCalc), (($bytesCopied/$lTimeSpan.TotalSeconds) / $gMBCalc) )

    return [int64]$lastByteCount
}

#endregion


#region status stuff initialization
    $status = New-Object -TypeName PSObject
    Add-Member -InputObject $status -NotePropertyName "Status" -NotePropertyValue ""
    Add-Member -InputObject $status -NotePropertyName "Message" -NotePropertyValue ""
#endregion


#region initialization stuff for special version
<# Login stuff #>

<#
    Possible CLI equivalent:

        // Sets the cli working mode, valid names are 'arm' for resource manager and 'asm' for service management
        config mode [options] <name>

help:    Log in to an Azure subscription using Active Directory or a Microsoft account identity.
help:
help:    Usage: login [options]
help:
help:    Options:
help:      -h, --help                            output usage information
help:      -v, --verbose                         use verbose output
help:      -vv                                   more verbose with debug output
help:      --json                                use json output
help:      -u --username <username>              user name or service principal ID. If multifactor authentication is required,
 you will be prompted to use the login command without parameters for interactive support.
help:      -e --environment [environment]        Environment to authenticate against, such as AzureChinaCloud; must support Ac
tive Directory.
help:      -p --password <password>              user password or service principal secret, will prompt if not given.
help:      --service-principal                   If given, log in as a service principal rather than a user.
help:      --certificate-file <certificateFile>  A PEM encoded certificate private key file.
help:      --thumbprint <thumbprint>             A hex encoded thumbprint of the certificate.
help:      --tenant <tenant>                     Tenant domain or ID to log into.
help:      -q --quiet                            do not prompt for confirmation of PII storage.
#>
$passwd = ConvertTo-SecureString $ASMPassword -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential ( $ASMUsername, $passwd )
Add-AzureAccount -Credential $credential | Out-Null

<#
help:    Log in to an Azure subscription using Active Directory or a Microsoft account identity.
help:
help:    Usage: login [options]
help:
help:    Options:
help:      -h, --help                            output usage information
help:      -v, --verbose                         use verbose output
help:      -vv                                   more verbose with debug output
help:      --json                                use json output
help:      -u --username <username>              user name or service principal ID. If multifactor authentication is required,
 you will be prompted to use the login command without parameters for interactive support.
help:      -e --environment [environment]        Environment to authenticate against, such as AzureChinaCloud; must support Ac
tive Directory.
help:      -p --password <password>              user password or service principal secret, will prompt if not given.
help:      --service-principal                   If given, log in as a service principal rather than a user.
help:      --certificate-file <certificateFile>  A PEM encoded certificate private key file.
help:      --thumbprint <thumbprint>             A hex encoded thumbprint of the certificate.
help:      --tenant <tenant>                     Tenant domain or ID to log into.
help:      -q --quiet                            do not prompt for confirmation of PII storage.
help:
help:    Current Mode: arm (Azure Resource Management)
#>
$passwd = ConvertTo-SecureString $ARMPassword -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential ( $ARMUsername, $passwd )
Login-AzureRmAccount -Credential $credential | Out-Null

<# select subscription #>
<#
There is no CLI command to select subscription by name.  You must use the associated "list" command (i.e. "vm list") with the
-s or --subscription parameter and pass the subscription ID (not name).
#>
Select-AzureSubscription -SubscriptionName $ASMSubscription

<# find the VM #>
<#
    The CLI commands do not appear to return variables which this script relies on.


#>
$srcVM = Get-AzureVM -ServiceName $ASMServiceName -Name $ASMVMName
#endregion


#region Check srcVM for NULL
if ( $srcVM -eq $null ) {
    Write-Error "ERROR: srcVM parameter may not be NULL"
}
#endregion


#region Login

<#
    0. Login
        a) check to see if ASM and ARM are logged in
            1> abort this script if either login is missing
#>

Write-Verbose "Checking logins..."

<# check ASM login #>
$asmAcct = @(Get-AzureAccount)
if ( $asmAcct.Count -eq 0 ) {
    Write-Error "You must login before calling this script using Add-AzureAccount"
    $status.Status = "Error"
    $status.Message = "Not logged into Azure classic"
    return (ConvertTo-Json -InputObject $status -Compress)
}

<# check ARM login #>
$armAcct = @(Get-AzureRmSubscription -WarningAction SilentlyContinue)
if ( $armAcct.Count -eq 0 ) {
    Write-Error "You must login before calling this script using Login-AzureRmAccount"
    $status.Status = "Error"
    $status.Message = "Not logged into Azure Resource Manager"
    return (ConvertTo-Json -InputObject $status -Compress)
}

#endregion


#region Initial message
#Write-Host ("Cloning VM, {0}::{1}, to Azure Resource Manager" -f $srcVM.ServiceName, $srcVM.Name)
$startVMCloneTime = Get-Date
#endregion


#region Resource Group

<#
    1. Resource group
        a) check for existence of Resource Group
        b) if Resource group doesn't exist then create a new one
#>

Write-Verbose "Resource Group checks..."

$localLocationCheck = @(Get-AzureLocation | Where-Object {$_.Name -eq $tgtLocation})
if ( $localLocationCheck.Count -eq 0 ) {
    Write-Error ("Invalid location: {0}" -f $tgtLocation)
    $status.Status = "Error"
    $status.Message = ("Invalid location: {0}" -f $tgtLocation)
    return (ConvertTo-Json -InputObject $status -Compress)
}

$localResourceGroup = @(Get-AzureRmResourceGroup -Name $tgtResourceGroupName -ErrorAction SilentlyContinue)
if ( $localResourceGroup.Count -eq 0 ) {
    Write-Verbose ("Create resource group: {0}" -f $tgtResourceGroupName)
    $localResourceGroup = New-AzureRmResourceGroup -Name $tgtResourceGroupName -Location $tgtLocation
}

#endregion


#region Network

<#
    2. Network
        a) check for network and network subnet existence
        b) if network pieces need to be created then create them
#>

Write-Verbose "Network checks..."

<# first, get the network, create if necessary #>
$network = $null
$localNetworks = @(Get-AzureRmVirtualNetwork -Name $tgtNetworkName -ResourceGroupName $tgtResourceGroupName -ErrorAction SilentlyContinue)
if ( $localNetworks.Count -eq 0 ) {
    Write-Verbose ("building {0} network" -f $tgtNetworkName)
    $network = New-AzureRmVirtualNetwork -Name $tgtNetworkName -ResourceGroupName $tgtResourceGroupName -Location $tgtLocation -AddressPrefix $tgtNetworkPrefix -Subnet (New-AzureRmVirtualNetworkSubnetConfig -Name $tgtSubnetName -AddressPrefix $tgtSubnetPrefix)
}
else {
    <#
        Network has been found. Have to search the prefix now.
    #>
    Write-Verbose ("network {0} found" -f $tgtNetworkName)
    $network = $localNetworks[0]
}

<# second, get the subnet, create if necessary #>
$subnet = $null
$localSubnets = @(Get-AzureRmVirtualNetworkSubnetConfig -Name $tgtSubnetName -VirtualNetwork $network -ErrorAction SilentlyContinue)
if ( $localSubnets.Count -eq 0 ) {
    Write-Verbose ("building subnet {0}" -f $tgtSubnetName)
    $network | Add-AzureRmVirtualNetworkSubnetConfig -Name $tgtSubnetName -AddressPrefix $tgtSubnetPrefix | Set-AzureRmVirtualNetwork | Out-Null
    $subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $tgtSubnetName -VirtualNetwork $network
}
else {
    Write-Verbose ("subnet {0} found" -f $tgtSubnetName)
    $subnet = $localSubnets[0]
}

<# get the IP or create it #>
Write-Verbose "Finding or creating IP"
$ipName = "{0}_IP" -f $srcVM.Name
$ipAddresses = @(Get-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $tgtResourceGroupName -ErrorAction SilentlyContinue)
if ( $ipAddresses.Count -eq 0 ) {
    $ipAddress = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $tgtResourceGroupName -Location $tgtLocation -AllocationMethod Dynamic
}
else {
    $ipAddress = $ipAddresses[0]
}

<# get the NIC or create it #>
Write-Verbose "Finding or creating NIC"
$nicName = "{0}_NIC" -f $srcVM.Name
$NICs = @(Get-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $tgtResourceGroupName -ErrorAction SilentlyContinue)

if ( $NICs.Count -eq 0 ) {
    if ( $tgtIPAddress -eq "NONE" ) {
        $tgtNIC = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $tgtResourceGroupName -Location $tgtLocation -Subnet $subnet -PublicIpAddress $ipAddress
    }
    else {
        $tgtNIC = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $tgtResourceGroupName -Location $tgtLocation -Subnet $subnet -PublicIpAddress $ipAddress -PrivateIpAddress $tgtIPAddress
    }
}
else {
    $tgtNIC = $NICs[0]
}

#endregion


#region Availability Set

<#
    3. Availability Set
        a) check to see if availability set is required
        b) check to see if availability set exists (if required)
        c) create availability set
#>

Write-Verbose "Availability Set checks..."

$tgtAvailabilitySet = $null

if ( $tgtAvailabilitySetName -ne "" ) {

    $localAvailabilitySets = @(Get-AzureRmAvailabilitySet -ResourceGroupName $tgtResourceGroupName -Name $tgtAvailabilitySetName)

    if ( $localAvailabilitySets.Count -gt 0 ) {
        Write-Verbose ("availability set, {0}, found" -f $tgtAvailabilitySetName)
        $tgtAvailabilitySet = $localAvailabilitySets[0]
    }
    else {
        Write-Verbose ("availability set, {0}, not found... creating" -f $tgtAvailabilitySetName)
        $tgtAvailabilitySet = New-AzureRmAvailabilitySet -ResourceGroupName $tgtResourceGroupName -Name $tgtAvailabilitySetName -Location $tgtLocation
    }
}

#endregion


#region Storage

<#
    4. Storage
        a) check for storage account
            1> create if doesn't exist
        b) check for vhd existence in blob
            1> create if doesn't exist
        c) stop source VM to initiate copies
        d) copy source OS disk to target
        e) copy source data disks to target
#>

Write-Verbose "Storage checks..."

$localStorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $tgtResourceGroupName -Name $tgtStorageAccountName -ErrorAction SilentlyContinue
if ( $localStorageAccount -eq $null ) {
    <#
        Create the storage account
    #>
    $localStorageAccount = New-AzureRmStorageAccount -ResourceGroupName $tgtResourceGroupName -Name $tgtStorageAccountName -Location $tgtLocation -SkuName $tgtStorageAccountType
    $localStorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $tgtResourceGroupName -Name $tgtStorageAccountName -ErrorAction SilentlyContinue

    if ( $localStorageAccount -eq $null ) {
        Write-Error "localStorageAccount is NULL."
        $status.Status = "Error"
        $status.Message = "localStorageAccount is NULL"
        return (ConvertTo-Json -InputObject $status -Compress)
    }
}

$DestinationAccountKey=(Get-AzureRmStorageAccountKey -ResourceGroupName $tgtResourceGroupName -Name $tgtStorageAccountName).Value[0]

if ( $DestinationAccountKey -eq $null ) {
    Write-Error "DestinationAccountKey is NULL"
    $status.Status = "Error"
    $status.Message = "DestinationAccountKey is NULL"
    return (ConvertTo-Json -InputObject $status -Compress)
}

$DestinationContext = New-AzureStorageContext -StorageAccountName $tgtStorageAccountName -StorageAccountKey $DestinationAccountKey

$container = get-azurestoragecontainer -Name "vhds" -context $DestinationContext -ErrorAction SilentlyContinue

if ( $container -eq $null ) {
    Write-Verbose "Container does not exist"
    $container = New-AzureStorageContainer -Name vhds -Permission Off -Context $DestinationContext
}
else {
    Write-Verbose "Container exists"
}

<# stop source vm #>
if ( $srcVM.PowerState -eq "Started" ) {
    Write-Verbose ("stopping {0}" -f $srcVM.Name)
    Stop-AzureVM -VM $srcVM -ServiceName $srcVM.ServiceName -StayProvisioned -Force | Out-Null
}

<# copy OS disk #>

#Write-Host "copying SYSTEM disk..."

$osdisk = Get-AzureOSDisk -VM $srcVM
$rc = CopyDisk -disk $osdisk -DestinationContext $DestinationContext

#Write-Verbose ("bytes copied = {0}" -f $rc.ToString("0000000000000000"))

<# copy data disks #>

$dataDisks = @(Get-AzureDataDisk -VM $srcVM)

if ( $dataDisks.Count -gt 0 ) {
    foreach ( $disk in $dataDisks ) {
#        Write-Host ("Copying disk, {0}, data disk {1} of {2}" -f $disk.DiskName, ($dataDisks.IndexOf($disk) + 1), $dataDisks.Count)
        $rc = CopyDisk -disk $disk -DestinationContext $DestinationContext
#        Write-Verbose ("bytes copied = {0}" -f $rc)
    }
}

#endregion


#region Virtual Machine

<#
    5. Virtual Machine
        a) build target VM
        b) restart source VM (parameter switch)
#>

Write-Verbose "Virtual machine creation..."

<# build the VM #>
Write-Verbose ("cloning {0}" -f $srcVM.Name)

$srcVMSize = .\Get-CoretekVMSizeSelection.ps1 -Location $tgtLocation -VM $srcVM -RecommendationsOnly -NoBasic -NoUI
Write-Verbose ("srcVMSize = {0}" -f $srcVMSize)

<# build a new VM config #>
Write-Verbose "Building the VM config"
$DestinationVM = New-AzureRmVMConfig -vmName $srcVM.Name -vmSize $srcVMSize 

<# Add a network interface #>
Write-Verbose "Adding the network interface"
$DestinationVM = Add-AzureRmVMNetworkInterface -VM $DestinationVM -NetworkInterface $tgtNIC #| Set-AzureRmNetworkInterface
$DestinationVM.NetworkProfile.NetworkInterfaces.Item(0).Primary = $True
#Update-AzureRmVM -VM $DestinationVM -ResourceGroupName $tgtResourceGroupName

<# Add the OS disk #>
Write-Verbose "Attaching the OS disk"
$destOSDiskURI = "{0}vhds/{1}.vhd" -f $DestinationContext.BlobEndPoint, $osdisk.DiskName
$DestinationVM = Set-AzureRmVMOSDisk -VM $DestinationVM -Name $osdisk.DiskName -VhdUri $destOSDiskURI -Windows -CreateOption attach

<# Add the data disks #>
Write-Verbose "Attaching the data disks (if any)"
if ( $dataDisks.Count -gt 0 ) {
    foreach ( $disk in $dataDisks ) {
        $destDataDiskURI = "{0}vhds/{1}.vhd" -f $DestinationContext.BlobEndPoint, $disk.DiskName
        $DestinationVM = Add-AzureRmVMDataDisk -VM $DestinationVM -Name $disk.DiskName -VhdUri $destDataDiskURI -Lun ($dataDisks.IndexOf($disk)) -CreateOption attach -DiskSizeInGB $disk.LogicalDiskSizeInGB
    }
}

<# Create the VM #>
Write-Verbose "Creating the VM"
New-AzureRmVM -ResourceGroupName $tgtResourceGroupName -Location $tgtLocation -VM $DestinationVM | Out-Null

<# restart VM #>
if ( $RestartSourceVM -eq $True ) {
#    Write-Verbose ("restarting {0}" -f $srcVM.Name)
    Start-AzureVM -VM $srcVM -ServiceName $srcVM.ServiceName | Out-Null
}

#endregion


#region Last message
$endVMCloneTime = Get-Date
$vmTimeSpan = New-TimeSpan -Start $startVMCloneTime -End $endVMCloneTime
$status.Status = "Success"
$status.Message = "Cloned VM, {0}::{1}, in {2}:{3}" -f $srcVM.ServiceName, $srcVM.Name, $vmTimeSpan.Minutes.ToString("00"), $vmTimeSpan.Seconds.ToString("00")
#Write-Host $status.Message
#Write-Host ("Cloned VM, {0}::{1}, in {2}:{3}" -f $srcVM.ServiceName, $srcVM.Name, $vmTimeSpan.Minutes.ToString("00"), $vmTimeSpan.Seconds.ToString("00") )
#endregion

return (ConvertTo-Json -InputObject $status -Compress)
