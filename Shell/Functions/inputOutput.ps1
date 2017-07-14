function Read-MultipleChoiceInput
{
    [CmdletBinding()]
    param
    (
        [string] $Prompt 
    ,
        [string[]] $PossibleAnswers
    )
    do
    {
        $MCInput = [string] (Read-Host $Prompt)
    }
    while($MCInput -notin $PossibleAnswers)
    
    Write-Output $MCInput
}

function Write-Prompt 
{
    [CmdletBinding()]
    param
    (
        [String] $Prompt
    )

    Write-Information ("`n" + $Prompt)
}