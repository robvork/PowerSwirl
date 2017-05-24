function Write-RetryPrompt 
{
    [CmdletBinding()]
    param
    (
        [String] $Message
    )

    Write-Information -MessageData $Message -Tags Message
    Write-Information -MessageData "Please try again." -Tags PostMessage
}

function Read-MenuSelection
{
    $Selection = Read-Host -Prompt "Selection"
    Write-Output $Selection 
}

function Write-CourseHeaders
{
    [CmdletBinding()]
    param
    (
        $Courses
    )

    Write-Information -MessageData $Courses.Length -Tags CourseCount -InformationAction SilentlyContinue
    Write-Information -MessageData "Choose a course from the following" -Tags PreHeaders
    foreach($Course in $Courses)
    {
        $CourseLine = $Course.selection.ToString() + ": " + $Course.course_id
        Write-Information -MessageData $CourseLine -Tags CourseLine 
    }
}

function Write-LessonHeaders
{
    [CmdletBinding()]
    param
    (
        $Lessons
    )

    Write-Information -Message $Lessons.Length -Tags LessonCount -InformationAction SilentlyContinue
    Write-Information -MessageData "Choose a lesson from the following" -Tags PreHeaders
    foreach($Lesson in $Lessons)
    {
        $LessonLine = $Lesson.selection.ToString() + ": " + $Lesson.lesson_id
        Write-Information -MessageData $LessonLine -Tags LessonLine
    }
}

function Test-PSwirlCourse
{
    param
    (
        $ServerInstance 
    ,   $Database 
    ,   $CourseID
    )

    if($CourseID -eq "" -or $CourseID -eq $null)
    {
        throw "Course must be not null and not empty"
    }

    $Query = "EXECUTE dbo.p_get_course @as_course_id = '$CourseID'"
    $TestResult = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $Query
    if($TestResult.course_exists)
    {
        Write-Output $TestResult.course_sid
    }
    else
    {
        throw "Course does not exist"
    }
}

function Test-PSwirlLesson
{
     param
    (
        $ServerInstance 
    ,   $Database 
    ,   $CourseSID
    ,   $LessonID 
    )

    if($LessonID -eq "" -or $LessonID -eq $null)
    {
        throw "Lesson must be not null and not empty"
    }

    $Query = "EXECUTE dbo.p_get_lesson 
                   @ai_course_sid = $CourseSid
              ,    @as_lesson_id = '$LessonID'
                   "
    $TestResult = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $Query
    if($TestResult.lesson_exists)
    {
        Write-Output $TestResult.lesson_sid
    }
    else
    {
        throw "Lesson does not exist"
    }

}

function Test-MenuSelection
{
    param
    (
        [Object[]] $MenuObjects
    ,   [int] $MenuSelection
    )

    $MenuSelections = $MenuObjects.Selection

    if($MenuSelection -notin $MenuSelections)
    {
        throw "$MenuSelection is not a valid selection"
    }
}

function Get-CourseHeaders
{
    <#
        .SYNOPSIS
        Get PowerSwirl courses 

        .DESCRIPTION
        Get the PowerSwirl course headers. A course header record consists of a descriptive name and a numeric course sid. 
        The user sees the descriptive name, but the database processes the course sid. 
    #>
    [CmdletBinding()]
    param
    (
        [string]
        $ServerInstance 
    
    ,   [string]
        $Database
    )

    $Query = "EXEC dbo.p_get_courses"
    $Courses = Invoke-SqlCmd2 -ServerInstance $ServerInstance -Database $Database -Query $Query 

    Write-Output $Courses 


}

function Get-LessonHeaders
{
    <#
        .SYNOPSIS
        Get PowerSwirl lesson headers

        .DESCRIPTION
        Get the PowerSwirl lesson headers. A lesson header record consists of numeric lesson sids and a descriptive name.
        The user sees the descriptive name, but the database processes the lesson sid.
    #>
    [CmdletBinding()]
    param
    (
        [string]
        $ServerInstance

     ,  
        [string]
        $Database

     ,    
        [string]
        $CourseID

     , 
        [int]
        $CourseSID
    )
    
    $Query = "EXECUTE dbo.p_get_lessons @ai_course_sid = $CourseSid"
    $LessonHeaders = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $Query 
    Write-Output $LessonHeaders 

}
