Write-Verbose "Importing from [$PSScriptRoot\public]"
. "$PSScriptRoot\public\Get-WSUSGroupMemberHelper.ps1"
. "$PSScriptRoot\public\Get-WSUSUpdateHelper.ps1"
. "$PSScriptRoot\public\Invoke-WSUSUpdateHelper.ps1"
Write-Verbose "Importing from [$PSScriptRoot\private]"
. "$PSScriptRoot\private\Import-WSUSUpdateServicesModule.ps1"
$publicFunctions = (Get-ChildItem -Path "$PSScriptRoot\public" -Filter '*.ps1').BaseName
Export-ModuleMember -Function $publicFunctions

