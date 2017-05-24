IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_get_lesson_content') 
	DROP PROCEDURE dbo.p_get_lesson_content;
GO

CREATE PROCEDURE dbo.p_get_lesson_content
(
	  @ai_debug_level INT = 0
	, @ai_course_sid SID
	, @ai_lesson_sid SID
)
AS
/*******************************************************************************
Procedure
p_get_lesson_content

Description 
Get all the content for a chosen course and lesson

--------------------------------Interface-----------------------------------------
Input Parameter(s)
@ai_course_sid : the sid of the chosen course
@ai_lesson_sid : the sid of the chosen lesson belonging to course @ai_course_sid

Output Parameter(s)
None

Result Set(s)
Lesson content list having the following attributes
step_num : a unique positive integer identifying a lesson step. 
		   the content of a lesson is presented by iterating through step_num 1 through step_num n,
		   where n is the number of steps for the lesson. 
step_prompt : the lesson step's prompt
requires_input : a bit indicating whether the step requires user input
	 1 => requires input
	 0 => no input required
execute_code : a bit indicating whether the step should execute code
	 1 => code execution required
	 0 => no code execution required
store_var : a bit indicating whether the code execution's results should be stored in a variable.
	 1 => execution results should be stored in a variable. if store_var = 1, execute_code = 1
	 0 => if execute_code = 1, code should be executed but not stored. 
		  if execute_code = 0, this is set to 0 by default but is not used
variable : the id of a variable where code execution results should be stored
		   this should be used only when execute_code = 1 and store_var = 1
solution : literal text or code to be executed for comparison to user's input.
		   this should be used only when requires_input = 1
--------------------------------History-----------------------------------------
Date : 2017-01-14 12:36:26
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	
	SELECT 
		   step_num AS step_num
		  ,step_prompt AS step_prompt
		  ,requires_input_flag AS requires_input
		  ,execute_code_flag AS execute_code
		  ,store_var_flag AS store_var 
		  ,variable AS variable
		  ,solution AS solution
	FROM 
		  dbo.lesson_dtl 
	WHERE 
		  course_sid = @ai_course_sid
		  AND 
		  lesson_sid = @ai_lesson_sid
	ORDER BY 
		  step_num
	;

END
GO