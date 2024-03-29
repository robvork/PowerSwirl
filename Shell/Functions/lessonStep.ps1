function Get-LessonInfo
{
    param
    (
        [Int] $CourseSid
        ,
        [Int] $LessonSid
    )
    $PowerSwirlConnection = Get-PowerSwirlConnection
    $ServerInstance = $PowerSwirlConnection.ServerInstance 
    $Database = $PowerSwirlConnection.Database 


    $Params = @{ServerInstance=$ServerInstance; Database=$Database}
    Write-Verbose "Getting lesson information"
    $Query = "EXECUTE dbo.p_get_lesson_info
                      @ai_course_sid = $CourseSid
              ,       @ai_lesson_sid = $LessonSid
              ;
             "
    $Params["Query"] = $Query
    Write-Verbose "Executing Query =`n$Query"
    $LessonInfo = Invoke-SqlCmd2 @params 
    
    Write-Output $LessonInfo
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
        [Int] $CourseSid
        ,
        [Int] $LessonSid
    )

    $PowerSwirlConnection = Get-PowerSwirlConnection
    $ServerInstance = $PowerSwirlConnection.ServerInstance 
    $Database = $PowerSwirlConnection.Database 


    $Params = @{ServerInstance=$ServerInstance; Database=$Database}
    Write-Verbose "Getting lesson content"
    $Query = "EXECUTE dbo.p_get_lesson_content
                      @ai_course_sid = $CourseSid
              ,       @ai_lesson_sid = $LessonSid
              ;
             "
    $Params["Query"] = $Query
    Write-Verbose "Executing Query =`n$Query" 
    $LessonContent = Invoke-SqlCmd2 @params -As PSObject

    Write-Output $LessonContent 
}

function Write-LessonPrompt
{
    <#
        .SYNOPSIS
        Writes the current step's prompt

        .DESCRIPTION
        Write the step prompt to the information stream and the host
    #>
    [CmdletBinding()]
    param
    (
        [String] $Prompt
    )

    Write-Information ("`n" + $Prompt)
}


function Read-StepInput
{
    <#
        .SYNOPSIS
        Read the user's input

        .DESCRIPTION
        Let the user write to the information stream. Read his input from this stream.
    #>

    $StepInput = Read-Host "Enter your answer"
    Write-Output $StepInput 
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
    [CmdletBinding()]
    param
    (
    [String] $UserInput 
    ,
    [String] $Solution
    ,
    [Switch] $ExecuteCode
    )

    try
    {
        # Evaluate each expression.
        # In the case when the inputs are just plain strings (e.g. the answer to a multiple choice question), Invoke-Expression just returns the same string
        # In the case when the inptus are code strings, the code is 
        if($ExecuteCode)
        {
            Write-Verbose "Executing code"
            $UserInput = Invoke-Expression $UserInput
            $Solution = Invoke-Expression $Solution
        }
        else
        {
            $UserInput = $UserInput.Trim()
            $Solution = $Solution.Trim()
        }
        
        Write-Verbose "Comparing input to solution"
        $diff = (Compare-Object $UserInput $Solution -ErrorAction Stop | 
                    Select-Object -ExpandProperty SideIndicator
                ) 

        if ($diff.Count -ne 0)
        {
            Write-Verbose "Input does not match solution"
            throw 
        }
        else
        {
            Write-Verbose "Input matches the solution"
        }
    }
    catch
    {
        throw "Input does not match solution"
    }
}

function Write-UserIncorrect
{
    <#
        .SYNOPSIS
        Write a message indicating that the user answered incorrectly

        .DESCRIPTION
        Write a message to the information stream, chosen from one or more possible messages, indicating an incorrect answer.
    #>
    [CmdletBinding()]
    param
    (
    )
    Write-Information "Incorrect. Try again"
}

function Write-UserCorrect
{
    <#
        .SYNOPSIS
        Write a message indicating that the user answered correctly

        .DESCRIPTION
        Write a message to the information stream, chosen from one or more possible messages, indicating a correct answer.
    #>
    [CmdletBinding()]
    param
    (
    )
    Write-Information "Correct."
}
