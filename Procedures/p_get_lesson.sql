IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_get_lesson') 
	DROP PROCEDURE dbo.p_get_lesson;
GO

CREATE PROCEDURE dbo.p_get_lesson
(
	@ai_course_sid SID
,	@as_lesson_id ID 
,	@ai_debug_level INT = 0
)
AS
/*******************************************************************************
Procedure
p_get_lesson

Description 
Get all courses available

--------------------------------Interface-----------------------------------------
Input Parameter(s)
None

Output Parameter(s)
None

Result Set(s)
--------------------------------History-----------------------------------------
Date : 2017-01-14 12:28:33
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	DECLARE @li_lesson_sid SID;
	DECLARE @lb_lesson_exists BIT;

	SET @li_lesson_sid = 
	(
		SELECT lesson_sid
		FROM dbo.lesson_hdr
		WHERE 
			lesson_id = @as_lesson_id
			AND
			course_sid = @ai_course_sid
	);

	IF @li_lesson_sid IS NULL
		SET @lb_lesson_exists = 0;
	ELSE
		SET @lb_lesson_exists = 1;

	SELECT @li_lesson_sid AS lessonSid, @lb_lesson_exists AS lessonExists;
END
GO