<#
    .SYNOPSIS
    Assign an update to a wsus group 

    .DESCRIPTION
    Assign an update to a wsus group for installation 

    .PARAMETER Template
    Parameter "Wsusgroups" can be set to one wsus group 
    Parameter "UpdateTitle" input is the title of the update that will be assigned as install to the wsus group

    .OUTPUTS
    Invoke-WSUSUpdateHelper returns $true if update succeed  or $false if not

    .EXAMPLE
    Invoke-WSUSUpdateHelper 
#>

Function Invoke-WSUSUpdateHelper {
    [CmdletBinding()]
    
    Param(
    [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [string]$Wsusgroup,

    [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [string]$UpdateTitle
    )  

    If (-not(Get-module UpdateServices )) {
       if (-not(Import-WSUSUpdateServicesModule)) {
            Write-Error 'No Wsus module found'-ErrorAction stop
       } 
    } 
    
    $wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer();
    if (-not($group = $wsus.GetComputerTargetGroups() | Where-Object {$_.Name -eq $Wsusgroup})){
        Write-Error  "Wsusgroup:  $Wsusgroup  is not found in WSUS" -ErrorAction Stop
    }    
               
    if (-not($Update = $wsus.SearchUpdates($UpdateTitle))) {
        Write-Error "UpdateTitle:  $UpdateTitle  is not found in WSUS" -ErrorAction Stop
    }    
    try {
        $update.Approve("Install",($group)) | Out-Null
    } catch {
        Write-Error -ErrorRecord $_ -ErrorAction Stop
    }      
} 