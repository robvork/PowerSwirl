param
(
    $TestServerInstance
,
    $TestDatabase
)

Get-Module -Name "PowerSwirl" -All | Remove-Module -Force 
Import-Module "PowerSwirl" -Force -ErrorAction Stop 

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
