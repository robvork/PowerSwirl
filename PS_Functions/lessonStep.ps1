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
