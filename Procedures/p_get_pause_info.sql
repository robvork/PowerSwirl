IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_get_pause_info') 
	DROP PROCEDURE dbo.p_get_pause_info;
GO

CREATE PROCEDURE dbo.p_get_pause_info
(
	  @ai_debug_level INT = 0
	, @ai_user_sid SID
)
AS
/*******************************************************************************
Procedure
p_get_pause_info

Description 
Get the lesson information necessary to resume a lesson
--------------------------------Interface-----------------------------------------
Input Parameter(s)
@ai_user_sid : the user sid of the user resuming the lesson

Output Parameter(s)
None

Result Set(s)
The user's pause info containing the following attributes
course_sid : course sid of paused lesson
lesson_sid : lesson sid of paused lesson
step_num : current step in paused lesson
--------------------------------History-----------------------------------------
Date : 2017-01-14 13:09:13
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	
	SELECT course_sid
		 , lesson_sid
		 , step_num 
	FROM dbo.user_pause_state
	WHERE 
		  [user_sid] = @ai_user_sid
	;

END
GO
