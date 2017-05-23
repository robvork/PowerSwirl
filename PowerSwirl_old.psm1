function Start-PowerSwirl
{
    [CmdletBinding()]

    param
    (
    )
    
    $params_Invoke_SQLCMD2 = @{}

    $params_Invoke_SQLCMD2["Database"] = "PowerSwirl"
    $params_Invoke_SQLCMD2["ServerInstance"] = "ASPIRING\SQL16"
    $params_Invoke_SQLCMD2["As"] = "PSObject"

    Write-Host "Welcome to PowerSwirl" -ForegroundColor Green
    $user_id = $env:USERNAME

    $query = "EXEC dbo.p_get_user @as_user_id = '$user_id'"
<#@"
    DECLARE @lb_user_exists BIT = 1;
    IF NOT EXISTS(SELECT * FROM dbo.user_hdr WHERE user_id = '$user_id')
    BEGIN
        INSERT INTO dbo.user_hdr(user_id) 
        VALUES('$user_id');
        SET @lb_user_exists = 0;
    END

    SELECT user_sid, @lb_user_exists AS user_exists
    FROM dbo.user_hdr
@"#>
    $params_Invoke_SQLCMD2["Query"] = $query
      
    $user_info = Invoke-SQLCMD2 @params_Invoke_SQLCMD2
    $user_sid = $user_info.user_sid
    $user_exists = $user_info.user_exists 

    if($user_exists)
    {
        Write-Host "Welcome back, $user_id"
    }
    else
    {
        Write-Host "New login created for username '$user_id'"
    }
   

    #Choose an arbitrary numbering for abbreviated course selection
    $query =  "EXEC dbo.p_get_courses"
<#@"
    SELECT ROW_NUMBER() OVER (ORDER BY course_id) AS choice, course_sid, course_id 
    FROM dbo.course_hdr
    ORDER BY course_id;
@"#>
    $params_Invoke_SQLCMD2["query"] = $query 

    $course_hdr = Invoke-SQLCMD2 @params_Invoke_SQLCMD2
    
    # Keep executing the following loop until a lesson is chosen.
    # This policy lets the user go back to the course list if he wishes to change his course selection
    $return_to_courses = $true
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

        $query = "EXEC dbo.p_get_lessons @ai_course_sid = $course_sid"
<#@"
                 SELECT ROW_NUMBER() OVER (ORDER BY lesson_id) AS choice, lesson_sid, lesson_id
                 FROM dbo.lesson_hdr
                 WHERE course_sid = $course_sid 
                 ORDER BY lesson_id
@"#>

        $params_Invoke_SQLCMD2["query"] = $query

        $lesson_hdr = Invoke-SQLCMD2 @params_Invoke_SQLCMD2

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
        $continue_lesson_choice = $true
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
                $continue_lesson_choice = $false 
                $return_to_courses = $false
                $choice_id = ($lesson_hdr | Where-Object {$_.choice -eq $choice}).lesson_id
                $lesson_sid = ($lesson_hdr | Where-Object {$_.choice -eq $choice}).lesson_sid
                Write-Host "Lesson chosen: $choice_id`n" -ForegroundColor Green                
            }
        }
        while($continue_lesson_choice)

    } while($return_to_courses)
    
    #Write-Host "Done" -ForegroundColor DarkYellow
    Start-PowerSwirlLesson -course_sid $course_sid -lesson_sid $lesson_sid -user_sid $user_sid

}

