<#
    .SYNOPSIS
    Import UpdateServicesModule

    .DESCRIPTION
    WSUS Server comes with UpdateServicesModule and this is required for helper module to run 

    .EXAMPLE
    Import-WSUSUpdateServicesModule
#>

function Import-WSUSUpdateServicesModule {
    Import-Module -Name UpdateServices -ErrorAction silentlycontinue -Global
    if (Get-Command -module UpdateServices | Where-Object -FilterScript {$_.name -eq 'Get-WsusUpdate'} ){
        return [bool] $true
    } else {
        Write-Error 'No Wsus module found'-ErrorAction SilentlyContinue
        return [bool] $false
    }
}
