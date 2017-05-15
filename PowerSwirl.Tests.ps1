$ThisModule = "$($MyInvocation.MyCommand.Path -replace '\.Tests\.ps1$', '').psm1"
$ThisModuleName = (($ThisModule | Split-Path -Leaf) -replace '\.psm1')
Get-Module -Name $ThisModuleName -All | Remove-Module -Force
Import-Module -Name $ThisModule -Force -ErrorAction Stop

InModuleScope "PowerSwirl" {
    Describe "Start-PowerSwirl" -Tag "Start-PowerSwirl", "Unit" {
        Context "Test-SQLServerConnectionString"  {
            It "Should throw if ServerInstance name is invalid" {
                $InvalidSQLServerInstance = "RGEVORKYAN\SQL12"
                {Test-SQLServerConnectionString "Server=$InvalidSQLServerInstance; 
                                                 Database=Master; 
                                                 trusted_connection=True"} | Should Throw "Connection string invalid"
            }
        }
    }
}


