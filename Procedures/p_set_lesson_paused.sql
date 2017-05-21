IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_set_lesson_paused') 
	DROP PROCEDURE dbo.p_set_lesson_paused;
GO

CREATE PROCEDURE dbo.p_set_lesson_paused
(
	  @ai_debug_level INT = 0
	, @ai_course_sid SID
	, @ai_lesson_sid SID
	, @ai_user_sid SID
	, @ai_step_num SID
)
AS
/*******************************************************************************
Procedure
p_set_lesson_paused

Description 
Create temporary pause data for a user pausing a given lesson. A user
can have at most 1 paused lesson at any given time, though he or she 
may have several in progress courses. 

This procedure is the primary means for enabling the user to explore using code 
execution outside of the context of a lesson.
--------------------------------Interface-----------------------------------------
Input Parameter(s)
@ai_lesson_sid : sid of lesson to pause
@ai_course_sid : sid of course containing lesson with sid @ai_lesson_sid
@ai_user_sid : sid of user whose lesson is being paused
@ai_step_num : step number of paused lesson

Output Parameter(s)
None

Result Set(s)
None
--------------------------------History-----------------------------------------
Date : 2017-01-14 13:02:07
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	DELETE FROM ups 
	FROM dbo.user_pause_state AS ups
	WHERE 
		ups.[user_sid] = @ai_user_sid
	;

	INSERT INTO dbo.user_pause_state
		(
			 [user_sid]
			,[course_sid]
			,[lesson_sid]
			,[step_num]
		)
	VALUES 
		(
			 @ai_user_sid
			,@ai_course_sid
			,@ai_lesson_sid
			,@ai_step_num
		)
	;

	UPDATE uc 
	SET	  step_num = @ai_step_num
		, lesson_in_progress_flag = 1
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