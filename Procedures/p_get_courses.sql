IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_get_courses') 
	DROP PROCEDURE dbo.p_get_courses;
GO

CREATE PROCEDURE dbo.p_get_courses
(
	@ai_debug_level INT = 0
)
AS
/*******************************************************************************
Procedure
p_get_courses

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
	SELECT ROW_NUMBER() OVER (ORDER BY course_id) AS selection
		 , course_id
		 , course_sid 
	FROM dbo.course_hdr
	ORDER BY course_id
	;

END
GO