class LessonStep
{
	[int] $StepNum
	[String] $Prompt
	[bool] $InputIsRequired
	[bool] $CodeMustBeExecuted
	[bool] $VariableMustBeSet
	[String] $VariableName
	[String] $Solution
}