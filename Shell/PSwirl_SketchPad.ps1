﻿Import-Module PowerSwirl -Force

#$lessonFile = 'C:\Users\ROBVK\Documents\Workspace\Projects\PowerSwirl\Lessons\intro_powerswirl_full.xml'
<#$lessonFile = 'C:\Users\ROBVK\Documents\Workspace\Projects\PowerSwirl\Lessons\intro_powerswirl_test_lesson.xml'
$lesson = Get-Content $lessonFile -Raw #>
#Get-LessonHeader $lesson | 
#Select -exp coursename
<##> 

<#
$lesson = [xml] ($lesson | 
ConvertFrom-LessonMarkup)

$lesson.lesson.body.section.step.prompt -replace "[ \t]+", " "
#>
 <#| 
Out-File -FilePath C:\Users\ROBVK\Documents\Workspace\Projects\PowerSwirl\Lessons\intro_powerswirl_full.xml 
#>

#| 
#ConvertTo-ImportSQL
<#
$ConnectionParams = @{
    ServerInstance='ASPIRING\SQL16';
    Database='PowerSwirl';
}
$lessonFile = 'C:\Users\ROBVK\Documents\Workspace\Projects\PowerSwirl\Lessons\intro_powerswirl_test_lesson.xml'

Get-Content -Path $lessonFile -Raw | 
ConvertFrom-LessonMarkup | 
Import-Lesson @ConnectionParams -OverWriteLesson -CreateNewCourse -Verbose
#>

#$LessonMarkupPath = ".\database\Data\Lessons\integration_test_step_content.xml"
#$LessonMarkupPath = ".\database\Data\Lessons\PowerShell Orientation\using_the_help_system.xml"

$ServerInstance = "ASPIRING\SQL16"
$Database = "PowerSwirl" 
$ModuleRoot = "C:\Users\ROBVK\Documents\Workspace\Projects\PowerSwirl"
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

 <# 
     **** Outline ****
     Is $ServerInstance valid?
     => Yes 
        Proceed
     => No
        Halt

     Does $Database already exist on $ServerInstance?
     => Yes
         Was force specified? 
         => Yes
                 Kill connections and drop database
         => No 
                 Raise error
     => No 
         Proceed with the installation process

     # For each (ObjectType, Path), is the path empty?
        # => Yes 
            # Continue to the next pair
        # => No
            # Is the Path valid?
            # => Yes
                # Run all *.sql scripts at that path (no recursion) against $ServerInstance, $Database

     *Object creation order*
     Create database
     Create data types
     Create tables
     Create constraints
     Create triggers
     Create functions
     Create procedures 
     Create views

     
    #>
