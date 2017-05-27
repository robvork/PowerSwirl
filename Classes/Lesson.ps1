class Lesson 
{
    [String] $LessonID 
    [Int] $LessonSID 

    Lesson([String] $LessonID, [Int] $LessonSID)
    {
        $this.LessonID = $LessonID 
        $this.LessonSID = $LessonSID 
    }

    [bool] Equals([Object] $other)
    {
        return ($other -is [Lesson]) -and ($other.LessonID -eq $this.LessonID -and $other.LessonSID -eq $this.LessonSID)
    }

    [String] ToString()
    {
        return $this.LessonID.ToString()
    }
}