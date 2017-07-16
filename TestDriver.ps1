function Test-PowerSwirl
{
    [CmdletBinding()]
    param
    (
        $ServerInstance
    ,   $Database 
    ,   $ModuleRoot = "C:\Users\ROBVK\Documents\Workspace\Projects\PowerSwirl"
    )
    
    Import-Module PowerSwirl -Force 

    $InstallScripts = @{
        DataTypesPath = "$ModuleRoot\Database\Data Types";
        TablesPath = "$ModuleRoot\Database\Tables";
        ConstraintsPath = "$ModuleRoot\Database\Constraints";
        FunctionsPath = "$ModuleRoot\Database\Functions";
        ProceduresPath = "$ModuleRoot\Database\Procedures";
        ViewsPath = "$ModuleRoot\Database\Views";
        TriggersPath = "$ModuleRoot\Database\Triggers";
    }

    Install-PowerSwirl -Force -ErrorAction Stop @InstallScripts -ServerInstance $ServerInstance -Database $Database

    $Tests = Get-ChildItem $ModuleRoot -Filter *.tests.ps1 -Recurse | 
    Select-Object -ExpandProperty FullName 

    Invoke-Pester $Tests 
}

Test-PowerSwirl -ServerInstance "ASPIRING\SQL16" -Database "PowerSwirl"
