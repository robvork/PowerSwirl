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
        $User

    ,   [String] 
        $CourseID

    ,   [String]
        $LessonID

    ,   [Int]
        $Step
    )
    $PowerSwirlConnection = Get-PowerSwirlConnection
    $ServerInstance = $PowerSwirlConnection.ServerInstance 
    $Database = $PowerSwirlConnection.Database 

    #region initialize information stream
    Write-Verbose "<* Initializing information stream variable for output"
    $InformationAction = Initialize-PSwirlStream
    Write-Verbose "*> Initialization complete. InformationAction = $InformationAction"
    #endregion 
    
    #region greeting
    Write-Information "Welcome to PowerSwirl, an interactive shell environment for learning programming skills" -InformationAction $InformationAction
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
        Write-Verbose "`t* Lesson not valid. Prompting user with available lessons for chosen course and requesting selection"
        do 
        {
            try
            {
                Write-LessonSelections $LessonSelections -InformationAction $InformationAction
                $Selection = Read-MenuSelection 
                Test-MenuSelection -MenuSelections $LessonSelections -MenuSelection $Selection
                $LessonSid = $LessonSelections | 
                                Where-Object -FilterScript {$_.selection -eq $Selection.Selection} |
                                Select-Object -ExpandProperty Lesson | 
                                Select-Object -ExpandProperty LessonSID
                
                 
                break
            }
            catch
            {
                Write-Verbose "`t* Lesson selection invalid. Getting new value"
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
    
    Start-PowerSwirlLesson -ServerInstance $ServerInstance -Database $Database -CourseSid $CourseSid -LessonSid $LessonSid -UserSid $UserSid -StepNum 1
    #endregion

}

function Start-PowerSwirlLesson
{
    [CmdletBinding()]
    param
    (
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

    $PowerSwirlConnection = Get-PowerSwirlConnection
    $ServerInstance = $PowerSwirlConnection.ServerInstance 
    $Database = $PowerSwirlConnection.Database 

    $Params = @{
       ServerInstance=$ServerInstance
    ;  Database=$Database 
    ;  CourseSid=$CourseSid
    ;  LessonSid=$LessonSid
    }

    $LessonInfo = Get-LessonInfo @Params
    $CourseID = $LessonInfo.courseID
    $LessonID = $LessonInfo.lessonID
    $StepCount = $LessonInfo.stepCount
    Write-Verbose "Course: $CourseID"
    Write-Verbose "Lesson: $LessonID"
    Write-Verbose "Step count: $StepCount"

    $LessonContent = Get-LessonContent @Params
    Write-Verbose "Beginning lesson"

    for($StepIdx = ($StepNumStart - 1); $StepIdx -lt $StepCount; $StepIdx++)
    {
        $CurrentStep = $LessonContent[$StepIdx]
        $StepNumCurrent = $CurrentStep.stepNum
        $StepPrompt = $CurrentStep.stepPrompt
        $StepRequiresPause = $CurrentStep.requiresPause
        $StepRequiresSolution = [bool] $CurrentStep.requiresSolution
        $StepRequiresCodeExecution = [bool] $CurrentStep.requiresCodeExecution
        $StepRequiresSetVariable = [bool] $CurrentStep.requiresSetVariable
        Write-Verbose "Lesson step $StepNumCurrent"

        Write-LessonPrompt -Prompt $StepPrompt 

        if($StepRequiresCodeExecution)
        {
            $CodeToExecute = $CurrentStep.codeToExecute
            $Res = Invoke-Expression $CodeToExecute
            if($StepRequiresSetVariable)
            {
                $VariableToSet = $CurrentStep.variableToSet
                Set-Variable -Name $VariableToSet -Value $Res -Scope Global
            }
        }

        if($StepRequiresPause -and (-not $DisableForcePause))
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

        if($StepRequiresSolution)
        {
            Write-Verbose "Step requires solution"
            # The first time the step is encountered, $PauseLesson should be true, so the lesson will be paused
            # The second time the step is encountered, we just resumed a lesson with $DisableForcePause = true, so we don't pause again
           
            $SolutionExpression = $CurrentStep.solutionExpression
            $RequiresSolutionExecution = [bool] $CurrentStep.requiresSolutionExecution
            do
            {
                try
                {
                    $UserInput = Read-StepInput 
                    Test-StepInput -UserInput $UserInput -Solution $SolutionExpression -ExecuteCode:$RequiresSolutionExecution
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
        }
        else
        {
            Read-Host 
            Write-Verbose "Step does not require input"
        }
        Write-Verbose "Step completed"
    }

    Write-Verbose "Lesson completed"
    Write-Information "Lesson completed. Type 'Start-PowerSwirl' to explore available lessons or use 'Start-PowerSwirlLesson' with appropriate parameters to start a new lesson."
}

function Install-PowerSwirl
{
    [CmdletBinding()]
    param
    (
        [Switch] $Force
    ,
        [String] $DataTypesPath  
    ,
        [String] $TablesPath  
    ,
        [String] $ConstraintsPath  
    ,
        [String] $FunctionsPath
    ,
        [String] $ProceduresPath
    ,
        [String] $ViewsPath   
    ,
        [String] $TriggersPath
    )

    <# 
     **** Outline ****
     Is $ServerInstance valid?
     => Yes 
        Proceed
     => No
        Halt

     Does $Database already exist on $ServerInstance?
     => Yes
         Was force specified? 
         => Yes
                 Kill connections and drop database
         => No 
                 Raise error
     => No 
         Proceed with the installation process

     # For each (ObjectType, Path), is the path empty?
        # => Yes 
            # Continue to the next pair
        # => No
            # Is the Path valid?
            # => Yes
                # Run all *.sql scripts at that path (no recursion) against $ServerInstance, $Database

     *Object creation order*
     Create database
     Create data types
     Create tables
     Create constraints
     Create triggers
     Create functions
     Create procedures 
     Create views

     
    #>

    try 
    {
        Set-StrictMode -Version Latest
        $PowerSwirlConnection = Get-PowerSwirlConnection
        $ServerInstance = $PowerSwirlConnection.ServerInstance 
        $Database = $PowerSwirlConnection.Database 

        # Is $ServerInstance a reachable SQL Server Instance? 
        Write-Verbose "Testing SQL Server Instance '$ServerInstance'"
        Test-SQLServerInstance $ServerInstance -ConnectionTimeout 5
        
        # Does $ServerInstance already have a database named $Database?
        Write-Verbose "Checking whether database '$Database' already exists on $ServerInstance"
        [string] $Query = "
                    SELECT 
                        CASE 
                            WHEN EXISTS (SELECT * FROM sys.databases WHERE name = '$Database')
                            THEN 
                                1
                            ELSE 
                                0
                        END AS databaseExists
                    ;
                "

        [bool] $databaseExists = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "master" -ConnectionTimeout 3 -Query $Query |
                                 Select-Object -ExpandProperty databaseExists

        # If database exists, we need to determine whether we can safely clobber it. We clobber only if the Force parameter is used
        if($databaseExists)
        {
            Write-Verbose "Database exists"
            if($Force)
            {
                Write-Verbose "Force parameter specified. Dropping database '$Database'"
                [String] $Query = "
                        BEGIN
                            ALTER DATABASE [$Database]
                            SET SINGLE_USER
                            WITH ROLLBACK IMMEDIATE;

                            DROP DATABASE [$Database];
                        END;
                        GO
                "
                Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "master" -Query $Query 
            }
            else 
            {
                Write-Verbose "Force parameter not specified. Halting."
                throw "Database '$Database' already exists on '$ServerInstance' and -Force was not enabled. Use -Force to confirm overwriting this database."    
            }
        }
        else {
            Write-Verbose "Database does not exist"
        }

        # Beyond this point, either the database existed and we dropped it, or it did not exist. In either case, we can create a fresh database and all of its attendant objects

        # Create database
        Write-Verbose "Creating database '$Database'"
        [string] $Query = "CREATE DATABASE [$Database];"

        Invoke-Sqlcmd -ServerInstance $ServerInstance -Database "master" -Query $Query 

        # Define order of objects to be compiled. By design, within each object type, the order of script execution is irrelevant.
        Write-Verbose "Defining object to path mappings"
        $ObjectToScriptMaps = @(
            @{
                ObjectType="DataTypes";
                Path=$DataTypesPath
            },
            @{
                ObjectType="Tables";       
                Path=$TablesPath
            },
            @{
                ObjectType="Constraints";  
                Path=$ConstraintsPath
            },
            @{
                ObjectType="Triggers";     
                Path=$TriggersPath
            },
            @{
                ObjectType="Functions";    
                Path=$FunctionsPath
            },
            @{
                ObjectType="Procedures";   
                Path=$ProceduresPath
            },
            @{
                ObjectType="Views";
                Path=$ViewsPath
            }
        )

        # Loop through the object types in the order listed above. 
        Write-Verbose "Iterating over object to path mappings"
        for($i = 0; $i -lt $ObjectToScriptMaps.Length; $i++)
        {
            $map = $ObjectToScriptMaps[$i]
            $objectType = $map["ObjectType"]
            $path = $map["Path"]
            Write-Verbose "Defining objects of type '$objectType'"

            # Is the path empty or NULL?
            if($path -eq "" -or $path -eq $null)
            {
                # Proceed to the next object type. Note that we are being lenient here because we may not need each object type to make the database operational
                Write-Verbose "No path specified for objectType = '$objectType'"
                continue 
            }
            # Does the path indicate a valid directory?
            elseif (-not (Test-Path $path -PathType Container))
            {
                Write-Verbose "Invalid path detected"
                throw "ObjectType '$objectType' has an invalid path at '$path'"
            } else 
            {
                # Run 0 or more SQL scripts found at that path.
                Write-Verbose "Fetching scripts for objectType = '$objectType'"
                $scripts = Get-ChildItem $path -Filter *.sql | 
                           Select-Object -ExpandProperty FullName
                if($scripts -eq $null)
                {
                    Write-Verbose "No SQL scripts found for objectType = '$objectType'"
                    continue 
                }
                else 
                {
                    # The order of script execution is irrelevant
                    foreach($s in $scripts)
                    {
                        Write-Verbose "Creating objectType '$objectType' by running script '$s' on $ServerInstance.$Database"
                        Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -InputFile $s 
                    }
                }
            }

        }
        
    }
    catch 
    {
        throw $_.Exception.Message
    }

   
}

function Set-PowerSwirlConnection
{
    param
    (
        [String] $ServerInstance
    ,
        [String] $Database
    )

    $powerswirlPath = Get-Module -Name "PowerSwirl" | 
                      Select-Object -ExpandProperty Path | 
                      Split-Path -Parent 
    $configPath = (Join-Path $powerswirlPath "config.xml")
    if(-not (Test-Path $configPath))
    {
        $configFileData = "<config>`n" + 
                          "`t<ServerInstance>$ServerInstance</ServerInstance>`n" + 
                          "`t<Database>$Database</Database>`n" + 
                          "</config>"
        Set-Content -Path $configPath -Value $configFileData
    }
    else 
    {
        $config = [xml] (Get-Content $configPath)

        # Configure SQL Server Instance and Database names
        $config.config.ServerInstance = $ServerInstance
        $config.config.Database = $Database
        
        $config.Save($configPath)
    }
    
    
    
}

function Get-PowerSwirlConnection
{
    $powerswirlPath = Get-Module -Name "PowerSwirl" | 
                      Select-Object -ExpandProperty Path | 
                      Split-Path -Parent 
    $configPath = (Join-Path $powerswirlPath "config.xml")
    if(-not (Test-Path $configPath))
    {
        throw "The config file does not exist. Use Set-PowerSwirlConnection to create the config file."
    }
    $config = [xml] (Get-Content $configPath)
    
    # Configure SQL Server Instance and Database names
    $ServerInstance = $config.config.ServerInstance 
    $Database = $config.config.Database 

    $ConfigProperties = @{
        ServerInstance=$ServerInstance;
        Database=$Database;
    }
    $Config = New-Object -TypeName PSObject -Property $ConfigProperties

    Write-Output $Config 
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