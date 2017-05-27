class Course 
{
    [String] $CourseID 
    [Int] $CourseSID 

    Course([String] $CourseID, [Int] $CourseSID)
    {
        $this.CourseID = $CourseID
        $this.CourseSID = $CourseSID
    }

    [bool] Equals ([Object] $other)
    {
        return ($other -is [Course]) -and ($other.CourseID -eq $this.CourseID -and $other.CourseSID -eq $this.CourseSID)
    }
}