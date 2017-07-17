[CmdletBinding()]
param 
(
    [Paramater(Mandatory=$true)]
    $ServerInstance
,   
    [Paramater(Mandatory=$true)]
    $Database = "PowerSwirl"
,   
    [Paramater(Mandatory=$true)]
    $ModuleRoot 
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

Install-PowerSwirl -Force -ErrorAction Stop @InstallScripts -ServerInstance $ServerInstance -Database $Database -Verbose 

$LessonMarkupPaths = @(
".\database\Data\Lessons\PowerShell Orientation\using_the_help_system.xml"
".\database\Data\Lessons\PowerShell Orientation\wildcards.xml"
)

$LessonMarkupPaths | 
Select-Object @{n="Path"; e={$_}} | 
Get-Content -Raw | 
ConvertFrom-PowerSwirlLessonMarkup | 
Import-PowerSwirlLesson -CreateNewCourse -OverWriteLesson -Verbose 