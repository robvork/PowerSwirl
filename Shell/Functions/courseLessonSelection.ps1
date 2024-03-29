function Write-RetryPrompt 
{
    [CmdletBinding()]
    param
    (
        [String] $Message
    )
    if($Message -eq "" -or $Message -eq $null)
    {
        throw "Message must be not null and not empty"
    }
    else
    {
        Write-Information -MessageData $Message -Tags Message
        Write-Information -MessageData "Please try again." -Tags PostMessage
    }
}

function Read-MenuSelection
{
    try
    {
        $Selection = [int](Read-Host -Prompt "Enter your selection")
        Write-Output (New-MenuSelection $Selection)
    }
    catch 
    {
        throw "Selection not convertible to int"
    }
}

function Write-CourseSelections
{
    [CmdletBinding()]
    param
    (
        [CourseSelection[]] $CourseSelections
    )

    if($CourseSelections -eq $null)
    {
        throw "Courses must be non-null"
    }

    Write-Information -MessageData $CourseSelections.Length -Tags CourseCount -InformationAction SilentlyContinue
    Write-Information -MessageData "Choose a course from the following" -Tags PreSelection
    foreach($CourseSelection in $CourseSelections)
    {
        Write-Information -MessageData $CourseSelection.ToString() -Tags CourseSelectionString
    }
}

function Write-LessonSelections
{
    [CmdletBinding()]
    param
    (
        $LessonSelections
    )

    Write-Information -Message $LessonSelections.Length -Tags LessonCount -InformationAction SilentlyContinue
    Write-Information -MessageData "Choose a lesson from the following" -Tags PreSelection
    foreach($LessonSelection in $LessonSelections)
    {
        Write-Information -MessageData $LessonSelection.ToString() -Tags LessonSelectionString
    }
}

function Get-Course
{
    param
    (
       [String] $CourseID
    )

    try
    {
        $PowerSwirlConnection = Get-PowerSwirlConnection
        $ServerInstance = $PowerSwirlConnection.ServerInstance 
        $Database = $PowerSwirlConnection.Database 
        Test-SQLServerInstance $ServerInstance
        Test-SQLServerDatabase -ServerInstance $ServerInstance -Database $Database 
        
        if($CourseID -eq "" -or $CourseID -eq $null)
        {
            throw "Course must be not null and not empty"
        }
        
        $Query = "EXECUTE dbo.p_get_course @as_course_id = '$CourseID'"
        $TestResult = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $Query 
        $TestResult | 
            Select-Object CourseExists, CourseSID |
            Write-Output   
    }
    catch
    {
        throw $_.Exception.Message 
    }
}

function Test-PSwirlCourse
{
    param
    (
        $CourseID
    )
    $PowerSwirlConnection = Get-PowerSwirlConnection
    $ServerInstance = $PowerSwirlConnection.ServerInstance 
    $Database = $PowerSwirlConnection.Database 
    $Params = @{
        ServerInstance=$ServerInstance;
        Database=$Database; 
        CourseID=$CourseID;
    }

    $TestResult = Get-Course @Params 

    if($TestResult.CourseExists)
    {
        Write-Output $TestResult.CourseSid
    }
    else
    {
        throw "Course does not exist"
    }
}

function Get-Lesson 
{
    [CmdletBinding()]
    param
    (
        [Int] $CourseSID 
    ,
        [String] $LessonID
    )
    $PowerSwirlConnection = Get-PowerSwirlConnection
    $ServerInstance = $PowerSwirlConnection.ServerInstance 
    $Database = $PowerSwirlConnection.Database 
    try
    {
        Test-SQLServerInstance $ServerInstance
        Test-SQLServerDatabase -ServerInstance $ServerInstance -Database $Database 
        
        if($CourseSID -eq $null)
        {
            throw "Course must be not null"
        }

        if($LessonID -eq "" -or $LessonID -eq $null)
        {
            throw "Lesson must be not null and not empty"
        }
        
        $Query = "EXECUTE dbo.p_get_lesson @ai_course_sid = $CourseSID, @as_lesson_id = '$LessonID'"
        $TestResult = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $Query 
        $TestResult | 
            Select-Object LessonExists, LessonSID |
            Write-Output   
    }
    catch
    {
        throw $_.Exception.Message 
    }
}

function Test-PSwirlLesson
{
     param
    (
        $CourseSID
    ,   $LessonID 
    )

    $PowerSwirlConnection = Get-PowerSwirlConnection
    $ServerInstance = $PowerSwirlConnection.ServerInstance 
    $Database = $PowerSwirlConnection.Database 
    $Params = @{
        CourseSID=$CourseSID;
        LessonID=$LessonID; 
    }
    $TestResult = Get-Lesson @Params

    if($TestResult.LessonExists)
    {
        Write-Output $TestResult.LessonSID
    }
    else
    {
        throw "Lesson does not exist"
    }

}

