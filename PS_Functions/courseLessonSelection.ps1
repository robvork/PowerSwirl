function Write-RetryPrompt 
{
    param
    (
        [String] $Message
    ,   [String] $InformationVariable
    )

    Write-Information -MessageData $Message -InformationAction Continue
    Write-Information -MessageData "Please try again." -InformationAction Continue
}

function Read-MenuSelection
{
    $Selection = Read-Host -Prompt "Selection"
    Write-Output $Selection 
}

function Write-CourseHeaders
{
    param
    (
        $Courses
    )

    foreach($Course in $Courses)
    {
        $CourseLine = $Course.selection + " : " + $Course.course_id
        Write-Information -MessageData $CourseLine
    }
}

function Read-PSwirlCourse
{
}

function Test-PSwirlCourse
{
    param
    (
        $ServerInstance 
    ,   $Database 
    ,   $CourseID
    )
}

function Read-PSwirlLesson
{
}

function Test-PSwirlLesson
{
    param
    (
        $ServerInstance 
    ,   $Database 
    ,   $CourseID
    ,   $LessonID
    )
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
    )

    
    $Query = "EXECUTE dbo.p_get_lessons @as_course_id = '$CourseID'"
    $LessonHeaders = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $Query 
    Write-Output $LessonHeaders 

}

function Get-LessonInfo
{
}

function Get-LessonContent
{
    <#
        .SYNOPSIS
        Get the PowerSwirl lesson data needed for the presentation of a lesson

        .DESCRIPTION
        Get the PowerSwirl lesson data, consisting of columns step_prompt, requires_input_flag, execute_code_flag, store_variable_flag, solution, and variable.
        Each record corresponds to a single step in a lesson. The step_prompt and flag values are mandatory, but the solution and variable flags are mandatory
        if and only if the requires_input_flag and store_variable_flag flags are set to true, respectively. 
    #>
    [CmdletBinding()]
    param
    (
    )
}