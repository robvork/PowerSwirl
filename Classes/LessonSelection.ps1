class LessonSelection : MenuSelection
{
    [Lesson] $Lesson

    LessonSelection([Int]$Selection, [String] $LessonID, [Int] $LessonSID)
        :base($Selection)
    {
        $this.Lesson = New-Lesson -LessonID $LessonID -LessonSID $LessonSID
    }

    [String] ToString() 
    {
        return $this.Selection.ToString() + ": " + $this.LessonID
    }

    [bool] Equals([Object] $other)
    {
        return ($other -is [LessonSelection]) -and ($other.selection.equals($this.Selection)) -and ($other.Lesson -eq $this.Lesson)
    }
}

function New-LessonSelection
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Int] $Selection
    ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $LessonID
    ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Int] $LessonSID
    )

    Write-Output ([LessonSelection]::new($Selection, $LessonID, $LessonSid))
}