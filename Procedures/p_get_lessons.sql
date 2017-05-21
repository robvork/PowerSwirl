IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_get_lessons') 
	DROP PROCEDURE dbo.p_get_lessons;
GO

CREATE PROCEDURE dbo.p_get_lessons
(
	  @ai_debug_level INT = 0
	, @ai_course_sid SID = NULL
	, @as_course_id ID = NULL
)
AS
/*******************************************************************************
Procedure
p_get_lessons

Description 
Get lessons available for a given course

--------------------------------Interface-----------------------------------------
Input Parameter(s)
@ai_course_sid : sid of course selection

Output Parameter(s)
None

Result Set(s)
Lesson list with following attributes
choice : a unique positive integer identifying each lesson
lesson_sid : the sid of the row's lesson
lesson_id : the id of the row's lesson
--------------------------------History-----------------------------------------
Date : 2017-01-14 12:32:27
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	IF @ai_course_sid IS NULL
		SET @ai_course_sid = 
		(
			SELECT course_sid 
			FROM dbo.course_hdr 
			WHERE course_id = @as_course_id
		);

	SELECT ROW_NUMBER() OVER (PARTITION BY c_dtl.course_sid ORDER BY l_hdr.lesson_id) AS choice
		   , c_dtl.lesson_sid
		   , l_hdr.lesson_id
	FROM dbo.course_dtl AS c_dtl
		 INNER JOIN dbo.lesson_hdr AS l_hdr
			ON c_dtl.course_sid = l_hdr.course_sid
			   AND
			   c_dtl.lesson_sid = l_hdr.lesson_sid
	WHERE c_dtl.course_sid = @ai_course_sid
	;

END
GO