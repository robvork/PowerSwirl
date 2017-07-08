function Import-Lesson
{
    [CmdletBinding()]
    param
    (
        [String] $ServerInstance
    ,
        [String] $Database
    ,
        [String] $XMLFilePath
    ,
        [Switch] $AbbreviatedXML
   
    )

    $LessonXML = [xml](Get-Content $XMLFilePath)

    if($AbbreviatedXML)
    {
        $CourseID = $LessonXML.Lesson.H.C
        $LessonID = $LessonXML.Lesson.H.L
    }
    
    # do the rest of the work agnostic as to which file type was specified
    
}

function Import-LessonHeader
{
    param
    (
        [string] $CourseID
    ,   [string] $LessonID
    )
}

function Test-LessonHeader
{}

function Import-LessonDetail
{
    <#
        .SYNOPSIS 
        Imports lesson detail rows 

        .DESCRIPTION
        Merges lesson detail rows into database as a single operation
    #>
    param
    (
        [LessonDetail[]] $LessonDetail
    )
}

function New-ImportLesson
{
    [CmdletBinding()]
    param
    (
        [String] $CourseName
    ,
        [String] $LessonName
    ,
        [Parameter(ParameterSetName="PremadeBody")]
        [String[]] $BodyBlock 
    ,
        [Parameter(ParameterSetName="PlaceholderBody")]
        [Int] $SectionCount = 1
    ,
        [Parameter(ParameterSetName="PlaceholderBody")]
        [Int[]] $StepCount = @(2)
    ,
        [Parameter(ParameterSetName="PlaceholderBody")]
        [Int[]] $FullStepCount = @(1)
    )
    
    $HeaderBlock = New-ImportLessonHeader -CourseName $CourseName -LessonName $LessonName
    if($PSCmdlet.ParameterSetName -eq "PlaceholderBody")
    {
        $BodyBlock = New-ImportLessonBody -SectionCount $SectionCount -StepCount $StepCount -FullStepCount $FullStepCount
    } 

    $LessonBlock = New-ImportLessonBlock -Name "Lesson" -Contents ($HeaderBlock + $BodyBlock)

    Write-Output $LessonBlock
}

Set-Alias -Name nil -Value New-ImportLesson 

function New-ImportLessonHeader
{
    param
    (
        [String] $CourseName
    ,
        [String] $LessonName        
    )

    if($CourseName -eq $null -or $CourseName -eq "")
    {
        throw "CourseName must be not null and not empty"
    }
    if($LessonName -eq $null -or $LessonName -eq "")
    {
        throw "LessonName must be nto null and not empty"
    }

    $CourseBlock = New-ImportLessonBlock -Name "Course" -Contents $CourseName
    $LessonBlock = New-ImportLessonBlock -Name "Lesson" -Contents $LessonName

    $HeaderBlock = New-ImportLessonBlock -Name "Header" -Contents ($CourseBlock + $LessonBlock)

    Write-Output $HeaderBlock
}

Set-Alias -Name nilh -Value New-ImportLessonHeader

function New-ImportLessonBody 
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName="PremadeSteps")]
        [string[]] $SectionBlocks
    ,
        [Parameter(ParameterSetName="PlaceholderSections")]
        [Int] $SectionCount = 1
    ,
        [Parameter(ParameterSetName="PlaceholderSections")]
        [Int[]] $StepCount = @(2)
    ,
        [Parameter(ParameterSetName="PlaceholderSections")]
        [Int[]] $FullStepCount = @(1)
    )

    if($PSCmdlet.ParameterSetName -eq "PlaceholderSections")
    {
        if($StepCount.Count -ne $SectionCount)
        {
            throw "StepCount must have a total of NumSections entries."
        }

        if($StepCount | 
            Where-Object -FilterScript {$_ -lt 0})
        {
            throw "StepCount must contain only non-negative integers."
        }

        if($FullStepCount.Count -ne $SectionCount)
        {
            throw "FullStepCount must have a total of NumSections entries."
        }

        if($FullStepCount | 
            Where-Object -FilterScript {$_ -lt 0})
        {
            throw "FullStepCount must contain only non-negative integers."
        }

        $SectionBlocks = (1..$SectionCount) | 
                            ForEach-Object {
                                New-ImportLessonSection -Title "section #$_" -StepCount $StepCount[$_ - 1] -FullStepCount $FullStepCount[$_ - 1]
                            }
    }
    
    $BodyBlock = New-ImportLessonBlock -Name "Body" -Contents $SectionBlocks 

    Write-Output $BodyBlock 
    
}

