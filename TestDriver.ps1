function Test-PowerSwirl
{
    [CmdletBinding()]
    param
    (
        $ServerInstance = "ASPIRING\SQL16"
    ,
        [Parameter(Mandatory=$true, HelpMessage="Enter the database to test")]
        $Database
    ,
        $ModuleRoot = "C:\Users\ROBVK\Documents\Workspace\Projects\PowerSwirl"
    )

    $InstallScripts = @{
        DataTypesPath = "$ModuleRoot\Database\Data Types";
        TablesPath = "$ModuleRoot\Database\Tables";
        ConstraintsPath = "$ModuleRoot\Database\Constraints";
        FunctionsPath = "$ModuleRoot\Database\Functions";
        ProceduresPath = "$ModuleRoot\Database\Procedures";
        ViewsPath = "$ModuleRoot\Database\Views";
        TriggersPath = "$ModuleRoot\Database\Triggers";
    }

    Install-PowerSwirl -ServerInstance $ServerInstance -Database $Database -Force -ErrorAction Stop @InstallScripts

    $Tests = Get-ChildItem $ModuleRoot -Filter *.tests.ps1 -Recurse | 
            Select-Object -ExpandProperty FullName | 
            ForEach-Object {
                Write-Output @{Path = $_;
                            Parameters=@{
                                    TestServerInstance = $ServerInstance;
                                    TestDatabase = $Database;
                                } 
                            }
            }

    Write-Output $Tests 
    #Invoke-Pester -Script $Tests 
}