function Start-PowerSwirlLesson
{
    [CmdletBinding()]
    param
    (
        [ValidateNotNullOrEmpty()]
        [int] $course_sid,

        [ValidateNotNullOrEmpty()]
        [int] $lesson_sid,

        [ValidateNotNullOrEmpty()]
        [int] $step_num = 0,

        [ValidateNotNullOrEmpty()]
        [int] $user_sid,

        [switch] $disableForcePause
    )
     

    #Remove any lesson-in progress variables from the global scope
    #Remove-Variable -Force -Scope "global" -Name "course_sid","lesson_sid","step_num" -ErrorAction SilentlyContinue

    $params_Invoke_SQLCMD2 = @{}
    $params_Invoke_SQLCMD2["ServerInstance"] = "ASPIRING\SQL16"
    $params_Invoke_SQLCMD2["Database"] = "PowerSwirl"
    $params_Invoke_SQLCMD2["As"] = "PSObject"

    $params_Invoke_SQLCMD2["Query"] = $query = "EXEC dbo.p_get_lesson_content @ai_course_sid = $course_sid, @ai_lesson_sid = $lesson_sid"
<#@"
                 SELECT step_num, step_prompt AS prompt, lesson_sid, requires_input_flag, execute_code_flag, store_var_flag, variable, solution
                 FROM dbo.lesson_dtl
                 WHERE course_sid = $course_sid AND lesson_sid = $lesson_sid
"@#>

    $lesson_dtl = Invoke-SQLCMD2 @params_Invoke_SQLCMD2

    $params_Invoke_SQLCMD2["Query"] = $query = "EXEC dbo.p_get_lesson_info @ai_course_sid = $course_sid, @ai_lesson_sid = $lesson_sid"
<#@"
                 SELECT COUNT(*) AS num_steps
                 FROM dbo.lesson_dtl
                 WHERE course_sid = $course_sid AND lesson_sid = $lesson_sid
"@#>  
    $lesson_info = Invoke-SQLCMD2 @params_Invoke_SQLCMD2  
    $num_steps = $lesson_info.num_steps
    $course_id = $lesson_info.course_id
    $lesson_id = $lesson_info.lesson_id
    Write-Host "Loading course $course_id, lesson $lesson_id" -ForegroundColor Green 

    function codeObjectsEqual
    {
        param
        (
            $code1,
            $code2
        )

        Try
        {
            $diff = (Compare-Object (Invoke-Expression $code1) (Invoke-Expression $code2) -ErrorAction Stop | Select-Object -ExpandProperty SideIndicator) 
            return ($diff.Count -eq 0)
        }
        Catch
        {
            return $false 
        }
    }

    $pauseLesson = $false
    for($step = $step_num; $step -lt $num_steps; $step += 1)
    {
        $curr = $lesson_dtl[$step]

        Write-Output $curr.step_prompt

        if($step % 4 -eq 3 -and -not $disableForcePause)
        {
             $pauseLesson = $true
             break
        }

        if($curr.store_var_flag)
        {
            if($curr.execute_code_flag)
            {
                Set-Variable -name $curr.variable -Value (Invoke-Expression $curr.solution) -Scope "global"
            }
            else
            {
                Set-Variable -name $curr.variable -Value $curr.solution -Scope "global"
            }
                
        }

        if($curr.requires_input_flag)
        {
            if(-not $disableForcePause)
            {
                $pauseLesson = $true
                break
            }


             $solution = $curr.solution
             
             Write-Host "Type 'play' to enter code mode, or attempt an answer to the question"        

           
             #Write-Output "$solution"
             #Write-Output (Invoke-Expression "$solution")
             #Write-Output "..."
             #Read-Host | Out-Null
            $user_correct = $false 
            do
            {
                $input = Read-Host "`n"

                if($input -eq "")
                {
                    continue
                }
                elseif($input -eq "play")
                {
                    $pauseLesson = $true
                    break
                }

                $user_correct = codeObjectsEqual -code1 $input -code2 $solution 
                 
                if(!$user_correct)
                {
                    Write-Host "Not quite. Try again.`n" -ForegroundColor DarkGreen
                }
                else
                {
                    Write-Host "Correct!`n" -ForegroundColor Green 
                    $user_correct = $true 
                }
            }
            while(!$user_correct)

            if($pauseLesson) 
            {
                break
            }
           
   
        }
        else
        {
             $input = Read-Host ":....."
             Write-Output ""
             $input = $input.ToLower()
             if($input -eq "play")
             {
                break
             }
        } 
        $input = ""
    }

    if($pauseLesson)
    {
        <#
        $global_scope = "global"
        Set-Variable -Name course_sid -Value $course_sid -Scope $global_scope -Force -Option ReadOnly
        Set-Variable -Name lesson_sid -Value $lesson_sid -Scope $global_scope -Force -Option ReadOnly
        Set-Variable -Name step_num -Value $step -Scope $global_scope -Force -Option ReadOnly
        #>
        Set-Variable -Name PowerSwirlUser -Value $user_sid -Scope "global"
        $params_Invoke_SQLCMD2["Query"] = "EXEC dbo.p_set_lesson_paused @ai_course_sid = $course_sid,
                                                                        @ai_lesson_sid = $lesson_sid,
                                                                        @ai_user_sid = $user_sid,
                                                                        @ai_step_num = $step"
<#@"
        INSERT INTO dbo.user_pause_state(user_sid, course_sid, lesson_sid, step_num)
        VALUES ($user_sid, $course_sid, $lesson_sid, $step)
"@#>
        
        Invoke-SQLCMD2 @params_Invoke_SQLCMD2
        Write-Host "Pausing PowerSwirl lesson, enabling code mode. Explore on your own and type 'nxt' to continue your lesson when you're ready." -ForegroundColor Green 
        return 
    }

     
}