Set-Alias -Name nilb -Value New-ImportLessonBody 

function New-ImportLessonSection
{
    [CmdletBinding()]
    param
    (
        [String] $Title
    ,
        [Parameter(ParameterSetName="PremadeSteps")]
        [String[]] $StepBlocks
    ,
        [Parameter(ParameterSetName="PlaceholderSteps")]
        [Int] $StepCount = 1
    ,
        [Parameter(ParameterSetName="PlaceholderSteps")]
        [Int] $FullStepCount = 0
    )

    if($Title -eq $null -or $Title -eq "")
    {
        throw "Title must be not null and not empty"
    }

    if($Title.Length -le 4)
    {
        throw "Title must be at least 5 characters"
    }

    if($PSCmdlet.ParameterSetName -eq "PlaceholderSteps")
    {
        if($StepCount -lt 0)
        {
            throw "StepCount must be non-negative"
        }

        if($FullStepCount -lt 0)
        {
            throw "NumStepsFull must be non-negative"
        }

        if($FullStepCount -gt $StepCount)
        {
            throw "FullStepCount must be less than or equal to StepCount"
        }

        $StepBlocks = [String[]] @()
        if($StepCount -gt 0)
        {
            $FullStepBlocks = [String[]] @()
            if($FullStepCount -gt 0)
            {
                $FullParams = @{
                RequiresPause=$true; 
                RequiresSolution=$true; 
                RequiresExecuteSolution=$true; 
                RequiresCodeExecution=$true; 
                RequiresSetVariable=$true; 
                SolutionExpression="soln_exp";
                CodeToExecute="1+1";
                VariableToSet="x";
                }

                $FullStepBlocks    = (1..$FullStepCount) | 
                                ForEach-Object {New-ImportLessonStep -Prompt "step #$_" @FullParams}
            }
        
            $DefaultStepBlocks = (($FullStepCount + 1)..$StepCount) | 
                                    ForEach-Object {New-ImportLessonStep -Prompt "step #$_"}
            $StepBlocks = $FullStepBlocks + $DefaultStepBlocks
        }
    }
    
    $TitleBlock = New-ImportLessonBlock -Name "Name" -Contents $Title 
    $SectionBlock = New-ImportLessonBlock -Name "Section" -Contents ($TitleBlock + $StepBlocks)

    Write-Output $SectionBlock

}

Set-Alias -Name nilse -Value New-ImportLessonSection 

function New-ImportLessonStep
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $Prompt = "step_prompt"
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch] $RequiresPause 
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch] $RequiresSolution 
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $SolutionExpression = $null 
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch] $RequiresExecuteSolution 
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch] $RequiresCodeExecution
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $CodeToExecute = $null 
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch] $RequiresSetVariable = $false
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $VariableToSet = $null 
    )

    Process 
    {
        Write-Verbose "Validating parameters"
        if($RequiresSolution)
        {
            if($SolutionExpression -eq $null -or $SolutionExpression -eq "")
            {
                throw "When solution is required, SolutionExpression must be not null or empty"
            }
        }

        if($RequiresCodeExecution)
        {
            if($CodeToExecute -eq $null -or $CodeToExecute -eq "")
            {
                throw "When code must be executed, CodeToExecute must be not null"
            }
        }

        if($RequiresSetVariable)
        {
            if($VariableToSet -eq $null) 
            {
                throw "When variable must be set, VariableToSet must be not null"
            }
        }

        Write-Verbose "Constructing prompt block" 
        $PromptBlock = New-ImportLessonBlock -Name "Prompt" -Contents $Prompt

        Write-Verbose "Constructing pause lesson block" 
        $RequiresPauseBlock = New-ImportLessonBlock -Name "RequiresPauseLesson" -Contents ([int] $RequiresPause.IsPresent)

        Write-Verbose "Constructing code to execute block" 
        $RequiresCodeExecutionBlock = New-ImportLessonBlock -Name "RequiresCodeExecution" -Contents ([int] $RequiresCodeExecution.IsPresent)
        $CodeExecutionBlocks = [String[]] @()
        if($RequiresCodeExecution)
        {
            $CodeToExecuteBlock = New-ImportLessonBlock -Name "CodeToExecute" -Contents $CodeToExecute       
            $RequiresSetVariableBlock = New-ImportLessonBlock -Name "RequiresSetVariable" -Contents ([int] $RequiresSetVariable.IsPresent)
       
            $VariableToSetBlock = [String[]]@()
            if($RequiresSetVariable)
            {
                $VariableToSetBlock = New-ImportLessonBlock -Name "Variable" -Contents $VariableToSet
            }

            $CodeExecutionBlocks = $CodeToExecuteBlock + $RequiresSetVariableBlock + $VariableToSetBlock
        }

        Write-Verbose "Constructing solution block"
        $RequiresSolutionBlock = New-ImportLessonBlock -Name "RequiresSolution" -Contents ([int] $RequiresSolution.IsPresent)
        $SolutionBlock = [String[]] @()
        if($RequiresSolution)
        {
            $SolutionExpressionBlock = New-ImportLessonBlock -Name "Expression" -Contents $SolutionExpression
            $RequiresExecuteBlock = New-ImportLessonBlock -Name "RequiresExecution" -Contents ([int] $RequiresExecuteSolution.IsPresent)
            $SolutionBlock = New-ImportLessonBlock -Name "Solution" -Contents ($SolutionExpressionBlock + $RequiresExecuteBlock)
        }

        Write-Verbose "Constructing final step block"
        $StepBlock = New-ImportLessonBlock -Name "Step" -Contents (
                     $PromptBlock +
                     $RequiresPauseBlock + 
                     $RequiresCodeExecutionBlock +
                     $CodeExecutionBlocks + 
                     $RequiresSolutionBlock +
                     $SolutionBlock
                     )

        Write-Verbose "Outputting StepBlock"
        Write-Output $StepBlock 
    }
    
}

