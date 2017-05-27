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