IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_create_new_course') 
	DROP PROCEDURE dbo.p_create_new_course;
GO

CREATE PROCEDURE dbo.p_create_new_course
(
	  @ai_debug_level INT = 0
	, @as_course_id ID
)
AS
/*******************************************************************************
Procedure
p_create_new_course

Description 
Briefly describe procedure

--------------------------------Interface-----------------------------------------
Input Parameter(s)
 @as_lesson_id : id of lesson to add
 @as_course_id : course id associated with @as_lesson_id
 @ab_overwrite_existing_lesson : bit indicating whether to overwrite the existing lesson
	in the event that there is a prexisting lesson with lesson id @as_lesson_id 
	within course @as_course_id
	1 => Overwrite existing lesson
	0 => Do not overwrite lesson. Throw error if lesson already exists
 @ab_create_new_course : bit indicating whether to create a new course in the event that 
	there is no course with id @as_course_id. 
	1 => Create new course if course does not exist
	0 => Do not create new course. Throw error if course does not exist. 

Output Parameter(s)
None

Result Set(s)
None
--------------------------------History-----------------------------------------
Date : 2017-01-14 14:18:07
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	DECLARE @ls_error_message AS NVARCHAR(MAX);
	DECLARE @lb_course_exists AS BIT;
	DECLARE @li_course_sid AS SID;

	SET @lb_course_exists = 
	(
		CASE 
			WHEN EXISTS 
			(
				SELECT * 
				FROM dbo.course_hdr 
				WHERE course_id = @as_course_id
			) 
				THEN 
						1
			ELSE 
						0
		END
	);

	IF @lb_course_exists = 1
	BEGIN
		SET @ls_error_message = CONCAT('Course ''', @as_course_id, ''' already exists.');
		RAISERROR(@ls_error_message, 16, 1);
	END; 
		
	SET @li_course_sid = 
	(
		SELECT MAX(course_sid) + 1 
		FROM dbo.course_hdr 
	)

	INSERT INTO dbo.course_hdr
	(
		course_sid
	,	course_id 
	)
	VALUES 
	(
		@li_course_sid
	,	@as_course_id
	)
	;

	SELECT @li_course_sid AS course_sid;

END
GO