Set-Alias -Name nilst -Value New-ImportLessonStep 

function New-ImportLessonBlock 
{
    param
    (
        [String] $Name
    ,
        [String[]] $Contents = ""
    )

    if($Name -eq $null -or $Name -eq "")
    {
        throw "Name must be not null and not empty"
    }

    $OpenBlock = "<$Name>"
    $Contents = $Contents | ForEach-Object {"`t" + $_.Trim(' ')}
    $CloseBlock = "</$Name>"

    $Block = @($OpenBlock) + $Contents + @($CloseBlock)
    #$BlockString = $Block -Join "`n"
    Write-Output $Block 

}

Set-Alias -Name nilb -Value New-ImportLessonBlock 

function Get-XMLElement
{
    param
    (
        $xml
    ,   $element 
    )

   
    $selection = Invoke-Expression "`$xml.$element"
    if($selection -eq $null)
    {
        throw "'$element' not found"
    }
         
    Write-Output $selection 
   
}

function Test-HasExactlyOneElement
{
    param
    (
        $xml
    ,   $element 
    )
    
    $foundCount =  Get-XMLElement -xml $xml -element $element | 
                   Measure-Object | 
                   Select-Object -ExpandProperty Count 

    if($foundCount -gt 1)
    {
        throw "The XML object has $foundCount occurrences of $element, but it can only have 1"
    } 
}

function Test-HasOneOrMoreElement
{
    param
    (
        $xml
    ,   $element 
    )
    
    Get-XMLElement -xml $xml -element $element
}

function Test-HasOnlyElementsInList
{
    param
    (
        $xml 
    ,   [string[]] $elementList
    )

    $elements = $xml |
                Get-Member -MemberType Properties | 
                Select-Object -ExpandProperty Name 

    $elementsNotAllowed = $elements | 
                          Where-Object {$_ -notin $elementList}

    if($elementsNotAllowed)
    {
        throw "The following elements were not in allowed list: $($elementsNotAllowed -join ",")"
    }
}

