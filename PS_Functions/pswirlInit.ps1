function Read-SQLServerInstance
{
    <#
        .SYNOPSIS
        Get SQL Server instance from user
    #>

    $ServerInstance = Read-Host -Prompt "SQL Server instance name"
    Write-Output $ServerInstance
}

function Read-SQLServerDatabase
{
    <#
        .SYNOPSIS
        Get SQL Server database from user
    #>

    $Database = Read-Host -Prompt "Database name"
    Write-Output $Database 
}

function Read-PSwirlUser
{
    <#
        .SYNOPSIS
        Read user and password from user
    #>
    $User = Read-Host -Prompt "PowerSwirl User"
    Write-Output $User 
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
    #$InformationAction = "Continue"
    $InformationAction = "SilentlyContinue"
    Write-Output $InformationAction 
}