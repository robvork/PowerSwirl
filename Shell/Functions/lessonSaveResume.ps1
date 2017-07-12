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
        [Int] $CourseSid
        ,
        [Int] $LessonSid
        ,
        [Int] $UserSid
        ,
        [Int] $StepNum
    )

    $PowerSwirlConnection = Get-PowerSwirlConnection
    $ServerInstance = $PowerSwirlConnection.ServerInstance 
    $Database = $PowerSwirlConnection.Database 


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

    $PSDefParamValues = $Global:PSDefaultParameterValues.Clone()
    $PSDefParamValues["Resume-Lesson:ServerInstance"] = $ServerInstance
    $PSDefParamValues["Resume-Lesson:Database"] = $Database
    $PSDefParamValues["Resume-Lesson:UserSid"] = $UserSid
    $PSDefParamValues["Resume-Lesson:InformationAction"] = $InformationPreference
    $PSDefParamValues["Resume-Lesson:Verbose"] = $VerbosePreference

    Set-Variable -Name PSDefaultParameterValues -Scope global -Value $PSDefParamValues
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
        [Int] $UserSid
    )

    $PowerSwirlConnection = Get-PowerSwirlConnection
    $ServerInstance = $PowerSwirlConnection.ServerInstance 
    $Database = $PowerSwirlConnection.Database 

    $Params = @{
        ServerInstance=$ServerInstance;
        Database=$Database;
    }

    try
    {
        Write-Verbose "Getting pause info"
        $Query = "EXECUTE dbo.p_get_pause_info 
                          @ai_user_sid = $UserSid
                 "
        $Params["Query"] = $Query 
        Write-Verbose "Executing Query =`n$Query"
        $PauseInfo = Invoke-Sqlcmd2 @Params

        $CourseSid = $PauseInfo.courseSid 
        $LessonSid = $PauseInfo.lessonSid 
        $StepNum = $PauseInfo.stepNum
        Write-Verbose "CourseSid = $CourseSid"
        Write-Verbose "LessonSid = $LessonSid"
        Write-Verbose "StepNum = $StepNum"

        $Params.Remove("Query")
        $Params["CourseSid"] = $CourseSid 
        $Params["LessonSid"] = $LessonSid 
        $Params["StepNumStart"] = $StepNum
        $Params["DisableForcePause"] = $true
        $Params["UserSid"] = $UserSid 

        Start-PowerSwirlLesson @Params
    }
    catch
    {
        throw $_.Exception.Message 
    }
}

Set-Alias -Name nxt -Value Resume-Lesson