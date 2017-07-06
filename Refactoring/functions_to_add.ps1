function Get-PSwirlServerInstance 
{
    <#
        .SYNOPSIS 
        Determines the SQL Server instance to use for PowerSwirl

        .DESCRIPTION 
        If the SQL Server instance name is provided, validate it. If it passes validation, 
        return the input as is. If it does not pass validation, prompt for a new instance name.
        Repeat this until the instance name passes validation.

        If the SQL Server instance name is not provided, prompt for an instance name. 
        Validate this instance name. If it is valid, return it. Otherwise, prompt for a new instance name. 
        Repeat this until the instance name passes validation.

        .PARAMETER ServerInstance
        The optional SQL Server instance name. Returned if valid. 
        Otherwise, the command prompts for a new instance name until the given value passes validation. The
        first valid instance name is returned.
    #>
    [CmdletBinding()] 
    param
    (
        [String] $ServerInstance
    )
}

function Get-PSwirlDatabase
{
    <#
        .SYNOPSIS 
        Determines the SQL Server database to use for PowerSwirl
    #>
    [CmdletBinding()] 
    param
    (
        [String] $ServerInstance
    ,
        [String] $Database
    )
}

function Get-PSwirlUser
{
    <#
        .SYNOPSIS 
        Determines the PowerSwirl user to use for progress tracking in PowerSwirl
    #>
    [CmdletBinding()] 
    param
    (
        [String] $ServerInstance
    ,
        [String] $Database
    , 
        [String] $ID
    ,
        [Int] $SID
    )
}

function Get-PSwirlCourse
{
    <#
        .SYNOPSIS 
        Determines the PowerSwirl course to load
    #>
    [CmdletBinding()] 
    param
    (
        [String] $ServerInstance
    ,
        [String] $Database
    ,
        [String] $ID
    ,
        [Int] $SID
    )
}

function Get-PSwirlLesson 
{
    <#
        .SYNOPSIS 
        Determines the PowerSwirl lesson to load
    #>
    [CmdletBinding()] 
    param
    (
        [String] $ServerInstance
    ,
        [String] $Database
    ,
        [String] $CourseID
    ,
        [Int] $CourseSID
    ,
        [String] $ID
    ,
        [Int] $SID
    )
}