function nxt
{
    [CmdletBinding()]
    param
    (
    )

    Try
    {
        <#
        $parent_scope = 2
        $inputs = Get-Variable -Name "course_sid","lesson_sid","step_num" -Scope $parent_scope         
        $input_count = $inputs | Measure-Object | Select -ExpandProperty Count
        if($input_count -ne 3)
        {
            Remove-Variable -Name "inputs","input_count","parent_scope"
            return
        }

        $bad_vals = $inputs |
                Where-Object {$_.Value -eq $null -or $_.Value -isnot [int]}
        if($bad_vals -ne $null)
        {
            throw "All inputs must be non-null ints."
        }#>
        $params_Invoke_SQLCMD2 = @{}

        $params_Invoke_SQLCMD2["Database"] = "PowerSwirl"
        $params_Invoke_SQLCMD2["ServerInstance"] = "ASPIRING\SQL16"
        $params_Invoke_SQLCMD2["As"] = "PSObject"
        $params_Invoke_SQLCMD2["Query"] = "EXEC dbo.p_get_user @as_user_id = '$($env:USERNAME)'" 
        $user_sid = Invoke-SQLCMD2 @params_Invoke_SQLCMD2 | Select-Object -ExpandProperty user_sid

        $params_Invoke_SQLCMD2["Query"] = $query = "EXEC dbo.p_get_pause_info @ai_user_sid = $user_sid"
<#@"
        SELECT course_sid, lesson_sid, step_num 
        FROM dbo.user_pause_state 
        WHERE user_sid = $PowerSwirlUser
"@#>
       
        $pause_info = Invoke-SQLCMD2 @params_Invoke_SQLCMD2
        $course_sid = $pause_info.course_sid 
        $lesson_sid = $pause_info.lesson_sid 
        $step_num = $pause_info.step_num

        $params_Invoke_SQLCMD2["Query"] = $query = "EXEC dbo.p_delete_user_pause_info @ai_user_sid = $user_sid"
<#@"
        DELETE FROM dbo.user_pause_state 
        WHERE user_sid = $PowerSwirlUser
"@#>
        
        Invoke-SQLCMD2 @params_Invoke_SQLCMD2

        Write-Host "Resuming lesson..." -ForegroundColor Green 

        Start-PowerSwirlLesson -course_sid $course_sid -lesson_sid $lesson_sid -step_num $step_num -user_sid $user_sid -disableForcePause
    }
    Catch
    {
        Write-Host "PowerSwirl resume failed: $($_.Exception.Message)" -ForegroundColor Red 
    }

}

