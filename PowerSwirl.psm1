<#######################################################################################
PowerSwirl

PowerSwirl is an interactive environment for learning PowerShell, SQL, and other programming languages
and concepts.
########################################################################################>

function Start-PowerSwirl
{
    [CmdletBinding()]
    param
    (
        [String]
        $ServerInstance

    ,   [String]
        $Database

    ,   [String]
        $User

    ,   [String] 
        $CourseID

    ,   [String]
        $LessonID

    ,   [Int]
        $Step
    )

    #region initialize information stream
    Write-Verbose "<* Initializing information stream variable for output"
    $InformationAction = Initialize-PSwirlStream
    Write-Verbose "*> Initialization complete. InformationAction = $InformationAction"
    #endregion 
    
    #region validating/determining lesson parameters
    Write-Verbose "<* Determining and validating parameter values"

    # Determine ServerInstance
    #region validate or get ServerInstance
    if($ServerInstance -eq '' -or $ServerInstance -eq $null)
    {
        $ServerInstance = Read-SQLServerInstance
    }

    Write-Verbose "`t<* Validating ServerInstance"
    do
    {
        try
        {
            Test-SQLServerInstance $ServerInstance -ErrorAction SilentlyContinue
            Write-Verbose "`t*> ServerInstance valid"
            break
        }
        catch
        {
            Write-Verbose "`t* ServerInstance invalid. Getting new value"
            Write-RetryPrompt -Message $_.Exception.Message -InformationAction $InformationAction
            $ServerInstance = Read-SQLServerInstance
        }
    } while($true) 

    Write-Verbose "`tUsing ServerInstance = $ServerInstance"
    #endregion

    # Determine Database
    #region validate or get Database
    if($Database -eq '' -or $Database -eq $null)
    {
        $Database = Read-SQLServerDatabase
    }

    do
    {
        try
        {
            Write-Verbose "`t<* Validating Database"
            Test-SQLServerDatabase -ServerInstance $ServerInstance -Database $Database
            Write-Verbose "`t*> Database valid"
            break
        }
        catch
        {
            Write-Verbose "`t*Database invalid. Getting new value"
            Write-RetryPrompt -Message $_.Exception.Message -InformationAction $InformationAction
            $Database = Read-SQLServerDatabase
        }
    } while ($true)

    Write-Verbose "`tUsing Database=$Database"
    #endregion

    # Determine user
    #region validate or get User
    if($User -eq '' -or $User -eq $null)
    {
        $User = Read-PSwirlUser
    }

    do 
    {
        try
        {
            Write-Verbose "`t<* Validating user '$User'"
            $UserSid = Test-PSwirlUser -ServerInstance $ServerInstance -Database $Database -User $User
            Write-Verbose "`t*> User valid" 
            break
        }
        catch
        {
            Write-Verbose "`t* User invalid. Getting new value"
            Write-RetryPrompt -Message $_.Exception.Message -InformationAction $InformationAction
            $User = Read-PSwirlUser
        }
    } while ($true)

    Write-Verbose "`tUsing User= $User, UserSid = $UserSid"
    #endregion

    # Determine course
    #region validate or get Course
    $CourseSelections = Get-CourseSelections -ServerInstance $ServerInstance -Database $Database 
    try
    {
        Write-Verbose "`t<* Validating course"
        $CourseSid = Test-PSwirlCourse -ServerInstance $ServerInstance -Database $Database -CourseID $CourseID
        Write-Verbose "`t*> Course valid"
    }
    catch
    {
        Write-Verbose "`t* Course not valid. Prompting user with available courses and requesting selection"
        do 
        {
            try
            {
                Write-CourseSelections $CourseSelections -InformationAction $InformationAction
                $Selection = Read-MenuSelection 
                Test-MenuSelection -MenuSelections $CourseSelections -MenuSelection $Selection
                Write-Verbose "`t*> Course selection valid"
                $CourseSid = $CourseSelections | 
                                Where-Object -FilterScript {$_.Selection -eq $Selection.Selection} |
                                Select-Object -ExpandProperty Course | 
                                Select-Object -ExpandProperty CourseSID
                
                break
            }
            catch
            {
                Write-Verbose "Course selection invalid. Getting new value"
                Write-RetryPrompt -Message $_.Exception.Message -InformationAction $InformationAction
            }
        } while ($true)
    }

    Write-Verbose "`tUsing CourseSid = $CourseSid"
    #endregion

    # Determine lesson
    #region validate or get Lesson
    $LessonSelections = Get-LessonSelections -ServerInstance $ServerInstance -Database $Database -CourseSID $CourseSid
    try
    {
        Write-Verbose "`t<* Validating lesson"
        $LessonSid = Test-PSwirlLesson -ServerInstance $ServerInstance -Database $Database -CourseSid $CourseSid -LessonID $LessonID
        Write-Verbose "`t*> Lesson valid"
    }
    catch
    {
        Write-Verbose "Lesson not valid. Prompting user with available lessons for chosen course and requesting selection"
        do 
        {
            try
            {
                Write-LessonSelections $LessonSelections -InformationAction $InformationAction
                $Selection = Read-MenuSelection 
                Test-MenuSelection -MenuSelections $LessonsSelections -MenuSelection $Selection
                $LessonSid = $LessonSelections | 
                                Where-Object -FilterScript {$_.selection -eq $Selection} |
                                Select-Object -ExpandProperty Lesson | 
                                Select-Object -ExpandProperty LessonSID
                
                 
                break
            }
            catch
            {
                Write-Verbose "Course selection invalid. Getting new value"
                Write-RetryPrompt -Message $_.Exception.Message -InformationAction $InformationAction
            }
        } while ($true)
    }
    Write-Verbose "`tUsing LessonSid = $LessonSid"
    Write-Verbose "#> Determination and validation complete"
    #endregion

    #endregion

    #region starting lesson 
    Write-Verbose "Starting PowerSwirl lesson with CourseSid = $CourseSid, LessonSid = $LessonSid, UserSid = $UserSid"
    return
    Start-PowerSwirlLesson -ServerInstance $ServerInstance -Database $Database -CourseSid $CourseSid -LessonSid $LessonSid -UserSid $UserSid -StepNum 1
    #endregion

}

