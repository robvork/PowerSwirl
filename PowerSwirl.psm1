<#######################################################################################
PowerSwirl

PowerSwirl is an interactive environment for learning PowerShell, SQL, and other programming languages
and concepts.
########################################################################################>

function Start-PowerSwirl
{
    <#
    .SYNOPSIS
    Open the PowerSwirl main menu to choose a course and lesson
    
    .DESCRIPTION
    The entrypoint for using PowerSwirl. Executing this command does the following in the order listed:
    Prompt for a user name. If the user name is not recognized, ask if the user should be created. Proceeds when either a valid user has been entered or created.
    List the available courses and prompt for a selection. Proceeds when a valid selection is made. 
    List the available lessons for the selected course. Proceeds when a valid selection is made. 
    Once the user, course, and lesson have been determined as described above, calls Start-PowerSwirlLesson to begin the chosen course and lesson for the user. 
    
    .PARAMETER User
    An optional user profile. Bypasses the interactive user login process if it's a valid user. If it's not valid, the command will ask whether to create a new user 
    with this name. If not, a new user login process begins. 
    
    .PARAMETER CourseID
    An optional CourseID selection. Bypasses the interactive course selection process if it is a valid CourseID. 
    
    .PARAMETER LessonID
    An optional lessonID selection. Bypasses the interactive lesson selection if it is a valid LessonID for the selected CourseID. 
    
    .EXAMPLE
    Start-PowerSwirl
    This command starts PowerSwirl so that the user login, course selection, and lesson selection process is all done interactively in the console.

    .EXAMPLE
    Start-PowerSwirl -User "rob" -CourseID "PowerShell Orientation" -LessonID "Using the Help System"
    This command starts PowerSwirl with the user "rob", CourseID "PowerShell Orientation", and LessonID "using the Help System". If all of these inputs are valid, the command immediately begins the chosen lesson for the user.
    
    .NOTES
    This command must be executed in a console-based host. 
    #>
    [CmdletBinding()]
    param
    (
        [String]
        $User

    ,   [String] 
        $CourseID

    ,   [String]
        $LessonID
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
            Write-Verbose "`t* User invalid."
            $CreateNewUser = Read-MultipleChoiceInput -Prompt "User '$User' was not found. Would you like to create a new user with this id? (y/n)" -PossibleAnswers "y","n"
            if($CreateNewUser -eq "y")
            {
                Register-PSwirlUser -UserName $User
            }
            else {
                $User = Read-PSwirlUser    
            }
        }
    } while ($true)

    Write-Verbose "`tUsing User= $User, UserSid = $UserSid"
    #endregion

    # Determine course
    #region validate or get Course
    $CourseSelections = Get-CourseSelections
    try
    {
        Write-Verbose "`t<* Validating course"
        $CourseSid = Test-PSwirlCourse -CourseID $CourseID
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
    $LessonSelections = Get-LessonSelections -CourseSID $CourseSid
    try
    {
        Write-Verbose "`t<* Validating lesson"
        $LessonSid = Test-PSwirlLesson -CourseSid $CourseSid -LessonID $LessonID
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
    
    $LessonParams = @{
        CourseSid=$CourseSid; 
        LessonSid=$LessonSid; 
        UserSid=$UserSid; 
        StepNum=1;
    }
    Start-PowerSwirlLesson @LessonParams
    #endregion

}

function Start-PowerSwirlLesson
{
    <#
    .SYNOPSIS
    Enters the PowerSwirl lesson mode
    
    .DESCRIPTION
    Starts or resumes a given PowerSwirl course and lesson for a given user at a specified step. Called by Start-PowerSwirl once user, course, and lesson IDs are translated into database SIDs. Can be called from elsewhere once this translation is complete. 
    
    .PARAMETER CourseSid
    The course SID of the lesson to start
    
    .PARAMETER LessonSid
    The lesson SID of the lesson to start
    
    .PARAMETER UserSid
    The user SID of the user taking the lesson.
    
    .PARAMETER StepNumStart
    The optional step at which to start the lesson. Defaults to the first step of the lesson. 
    
    .PARAMETER DisableForcePause
    Disables the pause mechanism for the first step requiring pause. Enabled when encountering a step for the second time to disable repeated pausing. 
    
    .EXAMPLE
    Start-PowerSwirlLesson -UserSid 3 -CourseSid 1 -LessonSid 2
    This command starts the lesson with course SID 1, lesson SID 2, for the user with SID 3

    .EXAMPLE 
    Start-PowerSwirlLesson -UserSid 2 -CourseSid 2 -LessonSid 3 -StepNum 5
    This command starts the lesson with course SID 2, lesson SID 3, for the user with SID 2 on the 5th step.
    #>
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
       CourseSid=$CourseSid;
       LessonSid=$LessonSid;
    }

    $LessonInfo = Get-LessonInfo @Params
    $CourseID = $LessonInfo.courseID
    $LessonID = $LessonInfo.lessonID
    $StepCount = $LessonInfo.stepCount
    Write-Verbose "Course: $CourseID"
    Write-Verbose "Lesson: $LessonID"
    Write-Verbose "Step count: $StepCount"

    $LessonContent = Get-LessonContent @Params
    $PauseEnabled = (-not $DisableForcePause)
    Write-Verbose "Beginning lesson"

    for($StepIdx = ($StepNumStart - 1); $StepIdx -lt $StepCount; $StepIdx++)
    {
        $CurrentStep = $LessonContent[$StepIdx]
        $StepNumCurrent = $CurrentStep.stepNum
        $StepPrompt = $CurrentStep.stepPrompt
        $StepRequiresPause = [bool] $CurrentStep.requiresPause
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

        if($StepRequiresPause)
        {
            if($PauseEnabled)
            {
                Write-LessonPrompt -Prompt "Pausing lesson. Explore on your own, then type 'nxt' to continue with the lesson"
                Write-Verbose "Pausing lesson and saving user's progress"
                $SaveLessonParams = @{
                    CourseSid = $CourseSid
                ;   LessonSid = $LessonSid
                ;   StepNum = ($StepNumCurrent + 1) # step numbers are 1 based, whereas the index to the array is 0 based
                ;   UserSid = $UserSid 
                }
                
                # if on step n, we need to pause and we don't need a solution, resume on step n+1
                    # if the lesson has at least n+1 steps, this causes a resume on the n+1st step
                    # if the lesson has n steps, then the resume will still work, but the step loop will immediately terminate and the lesson will be complete
                # if however we need to pause and we DO need a solution, we must come back to the step we paused at so that the user can input the solution
                if(-not $StepRequiresSolution)
                {
                    $SaveLessonParams["StepNum"] += 1
                }
                Save-Lesson @SaveLessonParams
                Start-Sleep -Seconds 3
                return
            }
            else
            {
                $PauseEnabled = $true  
            }
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
    <#
    .SYNOPSIS
    Installs the PowerSwirl database objects and sets the module database connection parameters
    
    .DESCRIPTION
    Begins by storing the ServerInstance and Database that will support PowerSwirl in a configuration file. 
    
    Then installs the database, data types, tables, constraints, functions, procedures, views, and triggers of PowerSwirl on the specified ServerInstance and Database. 
    
    If the database already exists, this command will drop and recreate the database if and only if the Force parameter is used. If the database exists and the Force parameter is not used, this command raises an error and halts. 

    Each of the paths to be specified is optional, but for normal installation, it is highly recommended to specify all relevant paths.
    
    Paths may be ommitted for development purposes.
    
    .PARAMETER ServerInstance
    The ServerInstance that will be hosting PowerSwirl
    
    .PARAMETER Database
    The Database that will be hosting PowerSwirl on ServerInstance
    
    .PARAMETER Force
    If enabled, drops and recreates the database if it already exists. If the database exists and this parameter is not enabled, the command raises a terminating error. 
    
    .PARAMETER DataTypesPath
    The path to the data type create SQL scripts. The 1st type of object to be created. 
    If omitted, the command will attempt the installation process skipping this step.
    
    .PARAMETER TablesPath
    The path to the table create SQL scripts. The 2nd type of object to be created. 
    If omitted, the command will attempt the installation process skipping this step.
    
    .PARAMETER ConstraintsPath
    The path to the constraint create SQL scripts. The 3rd type of object to be created. 
    If omitted, the command will attempt the installation process skipping this step.
    
    .PARAMETER FunctionsPath
    The path to the function create SQL scripts. The 4th type of object to be created. 
    If omitted, the command will attempt the installation process skipping this step.
    
    .PARAMETER ProceduresPath
    The path to the procedure create SQL scripts. The 5th type of object to be created. 
    If omitted, the command will attempt the installation process skipping this step.
    
    .PARAMETER ViewsPath
    The path to the view create SQL scripts. The 6th type of object to be created. 
    If omitted, the command will attempt the installation process skipping this step.
    
    .PARAMETER TriggersPath
    The path to the trigger create SQL scripts. The 7th type of object to be created. 
    If omitted, the command will attempt the installation process skipping this step.
    
    .EXAMPLE
    Install-PowerSwirl -ServerInstance "RVKSQL16" -Database "PowerSwirl" -DataTypesPath "C:\PowerSwirl\DataTypes" -TablesPath "C:\PowerSwirl\Tables" -ConstraintsPath "C:\PowerSwirl\Constraints" -FunctionsPath "C:\PowerSwirl\Functions" -ProceduresPath "C:\PowerSwirl\Procedures" -ViewsPath "C:\PowerSwirl\Views" -TriggersPath "C:\PowerSwirl\Triggers"
    This command installs the PowerSwirl database on SQL ServerInstance "RVKSQL16", database "PowerSwirl", with each of the paths specified as subdirectories of C:\PowerSwirl. Since the Force parameter was not used, the command will halt with a terminating error if "PowerSwirl" already exists on RVKSQL16.
    #>
    [CmdletBinding()]
    param
    (
        [String] $ServerInstance
    ,
        [String] $Database 
    ,
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

    try 
    {
        Set-StrictMode -Version Latest
        Set-PowerSwirlConnection -ServerInstance $ServerInstance -Database $Database 
        <#
        $PowerSwirlConnection = Get-PowerSwirlConnection
        $ServerInstance = $PowerSwirlConnection.ServerInstance 
        $Database = $PowerSwirlConnection.Database 
        #>

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
    <#
    .SYNOPSIS
    Sets the database connection parameters for PowerSwirl
    
    .DESCRIPTION
    Sets the SQL Server Instance name and Database name to be used by all PowerSwirl functions. Stores this information in a configuration xml file 'config.xml' 
    located in the PowerSwirl module root directory. If the file already contains a ServerInstance and Database setting, this command overwrites it with the specified values. 
    At any given time, PowerSwirl must have exactly 1 configuration setting stored. Multiple databases can be supported, but the connection settings must be handled accordingly. 
    
    .PARAMETER ServerInstance
    The SQL Server Instance hosting the PowerSwirl database
    
    .PARAMETER Database
    The database name of the PowerSwirl database on ServerInstance
    
    .EXAMPLE
    Set-PowerSwirlConnection -ServerInstance "RVKSQL16" -Database "PowerSwirl"
    This command sets the database connection settings to ServerInstance="RVKSQL16" and Database "PowerSwirl". 
    All PowerSwirl functions subsequently use these settings in operation.
    
    #>
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
    <#
    .SYNOPSIS
    Gets the PowerSwirl database connection settings
    
    .DESCRIPTION
    Reads the PowerSwirl ServerInstance and Database from config.xml in the PowerSwirl root directory. config.xml can be created and edited
    by using Set-PowerSwirlConnection (recommended) or manually. 
    
    .EXAMPLE
    Get-PowerSwirlConnection | Select-Object ServerInstance, Database
    This command fetches the connection information and displays these properties using Select-Object.
    #>

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
