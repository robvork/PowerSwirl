function pswirl
{
    [CmdletBinding()]

    param
    (
    )
    
    $database = "PowerSwirl"
    $server_instance = "ROBERTG\SQL14"
    $SQLCMD_object_type = "PSObject"

    Write-Host "Welcome to PowerSwirl" -ForegroundColor Green 
    
    #Choose an arbitrary numbering for abbreviated course selection
    $query = 
@"
                SELECT ROW_NUMBER() OVER (ORDER BY course_sid DESC) AS choice, course_sid, course_id 
                FROM dbo.course_hdr;
"@

    $course_hdr = Invoke-SQLCMD2 -ServerInstance $server_instance `
    -Database $database `
    -Query $query `
    -As $SQLCMD_object_type
    
    # Keep executing the following loop until a lesson is chosen.
    # This policy lets the user go back to the course list if he wishes to change his course selection
    $returnToCourses = $true
    do
    {
        Write-Output "The following courses are available" 
        foreach($course in $course_hdr)
        {
            Write-Output ($course.choice.ToString() + " : " +$course.course_id)
        }

        $max_choice = ($course_hdr.choice | measure -Maximum).Maximum.ToString()
        Write-Output "Choose a course between 1 and $max_choice above or press q to quit.`n"

        do
        {
            $choice = Read-Host "Choice" 

            if($choice.tolower() -eq "q")
            {
                Write-Output "Exiting PowerSwirl. Goodbye..."
                return
            }

            #check whether the input was an integer. only convert if so
            if($choice -match "^[\d]+$")
            {
                $choice = [int] $choice
            }

            #choice is invalid if it did not match the integer pattern above or it is not in the right range
            if($choice -isnot [int] -or $choice -lt 1 -or $choice -gt $max_choice)
            {
                 Write-Host "Invalid choice. Try again or press q to quit" -ForegroundColor Red
            }
            else
            {
                 break
            }
        } while($true)
  
    
        $choice_id = ($course_hdr | Where-Object {$_.choice -eq $choice}).course_id
        Write-Host "Course chosen: $choice_id`n" -ForegroundColor Green 
    
        $course_sid = ($course_hdr | Where-Object {$_.choice -eq $choice}).course_sid

        $query = 
@"
                 SELECT ROW_NUMBER() OVER (ORDER BY course_sid) AS choice, lesson_sid, lesson_id
                 FROM dbo.lesson_hdr
                 WHERE course_sid = $course_sid 
"@

        $lesson_hdr = Invoke-SQLCMD2 -ServerInstance $server_instance `
                                     -Database $database `
                                     -AS $SQLCMD_object_Type `
                                     -Query $query`

                  
        Write-Output "The following lessons are available for course: $choice_id"
        foreach($lesson in $lesson_hdr)
        {
            Write-Output ($lesson.choice.toString() + " : " + $lesson.lesson_id)
        }

        $max_lesson = ($lesson_hdr.choice | Measure-Object -Maximum).Maximum.ToString()

        Write-Output "Choose a lesson between 1 and $max_lesson above, press c to return to courses, or q to quit"

        <#
        # Keep prompting for lesson until one of the following is true:
            * User chooses a valid lesson number
            * User chooses to quit PowerSwirl by typing "q"
            * User chooses to return to course list
        #>
        $continueLessonChoice = $true
        do
        {
            $choice = Read-Host "Choice" 

            if($choice.tolower() -eq "c")
            {
                Write-Host "Returning to course list`n" -ForegroundColor Green
                break
            }

            if($choice.tolower() -eq "q")
            {
                Write-Output "Exiting PowerSwirl. Goodbye..."
                return
            }
        
            if($choice -match "^[\d]+$")
            {
                $choice = [int] $choice
            }

            if($choice -isnot [int] -or $choice -lt 1 -or $choice -gt $max_lesson)
            {
                 Write-Host "Invalid choice. Try again or press c to return to courses or q to quit." -ForegroundColor Red
            }
            else
            {
                $continueLessonChoice = $false 
                $returnToCourses = $false
                $choice_id = ($lesson_hdr | Where-Object {$_.choice -eq $choice}).lesson_id
                Write-Host "Lesson chosen: $choice_id`n" -ForegroundColor Green                
            }
        }
        while($continueLessonChoice)

    } while($returnToCourses)

    # When PSwirl reaches this point, the user has chosen a lesson and so we can begin the teaching!

    

}

