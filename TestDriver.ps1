function Test-PowerSwirl
{
    [CmdletBinding()]
    param
    (
        $ModuleRoot = "C:\Users\ROBVK\Documents\Workspace\Projects\PowerSwirl"
    )
    
    Import-Module PowerSwirl -Force 

    $PowerSwirlConnection = Get-PowerSwirlConnection
    $ServerInstance = $PowerSwirlConnection.ServerInstance 
    $Database = $PowerSwirlConnection.Database 

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
    Select-Object -ExpandProperty FullName 

    Invoke-Pester $Tests 
}

Test-PowerSwirl
