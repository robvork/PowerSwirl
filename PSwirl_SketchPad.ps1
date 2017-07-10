Import-Module PowerSwirl -Force

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

$ConnectionParams = @{
    ServerInstance='ASPIRING\SQL16';
    Database='PowerSwirl';
}
$lessonFile = 'C:\Users\ROBVK\Documents\Workspace\Projects\PowerSwirl\Lessons\intro_powerswirl_test_lesson.xml'

Get-Content -Path $lessonFile -Raw | 
ConvertFrom-LessonMarkup | 
Import-Lesson @ConnectionParams -OverWriteLesson -CreateNewCourse

