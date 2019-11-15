<#
    .SYNOPSIS
    list Wsus updates based on function input 

    .DESCRIPTION
    Create a custom list of updates for computer, based on function input

    .PARAMETER Template
    Parmeter "UpdateType" can be set to one or many if the following: 'Applications','Critical Updates','Definition Updates','Driver Sets','Drivers','Feature Packs','Security Updates','Service Packs','Tools','Update Rollups','Updates','Upgrades'    
    Parameter "InstallationState" can be set to one or many of the following: 'Downloaded','Failed','Installed','InstalledPendingReboot','NotApplicable','NotInstalled','Unknown' 

    .OUTPUTS
    Computer                  : MyComputer
    Title                     : 2019-11 Cumulative Update for Windows 10 Version 1903 for x64-based Systems (KB4524570)
    IsDeclined                : False
    IsApproved                : False
    UpdateInstallationState   : NotInstalled
    UpdateApprovalAction      : NotApproved
    UpdateClassificationTitle : Security Updates
    CreationDate              : 12-11-2019

    .EXAMPLE
    Get-WSUSUpdateHelper -computer MyComputer -UpdateType "Critical Updates","Security Updates" -InstallationState 'NotInstalled','downloaded'

    .EXAMPLE
    Get-WSUSUpdateHelper -computer MyComputer -UpdateType "Upgrades" -InstallationState 'NotInstalled','downloaded'

#>

Function Get-WSUSUpdateHelper {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,
        ValueFromPipeline = $true)]
        [ValidateSet(
            'Applications','Critical Updates','Definition Updates','Driver Sets','Drivers','Feature Packs','Security Updates','Service Packs','Tools','Update Rollups','Updates','Upgrades'
        )]
        $UpdateType = 'All',

        [Parameter(Mandatory = $false,
        ValueFromPipeline = $true)]
        [ValidateSet(
            'Downloaded','Failed','Installed','InstalledPendingReboot','NotApplicable','NotInstalled','Unknown'
        )]
        $InstallationState = 'All',

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]         
        [string]$Computer 

        
    )

    If (-not(Get-module UpdateServices )) {
        if (-not(Import-WSUSUpdateServicesModule)) {
             Write-Error 'No Wsus module found'-ErrorAction stop
        } 
     } 
     
    $CallerErrorActionPreference = $ErrorActionPreference

   if (-not(Get-WsusComputer | Where-Object -FilterScript {$_.FullDomainName -eq $Computer})) {
        Write-Error "Computer:  $Computer  is not found in WSUS" -ErrorAction stop
    }

        
    $UpdateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
    if ($UpdateType -eq 'ALL') {
        $updateClassifications = $wsus.GetUpdateClassifications() 
    } else {
        $updateClassifications = $wsus.GetUpdateClassifications() | Where-Object {$_.title -match ( $UpdateType -join '|' )} 
    }
   

    Try {
        $Client = $Wsus.GetComputerTargetByName($Computer)
        $UpdateScope.Classifications.AddRange($updateClassifications)     

        if ($InstallationState -eq 'All') {
            $UpdateScope.IncludedInstallationStates = 'Downloaded','Failed','Installed','InstalledPendingReboot','NotInstalled','Unknown'
        } else {
            $UpdateScope.IncludedInstallationStates = $InstallationState
        }
    
        $Client.GetUpdateInstallationInfoPerUpdate($UpdateScope) | 
        ForEach-Object {
            $PSObject = [PSCustomObject] @{
                    Computer                  = $Computer
                    Title                     = $_.GetUpdate().Title                    
                    IsDeclined                = $_.GetUpdate().IsDeclined
                    IsApproved                = $_.GetUpdate().IsApproved
                    UpdateInstallationState   = $_.UpdateInstallationState
                    UpdateApprovalAction      = $_.UpdateApprovalAction                    
                    UpdateClassificationTitle = $_.GetUpdate().UpdateClassificationTitle
                    CreationDate              = $_.GetUpdate().CreationDate.ToString("dd-MM-yyyy")

            }
        Write-Output -InputObject $PSObject 
        }  

    }catch {
        Write-Error -ErrorRecord $_ -ErrorAction $CallerErrorActionPreference
    }


}
