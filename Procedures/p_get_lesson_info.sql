IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_get_lesson_info') 
	DROP PROCEDURE dbo.p_get_lesson_info;
GO

CREATE PROCEDURE dbo.p_get_lesson_info
(
	  @ai_debug_level INT = 0
	, @ai_course_sid SID
	, @ai_lesson_sid SID
)
AS
/*******************************************************************************
Procedure
p_get_lesson_info

Description 
Get info for a given course and lesson
--------------------------------Interface-----------------------------------------
Input Parameter(s)
None

Output Parameter(s)
None

Result Set(s)
Lesson info having one row with the following attributes
course_id : id of course
lesson_id : id of lesson
num_steps : number of steps in the lesson
--------------------------------History-----------------------------------------
Date : 2017-01-14 12:48:21
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	SELECT   c_hdr.course_id
		   , l_hdr.lesson_id
		   ,
		   (  
				SELECT COUNT(*) 
				FROM dbo.lesson_dtl AS l_dtl
				WHERE l_dtl.course_sid = l_hdr.course_sid
					AND
					l_dtl.lesson_sid = l_hdr.lesson_sid
		   ) AS step_count
	FROM 
		 dbo.lesson_hdr AS l_hdr
		 INNER JOIN 
		 dbo.course_hdr AS c_hdr
			ON l_hdr.course_sid = c_hdr.course_sid
	WHERE 
		  l_hdr.course_sid = @ai_course_sid
		  AND
		  l_hdr.lesson_sid = @ai_lesson_sid
	;
END
GO