class MenuSelection
{
    [int] $Selection 

    MenuSelection([int]$Selection)
    {
        $this.Selection = $Selection 
    }

    MenuSelection([MenuSelection] $menuSelection, [bool] $isCopy)
    {
    	$this.Selection = $menuSelection.Selection
    }

    [bool] Equals ([Object]$other)
    {
        return ($other -is [MenuSelection]) -and ($other.Selection -eq $this.Selection)
    }
}

function New-MenuSelection
{
	param
	(
		[Int] $Selection
	)

	Write-Output ([MenuSelection]::new($Selection))
}