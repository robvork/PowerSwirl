function Import-LessonHeader
{
    param
    (
        [string] $CourseID
    ,   [string] $LessonID
    )
}

function Test-LessonHeader
{}

class LessonDetail
{
    [String] $StepPrompt
    [Boolean] $RequiresInputFlag 
    [Boolean] $ExecuteCodeFlag
    [Boolean] $StoreVariableFlag
    [String] $Solution
    [String] $Variable 

    LessonDetail( [String] $StepPrompt,
    [Boolean] $RequiresInputFlag, 
    [Boolean] $ExecuteCodeFlag,
    [Boolean] $StoreVariableFlag,
    [String] $Solution,
    [String] $Variable
    )
    {
        $this.StepPrompt = $StepPrompt;
        $this.RequiresInputFlag = $RequiresInputFlag;
        $this.ExecuteCodeFlag = $ExecuteCodeFlag;
        $this.StoreVariableFlag = $StoreVariableFlag;
        $this.Solution = $Solution;
        $this.Variable = $Variable; 
    }

}

function Import-LessonDetail
{
    <#
        .SYNOPSIS 
        Imports lesson detail rows 

        .DESCRIPTION
        Merges lesson detail rows into database as a single operation
    #>
    param
    (
        [LessonDetail[]] $LessonDetail
    )
}

function New-Course
{
    <#
        .SYNOPSIS
        Creates a new course 

        .DESCRIPTION
        Generates a new course record with no associated lessons and returns the corresponding course sid for further processing. 
    #>
    param
    (
        [String] $CourseName 
    )

}

function New-Lesson
{
    <#
        .SYNOPSIS
        Creates a new lesson for a given course

        .DESCRIPTION
        Generates a new lesson record for a given course and returns the corresponding lesson sid for further processing
    #>
    param
    (
        [String] $CourseSid
    ,   [String] $CourseName 
    )
}