function Import-PowerSwirlLesson
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
        $Path,

        [switch]
        $Force 
    )

    Try
    {

    Write-Verbose "Checking that input file exists"
    if(-not (test-path $path))
    {
        throw "Specified file does not exist. Check your path and try again" 
    }

    Write-Verbose "Checking that input file is a csv file"
    if(-not ((split-path $path -leaf) -match ".*csv"))
    {
        throw "Specified file is not a csv file. Please use a csv file" 
    }

    Write-Verbose "Checking that input file has the minimal amount of content"
    $total_line_count = (gc $Path | mo -line).Lines
    if($total_line_count -lt 4)
    {
        throw "For the lesson to have at least one prompt, the csv file must contain at least 4 lines" 
    }

    
    Write-Verbose "Checking that the first and third lines of the file contain the proper field names"
    $lessonHeader1 = (gc -path $Path) | Select -first 1 | ForEach-Object {$_.TrimEnd(",")}
    $lessonHeader2 = (gc -path $Path) | Select -first 1 -Skip 2 | ForEach-Object {$_.TrimEnd(",")}
    $templateHeader1 = Get-Content -Path D:\PowerSwirl\import_template.csv | Select-Object -First 1 -Skip 0 | ForEach-Object {$_.TrimEnd(",")}
    $templateHeader2 = Get-Content -Path D:\PowerSwirl\import_template.csv | Select-Object -First 1 -Skip 2 | ForEach-Object {$_.TrimEnd(",")}
    if($lessonHeader1 -ne $templateHeader1)
    {
        throw "The first line must match the following exactly: $templateHeader1" 
    }
    if($lessonHeader2 -ne $templateHeader2)
    {
        throw "The third line must match the following exactly: $templateHeader2" 
    }
    
    $serverInstance = "ASPIRING\SQL16"
    $database = "PowerSwirl"


    Write-Verbose "Loading hdr and dtl sections from file"
    $section1 = (Get-Content -Path $Path -Head 2) | ConvertFrom-CSV 
    $section2 = (Get-Content -Path $Path -Tail ($total_line_count - 2)) | ConvertFrom-CSV 


    Write-Verbose "Replacing empty values with 0 or NULL wherever appropriate"

    function fieldIsEmpty
    {
        param
        (
            [string] $field
        )

        return $field -eq "" -or $field -eq $null
    }

    foreach($step in $section2)
    {
        if(fieldIsEmpty($step.requires_input_flag))
        {
            $step.requires_input_flag = "0"
        }
        if(fieldIsEmpty($step.execute_code_flag))
        {
            $step.execute_code_flag = "0"
        }
        if(fieldIsEmpty($step.store_var_flag))
        {
            $step.store_var_flag = "0" 
        }
        if(fieldIsEmpty($step.solution))
        {
            $step.solution = $null
        }
        if(fieldIsEmpty($step.variable))
        {
           $step.variable = $null
        }

    
    } 

    $course_id = $section1.course_id
    $lesson_id = $section1.lesson_id
    $num_steps = ($section2 | mo).count
    $step_num = 1
    $lesson_in_progress_flag = 0
    $lesson_completed_flag = 0

    Write-Verbose "Finding existing course_sid or creating new course_sid for this new lesson"
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

    Write-Verbose "Checking if lesson with chosen name already exists. Error out unless if so unless -Force used"
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
        if($Force)
        {
            $query =
@"
              DECLARE @li_lesson_sid SID = (SELECT lesson_sid 
                                            FROM dbo.lesson_hdr 
                                            WHERE lesson_id = '$lesson_id'
                                                AND course_sid = $course_sid);
              DELETE FROM dbo.lesson_dtl
              WHERE lesson_sid = @li_lesson_sid; 

              SELECT @li_lesson_sid AS lesson_sid
"@            
        }
        else
        {
            throw "Lesson with passed in name already exists. Choose a unique lesson name or use the -Force switch to reimport lesson" 
        }
    }
    else
    {
            $query =
@"
               SELECT ISNULL(MAX(lesson_sid), 0) + 1 AS lesson_sid
               FROM dbo.lesson_hdr
               WHERE course_sid = $course_sid;
"@
    }
    Write-Verbose "Determining lesson sid of current lesson"
    $lesson_sid = Invoke-SQLCMD2 -ServerInstance $serverInstance `
                                 -Database $database `
                                 -Query $query | Select-Object -ExpandProperty lesson_sid

    #If course is new, insert entry into course_hdr
    Write-Verbose "Checking whether course is new. Inserting new course_hdr row if so. Otherwise, doing nothing."
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
    
    #Insert entry into lesson_hdr if it's new
    Write-Verbose "Checking whether this lesson already exists and this execution is revising it. Inserting new lesson_hdr row if so. `
                   Otherwise, doing nothing."
    $query =
