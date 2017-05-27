class MenuSelection
{
    [int] $Selection 

    MenuSelection($Selection)
    {
        $this.Selection = $Selection 
    }

    [bool] Equals ([Object]$other)
    {
        return ($other -is [MenuSelection]) -and ($other.Selection -eq $this.Selection)
    }
}