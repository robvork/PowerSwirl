function Save-Lesson
{
    <#
        .SYNOPSIS
        Save the progress on the current lesson

        .DESCRIPTION
        Store the user's current step number within the course and lesson. 
        A call to Resume-Lesson depends on a prior execution of this command.
    #>
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
}