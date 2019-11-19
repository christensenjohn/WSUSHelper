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
            Write-Error  "Wsusgroup:  $Wsusgroup  is not found in WSUS"
            return $false
       } 
    } 
    
     if (!$global:wsus) {
        $global:wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer();
    }

    if (-not($group = $global:wsus.GetComputerTargetGroups() | Where-Object {$_.Name -eq $Wsusgroup})){
        Write-Error  "Wsusgroup:  $Wsusgroup  is not found in WSUS"
        return $false        
    }    
               
    if (-not($Update = $global:wsus.SearchUpdates($UpdateTitle))) {
        Write-Error "UpdateTitle:  $UpdateTitle  is not found in WSUS" 
        return $false
    }    
    try {
        $update.Approve("Install",($group)) | Out-Null
    } catch {
        Write-Error -ErrorRecord $_ 
        return $false
    }
    return $true      
} 