function Start-PowerSwirlLesson
{
    [CmdletBinding()]
    param
    (
        [String] $ServerInstance 
        ,
        [String] $Database
        ,
        [Int] $CourseSid
        ,
        [Int] $LessonSid
        ,
        [Int] $UserSid
        ,
        [Int] $StepNumStart = 1
        ,
        [Switch] $DisableForcePause
    )

    $Params = @{
       ServerInstance=$ServerInstance
    ;  Database=$Database 
    ;  CourseSid=$CourseSid
    ;  LessonSid=$LessonSid
    }

    $LessonInfo = Get-LessonInfo @Params
    $CourseID = $LessonInfo.course_id
    $LessonID = $LessonInfo.lesson_id
    $StepCount = $LessonInfo.step_count
    Write-Verbose "Course: $CourseID"
    Write-Verbose "Lesson: $LessonID"
    Write-Verbose "Step count: $StepCount"

    $LessonContent = Get-LessonContent @Params
    Write-Verbose "Beginning lesson"
    
    $PauseLesson = -not $DisableForcePause.IsPresent
    for($StepIdx = ($StepNumStart - 1); $StepIdx -lt $StepCount; $StepIdx++)
    {
        $CurrentStep = $LessonContent[$StepIdx]
        $StepNumCurrent = $CurrentStep.step_num
        $StepPrompt = $CurrentStep.step_prompt
        $StepRequiresInput = [bool] $CurrentStep.requires_input
        Write-Verbose "Lesson step $StepNumCurrent"

        Write-LessonPrompt -Prompt $StepPrompt 

        if($StepRequiresInput)
        {
            Write-Verbose "Step requires input"
            # The first time the step is encountered, $PauseLesson should be true, so the lesson will be paused
            if($PauseLesson)
            {
                Write-LessonPrompt -Prompt "Pausing lesson. Explore on your own, then type 'nxt' to continue with the lesson"
                Write-Verbose "Pausing lesson and saving user's progress"
                $SaveLessonParams = @{
                    ServerInstance = $ServerInstance
                ;   Database = $Database
                ;   CourseSid = $CourseSid
                ;   LessonSid = $LessonSid
                ;   StepNum = $StepNumCurrent
                ;   UserSid = $UserSid 
                }
                Save-Lesson @SaveLessonParams
                return
            }

            # The second time the step is encountered, we just resumed a lesson with $DisableForcePause = true, so we don't pause again
            else
            {
                $Solution = $CurrentStep.solution
                $ExecuteCode = [bool] $CurrentStep.execute_code_flag
                do
                {
                    try
                    {
                        $UserInput = Read-StepInput 
                        Test-StepInput -UserInput $UserInput -Solution $Solution -ExecuteCode:$ExecuteCode
                        Write-UserCorrect
                        Write-Verbose "User answered correctly."
                        break
                    }
                    catch
                    {
                        Write-UserIncorrect
                        Write-Verbose "User answered incorrectly. Prompting for retry."
                    }
                }
                while($true) 
                $PauseLesson = $true 
            }
            
        }
        else
        {
            Read-Host 
            Write-Verbose "Step does not require input"
        }
        Write-Verbose "Step completed"
    }

   
    Write-Verbose "Lesson completed"
}

Set-Alias -Name "psw" -Value "Start-PowerSwirl"
Set-Alias -Name "pswirl" -Value "Start-PowerSwirl"
Set-Alias -Name "pswl" -Value "Start-PowerSwirlLesson"
Set-Alias -Name "impswl" -Value "Import-PowerSwirlLesson"

<#
Export-ModuleMember -Function Start-PowerSwirl -Alias pswirl, psw 
Export-ModuleMember -Function Start-PowerSwirlLesson -Alias pswl
Export-ModuleMember -Function Resume-Lesson -Alias nxt
#>

<#
Export-ModuleMember -Function Start-PowerSwirl -Alias "psw","pswirl"
Export-ModuleMember -Function Start-PowerSwirlLesson -Alias "pswl"
Export-ModuleMember -Function nxt
Export-ModuleMember -Function Import-PowerSwirlLesson -Alias "impswl"
#>