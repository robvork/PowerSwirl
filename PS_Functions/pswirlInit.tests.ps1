<#
function Read-SQLServerInstance
function Read-SQLServerDatabase
function Read-PSwirlUser
function Test-PSwirlUser
function Initialize-PSwirlStream
#>
Import-Module "C:\Users\ROBVK\Documents\Workspace\Projects\PowerSwirl" -Force 

InModuleScope "PowerSwirl" {

    Describe "Read-SQLServerInstance"{
        Context "Non-empty instance name" {
            $MockInstanceName = "MyInstance"

            mock -CommandName Read-Host -MockWith {$MockInstanceName}
            $o = Read-SQLServerInstance 
            
            It "should be a string" {
                $o | Should BeOfType [String]
            }

            It "should be the string specified in the test" {
                $o | Should BeExactly $MockInstanceName
            }
        }

        Context "Empty instance name" {
            $MockInstanceName = ""
            mock -CommandName Read-Host -MockWith {$MockInstanceName}
            It "should throw when an empty string is passed" {
                {Read-SQLServerInstance} | Should throw  
            }
        }
    }

    Describe "Read-SQLServerDatabase" {
        Context "Non-empty database name" {
            $MockDatabaseName = "MyDatabase"

            mock -CommandName Read-Host -MockWith {$MockDatabaseName}
            $o = Read-SQLServerDatabase 
            
            It "should be a string" {
                $o | Should BeOfType [String]
            }

            It "should be the string specified in the test" {
                $o | Should BeExactly $MockDatabaseName
            }
        }

        Context "Empty database name" {
            $MockDatabaseName = ""
            mock -CommandName Read-Host -MockWith {$MockDatabaseName}
            It "should throw when an empty string is passed" {
                {Read-SQLServerDatabase} | Should throw  
            }
        }
    }
    
    Describe "Read-PSwirlUser" {
        Context "Non-empty User name" {
            $MockUserName = "MyUser"

            mock -CommandName Read-Host -MockWith {$MockUserName}
            $o = Read-PSwirlUser 
            
            It "should be a string" {
                $o | Should BeOfType [String]
            }

            It "should be the string specified in the test" {
                $o | Should BeExactly $MockUserName
            }
        }

        Context "Empty User name" {
            $MockUserName = ""
            mock -CommandName Read-Host -MockWith {$MockUserName}
            It "should throw when an empty string is passed" {
                {Read-PSwirlUser} | Should throw  
            }
        }
    }
    
    Describe "Test-PSwirlUser" {
        Context "User exists" {
            $UserSid = 1
            Mock -CommandName Invoke-Sqlcmd2 -MockWith {New-Object -TypeName PSObject -Property @{user_exists=$true; user_sid=$UserSid}}
            
            It "should not throw" {
                {Test-PSwirlUser -ServerInstance "BogusServer" -Database "BogusDB" -User "BogusUser"} | Should not throw 
            } 

            It "should return an int" {
                Test-PSwirlUser -ServerInstance "BogusServer" -Database "BogusDB" -User "BogusUser" | Should beoftype [int]
            }

            It "should return the int specified in the test" {
                Test-PSwirlUser -ServerInstance "BogusServer" -Database "BogusDB" -User "BogusUser" | Should be 1 
            }
        }

        Context "User doesn't exist" {
            Mock -CommandName Invoke-Sqlcmd2 -MockWith {New-Object -TypeName PSObject -Property @{user_exists=$false; user_sid=$null}}

            It "should throw" {
                {Test-PSwirlUser -ServerInstance "BogusServer" -Database "BogusDB" -User "BogusUser"} | should throw
            }
        }
    }
    
    Describe "Initialize-PSwirlStream" {
        It 'should not throw' {
            {Initialize-PSwirlStream} | Should not throw
        }

        $o = Initialize-PSwirlStream 

        It 'should return a string' {
            $o | Should beoftype [string]
        }

        It "should return the string 'Continue'" {
            $o | Should be "Continue"
        }
    }
}



<#
     
#>