IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_set_lesson_in_progress') 
	DROP PROCEDURE dbo.p_set_lesson_in_progress;
GO

CREATE PROCEDURE dbo.p_set_lesson_in_progress
(
	  @ai_debug_level INT = 0
	, @ai_course_sid SID
	, @ai_lesson_sid SID
	, @ai_user_sid SID
	, @ai_step_num STEP = 1
)
AS
/*******************************************************************************
Procedure
p_set_lesson_in_progress

Description 
Set a given course and lesson to in progress for a specified user. Record
the step the user is currently on for later retrieval. 
--------------------------------Interface-----------------------------------------
Input Parameter(s) 
@ai_lesson_sid : sid of lesson to set in progress
@ai_course_sid : sid of course containing lesson with sid @ai_lesson_sid
@ai_user_sid : sid of user whose progress is being saved
@ai_step_num : the current step @ai_user_sid is on within @ai_course_sid, @ai_lesson_sid

Output Parameter(s)
None

Result Set(s)
None
--------------------------------History-----------------------------------------
Date : 2017-01-14 12:51:24
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	
	UPDATE uc 
	SET   lesson_in_progress_flag = 1
		, step_num = @ai_step_num
	FROM dbo.user_course AS uc
	WHERE 
		  uc.course_sid = @ai_course_sid
		  AND 
		  uc.lesson_sid = @ai_lesson_sid
		  AND 
		  uc.[user_sid] = @ai_user_sid
	;

END
GO