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

    Write-Verbose "Initializing information stream variable for output"
    $InformationAction = Initialize-PSwirlStream

    Write-Verbose "Validating parameters and reprompting for input whenever necessary"

    # Determine ServerInstance
    if($ServerInstance -eq '' -or $ServerInstance -eq $null)
    {
        $ServerInstance = Read-SQLServerInstance
    }

    do
    {
        try
        {
            Write-Verbose "Validating ServerInstance"
            Test-SQLServerInstance $ServerInstance -ErrorAction SilentlyContinue
            Write-Verbose "ServerInstance valid"
            break
        }
        catch
        {
            Write-Verbose "ServerInstance invalid. Getting new value"
            Write-RetryPrompt -Message $_.Exception.Message -InformationAction $InformationAction
            $ServerInstance = Read-SQLServerInstance
        }
    } while($true) 

    # Determine Database
    if($Database -eq '' -or $Database -eq $null)
    {
        $Database = Read-SQLServerDatabase
    }

    do
    {
        try
        {
            Write-Verbose "Validating Database"
            Test-SQLServerDatabase -ServerInstance $ServerInstance -Database $Database
            Write-Verbose "Database valid"
            break
        }
        catch
        {
            Write-Verbose "Database invalid. Getting new value"
            Write-RetryPrompt -Message $_.Exception.Message -InformationAction $InformationAction
            $Database = Read-SQLServerDatabase
        }
    } while ($true)
    
    # Determine user
    if($User -eq '' -or $User -eq $null)
    {
        $User = Read-PSwirlUser
    }

    do 
    {
        try
        {
            Write-Verbose "Validating user '$User'"
            $UserSid = Test-PSwirlUser -ServerInstance $ServerInstance -Database $Database -User $User
            Write-Verbose "User valid"
            Write-verbose "Using UserSid = $UserSid" 
            break
        }
        catch
        {
            Write-Verbose "User invalid. Getting new value"
            Write-RetryPrompt -Message $_.Exception.Message -InformationAction $InformationAction
            $User = Read-PSwirlUser
        }
    } while ($true)
   
    # Determine course
    $Courses = Get-CourseHeaders -ServerInstance $ServerInstance -Database $Database 
    try
    {
        Write-Verbose "Validating course"
        $CourseSid = Test-PSwirlCourse -ServerInstance $ServerInstance -Database $Database -CourseID $CourseID
        Write-Verbose "Course valid"
    }
    catch
    {
        Write-Verbose "Course not valid. Prompting user with available courses and requesting selection"
        do 
        {
            try
            {
                Write-CourseHeaders $Courses -InformationAction $InformationAction
                $Selection = Read-MenuSelection 
                Test-MenuSelection -MenuObjects $Courses -MenuSelection $Selection
                $CourseSid = $Courses | 
                                Where-Object -FilterScript {$_.Selection -eq $Selection} |
                                Select-Object -ExpandProperty course_sid 
                Write-Verbose "Using CourseSid = $CourseSid"

                break
            }
            catch
            {
                Write-Verbose "Course selection invalid. Getting new value"
                Write-RetryPrompt -Message $_.Exception.Message -InformationAction $InformationAction
            }
        } while ($true)
    }
    
    # Determine lesson
    $LessonsInCourse = Get-LessonHeaders -ServerInstance $ServerInstance -Database $Database -CourseSID $CourseSid
    try
    {
        Write-Verbose "Validating lesson"
        $LessonSid = Test-PSwirlLesson -ServerInstance $ServerInstance -Database $Database -CourseSid $CourseSid -LessonID $LessonID
        Write-Verbose "Lesson valid"
    }
    catch
    {
        Write-Verbose "Lesson not valid. Prompting user with available lessons for chosen course and requesting selection"
        do 
        {
            try
            {
                Write-LessonHeaders $LessonsInCourse -InformationAction $InformationAction
                $Selection = Read-MenuSelection 
                Test-MenuSelection -MenuObjects $LessonsInCourse -MenuSelection $Selection
                $LessonSid = $LessonsInCourse | 
                                Where-Object -FilterScript {$_.selection -eq $Selection} |
                                Select-Object -ExpandProperty lesson_sid 
                Write-Verbose "Using LessonSid = $LessonSid"
                 
                break
            }
            catch
            {
                Write-Verbose "Course selection invalid. Getting new value"
                Write-RetryPrompt -Message $_.Exception.Message -InformationAction $InformationAction
            }
        } while ($true)
    }

    Write-Verbose "Starting PowerSwirl lesson with CourseSid = $CourseSid, LessonSid = $LessonSid, UserSid = $UserSid"
    Start-PowerSwirlLesson -ServerInstance $ServerInstance -Database $Database -CourseSid $CourseSid -LessonSid $LessonSid -UserSid $UserSid -StepNum 1

}

function Start-PowerSwirlLesson
{
    param
    (
        [String] $ServerInstance 
        ,
        [String] $Database
        ,
        [String] $CourseSid
        ,
        [String] $LessonSid
        ,
        [String] $UserSid
        ,
        [String] $StepNum
    )
}

Set-Alias -Name "psw" -Value "Start-PowerSwirl"
Set-Alias -Name "pswirl" -Value "Start-PowerSwirl"
Set-Alias -Name "pswl" -Value "Start-PowerSwirlLesson"
Set-Alias -Name "impswl" -Value "Import-PowerSwirlLesson"

#Export-ModuleMember -Function Start-PowerSwirl -Alias pswirl, psw 
#Export-ModuleMember -Function Start-PowerSwirlLesson -Alias 
<#
Export-ModuleMember -Function Start-PowerSwirl -Alias "psw","pswirl"
Export-ModuleMember -Function Start-PowerSwirlLesson -Alias "pswl"
Export-ModuleMember -Function nxt
Export-ModuleMember -Function Import-PowerSwirlLesson -Alias "impswl"
#>