function Test-MenuSelection
{
    param
    (
        [MenuSelection[]] $MenuSelections
    ,   [MenuSelection] $MenuSelection
    )

    if($MenuSelection.Selection -notin $MenuSelections.Selection)
    {
        throw "Invalid menu selection"
    }
}

function Get-CourseSelections
{
    <#
        .SYNOPSIS
        Get PowerSwirl course selections 

        .DESCRIPTION
        Get the PowerSwirl course headers. A course header record consists of a descriptive name and a numeric course sid. 
        The user sees the descriptive name, but the database processes the course sid. 
    #>
    [CmdletBinding()]
    param
    (
    )

    $PowerSwirlConnection = Get-PowerSwirlConnection
    $ServerInstance = $PowerSwirlConnection.ServerInstance 
    $Database = $PowerSwirlConnection.Database 

    $Query = "EXEC dbo.p_get_courses"
    $Courses = Invoke-SqlCmd2 -ServerInstance $ServerInstance -Database $Database -Query $Query 

    Test-HasNoDBNulls $Courses "selection"
    Test-HasNoDBNulls $Courses "courseID"
    Test-HasNoDBNulls $Courses "courseSID"

    Test-HasNoEmptyStrings $Courses "courseID"

    Test-HasNoDuplicates $Courses "selection"
    Test-HasNoDuplicates $Courses "courseID"
    Test-HasNoDuplicates $Courses "courseSID"


    foreach($c in $Courses)
    {
        $courseSelection = New-CourseSelection -Selection $c.Selection -CourseID $c.CourseID -CourseSID $c.CourseSID 
        Write-Output $courseSelection
    }
}

function Get-Courses
{
    [CmdletBinding()]
    param
    (
    )
    $PowerSwirlConnection = Get-PowerSwirlConnection
    $ServerInstance = $PowerSwirlConnection.ServerInstance 
    $Database = $PowerSwirlConnection.Database 

    $Params = @{
        ServerInstance = $ServerInstance;
        Database=$Database; 
    }
    Get-CourseSelections @Params | 
    Select-Object -ExpandProperty Course
}

function Get-LessonSelections
{
    <#
        .SYNOPSIS
        Get PowerSwirl lesson selections

        .DESCRIPTION
        Get the PowerSwirl lesson headers. A lesson header record consists of numeric lesson sids and a descriptive name.
        The user sees the descriptive name, but the database processes the lesson sid.
    #>
    [CmdletBinding()]
    param
    (
        [int]
        $CourseSID
    )
    
    $PowerSwirlConnection = Get-PowerSwirlConnection
    $ServerInstance = $PowerSwirlConnection.ServerInstance 
    $Database = $PowerSwirlConnection.Database 

    $Query = "EXECUTE dbo.p_get_lessons @ai_course_sid = $CourseSid"
    $Lessons = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $Query 
    foreach($l in $Lessons)
    {
        $LessonSelection = New-LessonSelection -Selection $l.Selection -LessonID $l.lessonID -LessonSID $l.lessonSID 
        Write-Output $LessonSelection
    }

}

function Test-HasNoDBNulls
{
    param
    (
        [Object[]] $Objects
    ,
        [String] $Property
    )

    if($Objects -eq $null -or $Property -eq $null)
    {
        throw "Objects and property must be not null"
    }

    if($Property -eq "")
    {
        throw "Property must be non-empty"
    }

    if($Property -notin ($Objects | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name))
    {
        throw "Property must be a property of the objects"
    }

    if($Objects[$Property] | Where-Object {$_ -is [System.DBNull]})
    {
        throw "Values of '$Property' must be non-null"
    }   
}


function Test-HasNoDuplicates
{
    param
    (
        [Object[]] $Objects
    ,
        [String] $Property
    )

    if($Objects -eq $null -or $Property -eq $null)
    {
        throw "Objects and property must be not null"
    }

    if($Property -eq "")
    {
        throw "Property must be non-empty"
    }

    if($Property -notin ($Objects | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name))
    {
        throw "Property must be a property of the objects"
    }

    $Count = $Objects.Length 
    $UniqueCount = ($Objects.$Property | 
                   Sort-Object -Unique).Length
                   
    if($Count -ne $UniqueCount)
    {
        throw "Values of '$Property' must be unique"
    }   
}

function Test-HasNoEmptyStrings
{
    param
    (
        [Object[]] $Objects
    ,
        [String] $Property
    )

    if($Objects -eq $null -or $Property -eq $null)
    {
        throw "Objects and property must be not null"
    }

    if($Property -eq "")
    {
        throw "Property must be non-empty"
    }

    if($Property -notin ($Objects | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name))
    {
        throw "Property must be a property of the objects"
    }

    if($Objects[$Property] -contains "")
    {
        throw "Values of '$Property' must be non-empty"
    }
}







