function New-PSwirlDrive 
{
    param
    (
        [switch] $PassThru
    )
    $RootDirectory = New-RandomTempDirectory
    $DriveName = Get-PSwirlDriveName

    if(-not (Test-Path "${DriveName}:\"))
    {
        New-PSDrive -Name $DriveName -Root $RootDirectory -PSProvider FileSystem -Scope Global -Description "PowerSwirl disposable drive" | Out-Null 
    }

    if(-not (Test-Path "Variable:Global:$DriveName"))
    {
        New-Variable -Name $DriveName -Scope Global -Value $RootDirectory
    }

    if($PassThru)
    {
        Get-PSDrive $DriveName 
    }
}

function New-RandomTempDirectory
{
    do 
    {
        $tempPath = $env:TEMP 
        $Path = Join-Path $tempPath ([Guid]::NewGuid())
    } until (-not (Test-Path $Path))

    New-Item -ItemType Container -Path $Path 
}

function Clear-PSwirlDrive
{
    param 
    (
        [String[]] $Exclude 
    )
    $PSwirlDriveName = Get-PSwirlDriveName
    $Path = (Get-PSDrive -name $PSwirlDriveName).Root 
    if(Test-Path $Path)
    {
        Get-ChildItem -Recurse -Path $Path | 
        Sort-Object -Descending -Property -FullName | 
        Where-Object { $Exclude -NotContains $_.FullName} | 
        Remove-Item -Force -Recurse 
    }
}

function Remove-PSwirlDrive
{
    $PSwirlDriveName = Get-PSwirlDriveName
    $Drive = Get-PSDrive -Name $PSwirlDriveName -ErrorAction SilentlyContinue
    $Path = $Drive.Root 

    if($Drive)
    {
        $Drive | Remove-PSDrive -Force -ErrorAction SilentlyContinue
    }

    if($Path -and (Test-Path $Path))
    {
        Remove-Item -Path $Path -Force -Recurse
    }

    if(Get-Variable $PSwirlDriveName -Scope Global -ErrorAction SilentlyContinue)
    {
        Remove-Variable $PSwirlDriveName -Scope Global -Force 
    }

}

function Get-PSwirlDriveName 
{
    Write-Output "PSwirlDrive"
}