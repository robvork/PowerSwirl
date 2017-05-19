$VerbosePreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"

$ThisModule = "$($MyInvocation.MyCommand.Path -replace '\.Tests\.ps1$', '').psm1"
$ThisModuleName = (($ThisModule | Split-Path -Leaf) -replace '\.psm1')
Get-Module -Name $ThisModuleName -All | Remove-Module -Force 
Import-Module -Name $ThisModule -Force -ErrorAction Stop 

InModuleScope "PowerSwirl" {
    Describe "Start-PowerSwirl" -Tag "Start-PowerSwirl", "Unit" {
        $InvalidServerInstance = "RGEVORKYAN\SQL12"
        $ValidServerInstance = "ASPIRING\SQL16"
        $InvalidDatabase = "temporaryDB"
        $ValidDatabase = "tempdb"
        Context "Test-SQLServerConnectionString"  {
            It "Should throw if ServerInstance name is invalid" {
                {Test-SQLServerConnectionString "Server=$InvalidServerInstance; Database=$ValidDatabase; trusted_connection=True"} | Should throw "Connection string invalid"
            }

            It "Should throw if ServerInstance name is valid but database name is invalid" {
                {Test-SQLServerConnectionString "Server=$ValidServerInstance; Database=$InvalidDatabase; trusted_connection=True"} | Should throw "Connection string invalid"
            }

            It "Should not throw if ServerInstance name and Database are both valid" {
                {Test-SQLServerConnectionString "Server=$ValidServerInstance; Database=$ValidDatabase; trusted_connection=True"} | Should not throw 
            }


        }
    }
}
