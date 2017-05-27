class CourseSelection : MenuSelection
{
    [Course] $Course

    CourseSelection([Int]$Selection, [String] $CourseID, [Int] $CourseSID) 
        : base($Selection) 
    {
        $this.Course = New-Course -CourseID $CourseID -CourseSID $CourseSID
    }

    [String] ToString() 
    {
        return $this.Selection.ToString() + ": " + $this.course.CourseID.ToString()
    }

    [bool] Equals([Object] $other)
    {
        return ($other -is [CourseSelection]) -and ($other.selection.equals($this.Selection)) -and ($other.course.equals($this.course))
    }
}

function New-CourseSelection
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Int] $Selection
    ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Int] $CourseSID 
    ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $CourseID
    )

    Write-Output ([CourseSelection]::new($Selection, $CourseID, $CourseSID))
}