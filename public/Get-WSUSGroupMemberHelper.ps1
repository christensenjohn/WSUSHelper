<#
    .SYNOPSIS
    list Computers in Wsus 

    .DESCRIPTION
    Create a list of alle computers in all group or specific groups

    .PARAMETER Template
    Parameter "Wsusgroups" can be set to one or many wsus group. Default is All groups.

    .OUTPUTS
    Name      : MyComputer
    WsusGroup : Windows10


    .EXAMPLE
    Get-WSUSGroupMemberHelper -Wsusgroups 'Windows10','pc_Win7'
#>

Function Get-WSUSGroupMemberHelper {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]     
    Param(
       [System.Collections.Specialized.StringCollection]$groups
    )

    If (-not(Get-module UpdateServices )) {
        if (-not(Import-WSUSUpdateServicesModule)) {
             Write-Error 'No Wsus module found'-ErrorAction stop
        } 
     } 

    Try {
        if ($groups -eq $null) {
            $Computers = Get-WsusComputer 
        } else {         
            $Computers += Get-WsusComputer -RequestedTargetGroupName $groups
        }
        $Computers | ForEach-Object {
            $PSObject = [PSCustomObject] @{
                Name      = $_.FullDomainName
                WsusGroup = $_.RequestedTargetGroupName
            }
        Write-Output -InputObject $PSObject
        } 

    } catch {
        Write-Error -ErrorRecord $_ -ErrorAction stop
    }
}