function Import-Lesson
{
    <#
        .SYNOPSIS
        Generate a lesson for PowerSwirl from a CSV file

        .DESCRIPTION
        Given a file with the first two lines specifying 
        the course_id and lesson_id and the remaining lines
        detailing the step promprts, requires_input_flag, and solution,
        insert appropriate entries into the PowerSwirl database to make
        the lessons available to users

        .PARAMETER path
        path must be a CSV file with the following format:
        The first row should contain two entries: "course_id" and "lesson_id"
        The second row should contain two entries, a non-empty course_id and lesson_id
        The third row should contain 3 entries: "step_prompt", "requires_input", "solution". 
        All remaining rows should contain 3 entries, with rows listed in the order they should appear to the user

    #>
    [CmdletBinding()]

    param
    (
        [ValidateNotNullOrEmpty()]
        [Parameter(ValueFromPipeline=$true)]
        [string]
        [alias("Source", "LessonFile", "File")]
        $Path
    )

    if(-not (test-path $path))
    {
        Write-Host "Specified file does not exist. Check your path and try again" -ForegroundColor Red
        return
    }

    if(-not ((split-path $path -leaf) -match ".*csv"))
    {
        Write-Host "Specified file is not a csv file. Please use a csv file" -ForegroundColor Red
        return
    }

    $total_line_count = (gc $Path | mo -line).Lines
    if($total_line_count -lt 4)
    {
        Write-Host "For the lesson to have at least one prompt, the csv file must contain at least 4 lines" -ForegroundColor Red
        return
    }

    $firstline = (gc -path $Path) | Select -first 1
    $thirdline = (gc -path $Path) | Select -first 1 -Skip 2

    if($firstline.trimend(",") -ne "course_id,lesson_id")
    {
        Write-Host "The first line must have two entries: course_id, lesson_id" -ForegroundColor Red
        return
    }
    if($thirdline -ne "step_prompt,requires_input,solution")
    {
        Write-Host "The third line must have three entries: step_prompt,requires_input,solution" -ForegroundColor Red
        return
    }

    $serverInstance = "ROBERTG\SQL14"
    $database = "PowerSwirl"

    $section1 = (Get-Content -Path $Path -Head 2) | ConvertFrom-CSV 
    $section2 = (Get-Content -Path $Path -Tail ($total_line_count - 2)) | ConvertFrom-CSV 

    $course_id = $section1.course_id
    $lesson_id = $section1.lesson_id
    $num_steps = ($section2 | mo).count
    $step_num = 1
    $lesson_in_progress = 0
    $lesson_completed = 0

    $query = 
@"
              SELECT ISNULL(
                                (
                                    SELECT course_sid
                                    FROM course_hdr
                                    WHERE course_id = '$course_id'
                                ), 
                                (
                                    SELECT MAX(course_sid) + 1
                                    FROM course_hdr
                                )
                            ) AS course_sid;
                             
"@

    $course_sid = Invoke-SQLCMD2 -ServerInstance $serverInstance `
                                 -Database $database  `
                                 -Query $query | Select-Object -ExpandProperty course_sid

    $query =
@"
               IF EXISTS(SELECT * 
                         FROM dbo.lesson_hdr 
                         WHERE lesson_id = '$lesson_id'
                            AND course_sid = $course_sid)
                    SELECT 1 AS lesson_id_exists;
               ELSE
                    SELECT 0 AS lesson_id_exists;
"@

    $lesson_id_exists = Invoke-SQLCMD2 -ServerInstance $serverInstance `
                                        -Database $database `
                                        -Query $query |
                                        Select-Object -ExpandProperty lesson_id_exists
    if($lesson_id_exists -eq 1)
    {
        Write-Host "Lesson with passed in name already exists. Choose a unique lesson name" -ForegroundColor Red
        return
    }

    $query =
@"
               SELECT ISNULL(MAX(lesson_sid), 0) + 1 AS lesson_sid
               FROM dbo.lesson_hdr
               WHERE course_sid = $course_sid;
"@

    $lesson_sid = Invoke-SQLCMD2 -ServerInstance $serverInstance `
                                 -Database $database `
                                 -Query $query | Select-Object -ExpandProperty lesson_sid

    #If course is new, insert entry into course_hdr
    $query =
@"
             IF NOT EXISTS
             (
                SELECT * 
                FROM dbo.course_hdr
                WHERE course_sid = $course_sid 
             )
                INSERT INTO dbo.course_hdr(course_sid, course_id)
                VALUES($course_sid, '$course_id');
"@
    Invoke-SQLCMD2 -ServerInstance $serverInstance `
                   -Database $database `
                   -Query $query

    #Insert entry into lesson_hdr
    $query =
@"
             INSERT INTO dbo.lesson_hdr(course_sid, lesson_sid, lesson_id)
             VALUES($course_sid, $lesson_sid, '$lesson_id');

"@
    
    Invoke-SQLCMD2 -ServerInstance $serverInstance `
                   -Database $database `
                   -Query $query

    #Insert summary information into course_dtl
    $query =
@"
              INSERT INTO dbo.course_dtl(course_sid, lesson_sid, step_num, num_steps, lesson_in_progress, lesson_completed)
              VALUES($course_sid, $lesson_sid, $step_num, $num_steps, $lesson_in_progress, $lesson_completed)
"@

    Invoke-SQLCMD2 -ServerInstance $serverInstance `
                   -Database $database `
                   -Query $query

    #Insert individual steps into lesson_dtl
    $step_num = 1
    foreach($step in $section2)
    {
        $step_prompt = $step.step_prompt.toString().replace("'", "''")
        $requires_input = $step.requires_input.toString()
        $solution = $step.solution.toString()
        
        $query =
@"
              INSERT INTO dbo.lesson_dtl(course_sid, lesson_sid, step_num, step_prompt, requires_input, solution)
              VALUES($course_sid, $lesson_sid, $step_num, '$step_prompt', $requires_input, $solution)
"@
            
        Invoke-SQLCMD2 -ServerInstance $serverInstance `
                       -Database $database `
                       -Query $query
        $step_num += 1 
    }
    
}