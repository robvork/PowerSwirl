class CourseSelection : MenuSelection
{
    [Course] $course

    CourseSelection([Int]$Selection, [String] $CourseID, [Int] $CourseSID) 
        : base($Selection) 
    {
        $this.course = [Course]::new($CourseID, $CourseSID)
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