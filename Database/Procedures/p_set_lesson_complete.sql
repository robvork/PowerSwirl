IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_set_lesson_complete') 
	DROP PROCEDURE dbo.p_set_lesson_complete;
GO

CREATE PROCEDURE dbo.p_set_lesson_complete
(
	  @ai_debug_level INT = 0
	, @ai_course_sid SID
	, @ai_lesson_sid SID
	, @ai_user_sid SID
)
AS
/*******************************************************************************
Procedure
p_set_lesson_complete

Description 
Set a given course and lesson to complete for a specified user. 
This erases any in-progress data the user has for that lesson.
--------------------------------Interface-----------------------------------------
Input Parameter(s)
@ai_lesson_sid : sid of lesson to set to complete
@ai_course_sid : sid of course containing lesson with sid @ai_lesson_sid
@ai_user_sid : sid of user whose (course, lesson) we are setting to complete

Output Parameter(s)
None

Result Set(s)
None
--------------------------------History-----------------------------------------
Date : 2017-01-14 12:57:35
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	
	UPDATE uc 
	SET   lesson_in_progress_flag = 0
		, lesson_completed_flag = 1
		, step_num = 1
	FROM dbo.user_course AS uc
	WHERE 
		  uc.course_sid = @ai_course_sid
		  AND 
		  uc.lesson_sid = @ai_lesson_sid
		  AND 
		  uc.[user_sid] = @ai_user_sid
	;

	DELETE FROM ups 
	FROM dbo.user_pause_state AS ups
	WHERE	  
		  ups.course_sid = @ai_course_sid
		  AND 
		  ups.lesson_sid = @ai_lesson_sid
		  AND 
		  ups.[user_sid] = @ai_user_sid
	;

END
GO