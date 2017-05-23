function Save-Lesson
{
    <#
        .SYNOPSIS
        Save the progress on the current lesson

        .DESCRIPTION
        Store the user's current step number within the course and lesson. 
        A call to Resume-Lesson depends on a prior execution of this command.
    #>

    [CmdletBinding()]
    param
    (
        [String] $ServerInstance 
        ,
        [String] $Database
        ,
        [Int] $CourseSid
        ,
        [Int] $LessonSid
        ,
        [Int] $UserSid
        ,
        [Int] $StepNum
    )

    $Params = @{
        ServerInstance=$ServerInstance;
        Database=$Database;
    }
    $Query = "EXECUTE dbo.p_set_lesson_paused
                      @ai_course_sid = $CourseSid
             ,        @ai_lesson_sid = $LessonSid
             ,        @ai_user_sid = $UserSid
             ,        @ai_step_num = $StepNum
             ;
    "
    $Params["Query"] = $Query 
    Write-Verbose "Executing Query =`n$Query"
    
    Invoke-Sqlcmd2 @Params 
}

function Resume-Lesson
{
    <#
        .SYNOPSIS
        Resume a lesson that was saved

        .DESCRIPTION
        Using the currenet user's step number within a given course and lesson, resume a lesson
        where it was left off previously. Produces an error if no corresponding value found. 
    #>
    [CmdletBinding()]
    param
    (
        [String] $ServerInstance 
        ,
        [String] $Database
        ,
        [Int] $UserSid
    )

    $Params = @{
        ServerInstance=$ServerInstance;
        Database=$Database;
    }

    Write-Verbose "Getting pause info"
    $Query = "EXECUTE dbo.p_get_pause_info 
                      @ai_user_sid = $UserSid
             "
    $Params["Query"] = $Query 
    Write-Verbose "Executing Query =`n$Query"
    $PauseInfo = Invoke-Sqlcmd2 @Params
    $CourseSid = $PauseInfo.course_sid 
    $LessonSid = $PauseInfo.lesson_sid 
    $StepNum = $PauseInfo.step_num
    Write-Verbose "CourseSid = $CourseSid"
    Write-Verbose "LessonSid = $LessonSid"
    Write-Verbose "StepNum = $StepNum"

    $Params.Remove("Query")
    $Params["CourseSid"] = $CourseSid 
    $Params["LessonSid"] = $LessonSid 
    $Params["StepNum"] = $StepNum
    $Params["DisableForcePause"] = $true
    $Params["UserSid"] = $UserSid 

    Start-PowerSwirlLesson @Params
}

Set-Alias -Name nxt -Value Resume-Lesson