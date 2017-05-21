<#######################################################################################
PowerSwirl

PowerSwirl is an interactive environment for learning PowerShell, SQL, and other programming languages
and concepts.
########################################################################################>


#region new
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
            Write-Verbose "Validating ServerInstance..."
            Test-SQLServerInstance $ServerInstance -ErrorAction SilentlyContinue
            Write-Verbose "ServerInstance valid"
            break
        }
        catch
        {
            Write-Verbose "ServerInstance invalid. Getting new value"
            Write-RetryPrompt -Message $_.Exception.Message
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
            Write-RetryPrompt -Message $_.Exception.Message 
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
            Write-Verbose "Validating user"
            Test-PSwirlUser -PSwirlUser $User
            Write-Verbose "User valid" 
            break
        }
        catch
        {
            Write-Verbose "User invalid. Getting new value"
            Write-RetryPrompt -Message $_.Exception.Message 
            $User = Read-PSwirlUser
        }
    } while ($true)
    
    return

    # Determine course
    try
    {
        Write-Verbose "Validating course"
        Test-PSwirlCourse -ServerInstance $ServerInstance -Database $Database -CourseID $CourseID
        Write-Verbose "Course valid"
    }
    catch
    {
        Write-Verbose "Course not valid. Prompting user with available courses and requesting selection"
        $Courses = Get-CourseHeader -ServerInstance $ServerInstance -Database $Database 
        do 
        {
            try
            {
                Write-CourseHeader $Courses 
                $Selection = Read-MenuSelection 
                Test-MenuSelection -ChoiceObjects $CourseList 
                 
                break
            }
            catch
            {
                Write-Verbose "Course selection invalid. Getting new value"
                Write-RetryPrompt -Message $_.Exception.Message 
            }
        } while ($true)
    }
    
    # Determine lesson
    try
    {
        Write-Verbose "Validating lesson"
        Test-PSwirlLesson -ServerInstance $ServerInstance -Database $Database -CourseID $CourseID -LessonID $LessonID
        Write-Verbose "Lesson valid"
    }
    catch
    {
        Write-Verbose "Lesson not valid. Prompting user with available lessons for chosen course and requesting selection"
        $LessonsInCourse = Get-CourseDetail -ServerInstance $ServerInstance -Database $Database 
       
        do 
        {
            try
            {
                Write-CourseHeader $Courses 
                $Selection = Read-MenuSelection 
                Test-MenuSelection -ChoiceObjects $CourseList 
                 
                break
            }
            catch
            {
                Write-Verbose "Course selection invalid. Getting new value"
                Write-RetryPrompt -Message $_.Exception.Message 
            }
        } while ($true)
    }



}
#endregion 


Set-Alias -Name "psw" -Value "Start-PowerSwirl"
Set-Alias -Name "pswirl" -Value "Start-PowerSwirl"
Set-Alias -Name "pswl" -Value "Start-PowerSwirlLesson"
Set-Alias -Name "impswl" -Value "Import-PowerSwirlLesson"

Export-ModuleMember -Function Start-PowerSwirl -Alias pswirl, psw 
#Export-ModuleMember -Function Start-PowerSwirlLesson -Alias 
<#
Export-ModuleMember -Function Start-PowerSwirl -Alias "psw","pswirl"
Export-ModuleMember -Function Start-PowerSwirlLesson -Alias "pswl"
Export-ModuleMember -Function nxt
Export-ModuleMember -Function Import-PowerSwirlLesson -Alias "impswl"
#>