function Read-SQLServerInstance
{
    <#
        .SYNOPSIS
        Get SQL Server instance from user
    #>

    [CmdletBinding()]
    param
    (
    )

    $ServerInstance = Read-Host -Prompt "SQL Server instance name"
    if($ServerInstance -eq "")
    {
        throw "Empty ServerInstance passed"
    }
    else
    {
        Write-Output $ServerInstance
    }
}

function Read-SQLServerDatabase
{
    <#
        .SYNOPSIS
        Get SQL Server database from user
    #>

    $Database = Read-Host -Prompt "Database name"
    if($Database -eq "")
    {
        throw "Empty Database passed"
    }
    else
    {
        Write-Output $Database
    } 
}

function Read-PSwirlUser
{
    <#
        .SYNOPSIS
        Read user and password from user
    #>
    $User = Read-Host -Prompt "PowerSwirl User"
    if($User -eq "")
    {
        throw "Empty User passed"
    }
    else
    {
        Write-Output $User
    } 
}


function Test-PSwirlUser
{
    param
    (
        [String]
        $ServerInstance
    ,
        [String]
        $Database 
    ,
        [String]
        $User  
    )

    $Query = "EXECUTE dbo.p_get_user @as_user_id = '$User'"
    $TestResult = Invoke-Sqlcmd2 -ServerInstance $ServerInstance -Database $Database -Query $Query
    if([bool]$TestResult.user_exists)
    {
        Write-Output $TestResult.user_sid 
    }
    else
    {
        throw "User does not exist"
    }


}

function Initialize-PSwirlStream
{
    $InformationAction = "Continue"
    Write-Output $InformationAction 
}