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
        [String] $ServerInstance 
        ,
        [String] $Database
        ,
        [String] $CourseSid
        ,
        [String] $LessonSid
    )

    $Params = @{ServerInstance=$ServerInstance; Database=$Database}
    Write-Verbose "Getting lesson information"
    $Query = "EXECUTE dbo.p_get_lesson_info 
                      @ai_course_sid = $CourseSid
              ,       @ai_lesson_sid = $LessonSid
              ;
             "
    $Params["Query"] = $Query
    Write-Verbose "Executing Query =`n$Query" 
}

function Write-LessonPrompt
{
    <#
        .SYNOPSIS
        Writes the current step's prompt

        .DESCRIPTION
        Write the step prompt to the information stream and the host
    #>
}

function Read-StepInput
{
    <#
        .SYNOPSIS
        Read the user's input

        .DESCRIPTION
        Let the user write to the information stream. Read his input from this stream.
    #>
}

function Test-StepInput
{
    <#
        .SYNOPSIS
        Test the user's input against the true solution

        .DESCRIPTION
        Evaluate the user's input, either code or literal values, to the stored solution. The answer the user provides must be exactly
        the same as the solution when literal values are expected, but any equivalent (under code evaluation) code will work. That is, superficial
        differences between the user's answer and the stored solution do not invalidate a correct answer.
    #>
}

function Write-UserIncorrect
{
    <#
        .SYNOPSIS
        Write a message indicating that the user answered incorrectly

        .DESCRIPTION
        Write a message to the information stream, chosen from one or more possible messages, indicating an incorrect answer.
    #>
}

function Write-UserCorrect
{
    <#
        .SYNOPSIS
        Write a message indicating that the user answered correctly

        .DESCRIPTION
        Write a message to the information stream, chosen from one or more possible messages, indicating a correct answer.
    #>
}