@"
             IF NOT EXISTS(SELECT * FROM dbo.lesson_hdr WHERE course_sid = $course_sid AND lesson_sid = $lesson_sid)
                 INSERT INTO dbo.lesson_hdr(course_sid, lesson_sid, lesson_id)
                 VALUES($course_sid, $lesson_sid, '$lesson_id');

"@
    Invoke-SQLCMD2 -ServerInstance $serverInstance `
                   -Database $database `
                   -Query $query

    #Insert summary information into course_dtl
    Write-Verbose "If lesson already exists, deleting metadata associated with it and generating new metadata"
    $query =
@"
              IF EXISTS(SELECT * FROM dbo.course_dtl WHERE course_sid = $course_sid AND lesson_sid = $lesson_sid)
                DELETE FROM dbo.course_dtl WHERE course_sid = $course_sid AND lesson_sid = $lesson_sid

              INSERT INTO dbo.course_dtl(course_sid, lesson_sid, step_num, lesson_in_progress_flag, lesson_completed_flag)
              VALUES($course_sid, $lesson_sid, $step_num, $lesson_in_progress_flag, $lesson_completed_flag)
"@

    Invoke-SQLCMD2 -ServerInstance $serverInstance `
                   -Database $database `
                   -Query $query

    #Insert individual steps into lesson_dtl
    Write-Verbose "Inserting individual lesson steps into dbo.lesson_dtl"
    $step_num = 1
    foreach($step in $section2)
    {
         
        $step_prompt = "'$($step.step_prompt.toString().replace("'", "''"))'"
        $requires_input = $step.requires_input_flag
        $execute_code = $step.execute_code_flag
        $store_var = $step.store_var_flag
        
        # NULL without single quotes is interpreted as a NULL value
        if($step.variable -eq $null)
        {
            $var = "NULL"
        }
        #If the var is not a PowerShell null, it has some non-empty string as its value and we need to use single quotes
        else 
        {
            $var = "'$($step.variable)'"
        }
        
        # NULL without single quotes is interpreted as a NULL value in SQL Server
        if($step.solution -eq $null)
        {
            $solution = "NULL"
        }
        #If the solution is not a PowerShell null, it has some non-empty string as its value and we need to use single quotes
        else
        {
            $solution = "'$($step.solution)'"
        }
        
        $query =
@"
              INSERT INTO dbo.lesson_dtl(course_sid, lesson_sid, step_num, step_prompt, requires_input_flag, execute_code_flag, store_var_flag, solution, variable)
              VALUES($course_sid, $lesson_sid, $step_num, $step_prompt, $requires_input, $execute_code, $store_var, $solution, $var)
"@
           
        Write-Verbose $query 
        Invoke-SQLCMD2 -ServerInstance $serverInstance `
                       -Database $database `
                       -Query $query
        $step_num += 1 
    
    }
        
    }
    catch
    {
        Write-Host "Error encountered: $($_.Exception.Message)" -ForegroundColor Red 
    }
}