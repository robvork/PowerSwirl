class LessonSelection : MenuSelection
{
    [String] $LessonID 
    [Int] $LessonSID 

    LessonSelection([Int]$Selection, [String] $LessonID, [Int] $LessonSID)
        :base($Selection)
    {
        $this.LessonID = $LessonID
        $this.LessonSID = $LessonSID 
    }

    [String] ToString() 
    {
        return $this.Selection.ToString() + ": " + $this.LessonID
    }

    [bool] Equals([Object] $other)
    {
        return ($other -is [LessonSelection]) -and ($other.LessonID = $this.LessonID -and $other.LessonSID -eq $this.LessonSID)
    }
}