function ConvertFrom-LessonMarkup
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName="LessonString", ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]
        $LessonString
    )

    Write-Verbose "Converting LessonString to pre-processed XML"
    $LessonXML = [xml] $LessonString
    
    Write-Verbose "Getting lesson object"
    $Lesson = Get-XMLElement $LessonXML "Lesson"

    Write-Verbose "Getting header of lesson"
    $Header = Get-XMLElement $Lesson "H"

    Write-Verbose "Getting body of lesson"
    $Body = Get-XMLElement $Lesson "B"

    Write-Verbose "Getting course name of header"
    $CourseName = Get-XMLElement $Header "C"

    Write-Verbose "Getting lesson of header"
    $LessonName = Get-XMLElement $Header "L"

    Write-Verbose "Getting sections of body" 
    $Sections = Get-XMLElement $Body "S"

    Write-Verbose "Mapping a unique identity to each section name" 
    $SectionIDToName =  @{}
    for($i = 0; $i -lt $Sections.Length; $i++) 
    {
        $SectionIDToName[$i] = (Get-XMLElement $Sections[$i] "N")
    }

    Write-Verbose "Mapping section id to step list"
    $SectionIDToSteps =  @{}
    $SectionIDToName.Keys | 
        ForEach-Object {$SectionIDToSteps[$_] = (Get-XMLElement $Sections[$_] "T")}

    Write-Verbose "Extracting step detail and assigning step numbers"
    $SectionIDToStepDetail =  @{}
    $SectionIDToName.Keys |
    ForEach-Object {
        $Steps = $SectionIDToSteps[$_]; 
        $SectionStepDetails = @();
        for($i = 0; $i -lt $Steps.Length; $i++)
        {
            $StepID = $i 
            $Step = $Steps[$i] 
            $Prompt = Get-XMLElement $Step "P"
            $RequiresExecution = $false 
            $RequiresPause = $false 
            $RequiresSolution = $false 
            $RequiresSetVariable = $false 
            $CodeToExecute = $null 
            $Variable = $null 
            $SolutionExpression = $null 
            $SolutionRequiresExecution = $false
            if("opt" -in ($Step | Get-Member -MemberType Property | Select-Object -ExpandProperty Name))
            {
                $opt = Get-XMLElement $Step "opt"
                if($opt.contains("e"))
                {
                    $RequiresExecution = $true 
                    $CodeToExecute = Get-XMLElement $Step "code"
                }   
                if($opt.contains("v"))
                {
                    $RequiresSetVariable = $true
                    $VariableName = Get-XMLElement $Step "var"
                }
                if($opt.contains("s"))
                {
                    $RequiresSolution = $true 
                    $Solution = Get-XMLElement $Step "soln"
                    $SolutionExpression = Get-XMLElement $Solution "expr"
                    $SolutionRequiresExecution = [bool] [int] (Get-XMLElement $Solution "exec")
                }
                if($opt.contains("p"))
                {
                    $RequiresPause = $true 
                }
            }
            $stepDetails = @{
                StepID = $StepID;
                Prompt = $Prompt;
                RequiresSetVariable = $RequiresSetVariable;
                VariableToSet = $Variable;
                RequiresCodeExecution = $RequiresExecution;
                CodeToExecute = $CodeToExecute;
                RequiresPause = $RequiresPause;
                RequiresSolution = $RequiresSolution;
                SolutionExpression = $SolutionExpression;
                RequiresSolutionExecution = $SolutionRequiresExecution;
            }
            $SectionStepDetails += New-Object -TypeName PSObject -Property $stepDetails
        };
        $SectionIDToStepDetail[$_] = $SectionStepDetails
    }
        
    Write-Verbose "Generating XML for each section"
    $SectionIDToXML =  @{}
    foreach($SectionID in $SectionIDToName.Keys)
    {
        $SectionName = $SectionIDToName[$SectionID] 
        $SectionStepDetails = $SectionIDToStepDetail[$SectionID] 
        $StepsXML = $SectionStepDetails | 
                    New-ImportLessonStep
        $SectionXML = New-ImportLessonSection -Title $SectionName -StepBlocks $StepsXML 
        $SectionIDToXML[$SectionID] = $SectionXML 
    }
    
    Write-Verbose "Generating XML for entire body of lesson"
    $SectionBlocks = [string[]]@()
    for($sectionIdx = 0; $sectionIdx -lt $Sections.Length; $sectionIdx++)
    {
        $SectionBlocks += $SectionIDToXML[$sectionIdx]
    }
    $BodyXML = New-ImportLessonBody -SectionBlocks $SectionBlocks 

    Write-Verbose "Generating XML for entire lesson"
    $LessonXML = New-ImportLesson -CourseName $CourseName -LessonName $LessonName -BodyBlock $BodyXML 
    
    Write-Output $LessonXML
}

<#
[Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $Prompt = "step_prompt"
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch] $RequiresPause 
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch] $RequiresSolution 
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $SolutionExpression = $null 
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch] $RequiresExecuteSolution 
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch] $RequiresCodeExecution
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $CodeToExecute = $null 
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch] $RequiresSetVariable = $false
        ,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String] $VariableToSet = $null 
#>