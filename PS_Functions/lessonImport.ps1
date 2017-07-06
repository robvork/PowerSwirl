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
    param
    (
        [String] $CourseID
    ,
        [String] $LessonID
    ,
        [Int] $SectionCount = 1
    ,
        [Int[]] $StepCount = @(2)
    ,
        [Int[]] $FullStepCount = @(1)
    )
    
    $HeaderBlock = New-ImportLessonHeader -CourseID $CourseID -LessonID $LessonID
    $BodyBlock = New-ImportLessonBody -SectionCount $SectionCount -StepCount $StepCount -FullStepCount $FullStepCount

    $LessonBlock = New-ImportLessonBlock -Name "Lesson" -Contents ($HeaderBlock + $BodyBlock)

    Write-Output $LessonBlock
}

Set-Alias -Name nil -Value New-ImportLesson 

function New-ImportLessonHeader
{
    param
    (
        [String] $CourseID
    ,
        [String] $LessonID        
    )

    if($CourseID -eq $null -or $CourseID -eq "")
    {
        throw "CourseID must be not null and not empty"
    }
    if($LessonID -eq $null -or $LessonID -eq "")
    {
        throw "LessonID must be nto null and not empty"
    }

    $CourseBlock = New-ImportLessonBlock -Name "Course" -Contents $CourseID
    $LessonBlock = New-ImportLessonBlock -Name "Lesson" -Contents $LessonID

    $HeaderBlock = New-ImportLessonBlock -Name "Header" -Contents ($CourseBlock + $LessonBlock)

    Write-Output $HeaderBlock
}

Set-Alias -Name nilh -Value New-ImportLessonHeader

function New-ImportLessonBody 
{
    [CmdletBinding()]
    param
    (
        [Int] $SectionCount = 1
    ,
        [Int[]] $StepCount = @(2)
    ,
        [Int[]] $FullStepCount = @(1)
    )

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
    $BodyBlock = New-ImportLessonBlock -Name "Body" -Contents $SectionBlocks 

    Write-Output $BodyBlock 
    
}

Set-Alias -Name nilb -Value New-ImportLessonBody 

function New-ImportLessonSection
{
    param
    (
        [String] $Title
    ,
        [Int] $StepCount = 1
    ,
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
    
    $SectionBlock = New-ImportLessonBlock -Name "Section" -Contents $StepBlocks

    Write-Output $SectionBlock

}

Set-Alias -Name nilse -Value New-ImportLessonSection 

function New-ImportLessonStep
{
    [CmdletBinding()]
    param
    (
        [String] $Prompt = "step_prompt"
        ,
        [Switch] $RequiresPause 
        ,

        [Switch] $RequiresSolution 
        ,
        [String] $SolutionExpression = $null 
        ,
        [Switch] $RequiresExecuteSolution 
        
        ,
        [Switch] $RequiresCodeExecution
        ,
        [String] $CodeToExecute = $null 
        
        ,
        [Switch] $RequiresSetVariable = $false
        , 
        [String] $VariableToSet = $null 
    )

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

   
    $selection = Invoke-Expression "`$xml.`$element"
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


function ConvertTo-LessonXML
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName="LessonString", ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]
        $LessonString
    )

    Write-Verbose "Converting LessonString to pre-processed XML"
    $LessonString = [xml] $LessonString
    
    Write-Verbose "Checking that the top level object of LessonString is 'lesson'"
    if("lesson" -notin ($LessonString | 
                        Get-Member | 
                        Select-Object -ExpandProperty Name
                       )
      )
    {
        throw "The top level of the lesson to be imported must be an object 'lesson'."
    }

    Write-Verbose "Checking that the lesson object has an element 'H' for the header section"
    if("H" -notin ($LessonString.Lesson |
                   Get-Member | 
                   Select-Object -ExpandProperty Name
                  )
      )
    {
        throw "The lesson object must contain an element 'H' for the header."
    }

    Write-Verbose "Checking that the lesson object has an element 'B' for the body section"
    if("B" -notin ($LessonString.Lesson |
                   Get-Member | 
                   Select-Object -ExpandProperty Name
                  )
      )
    {
        throw "The lesson object must contain an element 'B' for the body."
    }

    Write-Verbose "Checking that the header section contains a 'C' section for course"
    if("C" -notin ($LessonString.Lesson.H |
                   Get-Member | 
                   Select-Object -ExpandProperty Name 
                  ) 
      )
    {
        throw "The lesson.H object must have a 'C' element for course name"
    }

    Write-Verbose "Checking that the header section contains a 'L' section for course"
    if("L" -notin ($LessonString.Lesson.H |
                   Get-Member | 
                   Select-Object -ExpandProperty Name 
                  ) 
      )
    {
        throw "The lesson.H object must have a 'L' element for course name"
    }

   
}