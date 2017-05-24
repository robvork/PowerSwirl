IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_get_course') 
	DROP PROCEDURE dbo.p_get_course;
GO

CREATE PROCEDURE dbo.p_get_course
(
	@as_course_id ID 
,	@ai_debug_level INT = 0
)
AS
/*******************************************************************************
Procedure
p_get_course

Description 
Get all courses available

--------------------------------Interface-----------------------------------------
Input Parameter(s)
None

Output Parameter(s)
None

Result Set(s)
Course list with following attributes
choice : a unique positive integer identifying each course
course_sid : the sid of the row's course
course_id : the id of the row's course
--------------------------------History-----------------------------------------
Date : 2017-01-14 12:28:33
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	DECLARE @li_course_sid SID;
	DECLARE @lb_course_exists BIT;

	SET @li_course_sid = 
	(
		SELECT course_sid
		FROM dbo.course_hdr
		WHERE course_id = @as_course_id
	);

	IF @li_course_sid IS NULL
		SET @lb_course_exists = 0;
	ELSE
		SET @lb_course_exists = 1;

	SELECT @li_course_sid, @lb_course_exists;
END
GO