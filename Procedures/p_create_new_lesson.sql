IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_create_new_lesson') 
	DROP PROCEDURE dbo.p_create_new_lesson;
GO

CREATE PROCEDURE dbo.p_create_new_lesson
(
	  @ai_debug_level INT = 0
	, @as_lesson_id ID
	, @as_course_id ID
	, @ab_overwrite_existing_lesson FLAG
	, @ab_create_new_course FLAG
)
AS
/*******************************************************************************
Procedure
p_create_new_lesson

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
	DECLARE @lb_lesson_exists AS BIT;
	DECLARE @lb_course_exists AS BIT;
	DECLARE @li_lesson_sid AS SID;
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

	IF @lb_course_exists = 0 
	BEGIN
		IF @ab_create_new_course = 1
		BEGIN
			SET @li_course_sid = 
			(
				SELECT ISNULL(MAX(course_sid), 0) + 1 
				FROM dbo.course_hdr
			); 
			
			INSERT INTO dbo.course_hdr
						(
						  course_sid
						 ,course_id
						)
						VALUES 
						(
						  @li_course_sid
						 ,@as_course_id
						)
			;
		END;
		ELSE
		BEGIN
			SET @ls_error_message = 'Course with id ''' 
								     + @as_course_id 
									 + ''' does not exist and procedure called with @ab_overwrite_existing_lesson = 0.' + NCHAR(13)
									 + 'Use an existing course or use @ab_overwrite_existing_lesson = 1';
			RAISERROR(@ls_error_message, 16, 1);
		END;
	END;
	ELSE
		SET @li_course_sid = 
		(
			SELECT course_sid 
			FROM dbo.course_hdr 
			WHERE course_id = @as_course_id
		);


	SET @lb_lesson_exists = 
	(
		CASE 
			WHEN EXISTS 
			(
				SELECT * 
				FROM dbo.lesson_hdr 
				WHERE  
					course_sid = @li_course_sid
					AND 
					lesson_id = @as_lesson_id
			) 
				THEN 
						1
			ELSE 
						0
		END
	);

	

	IF @lb_lesson_exists = 1
	BEGIN
		IF @ab_overwrite_existing_lesson = 1
		BEGIN
			SET @li_lesson_sid = 
			(
				SELECT lesson_sid 
				FROM dbo.lesson_hdr 
				WHERE lesson_id = @as_lesson_id
			); 
			
			DELETE FROM dbo.lesson_dtl
			WHERE	course_sid = @li_course_sid 
				AND lesson_sid = @li_lesson_sid
			;
		END
		ELSE
		BEGIN
			SET @ls_error_message = 'Lesson with id ''' 
								     + @as_lesson_id 
									 + ''' already exists within course ''' 
									 + @as_course_id 
									 + ''' and procedure called with @ab_overwrite_existing_lesson = 0. ' + NCHAR(13) 
									 + 'Choose unique lesson name or use @ab_overwrite_existing_lesson = 1'; 
			RAISERROR(@ls_error_message, 16, 1);
		END
	END
	ELSE
	BEGIN
		SET @li_lesson_sid = 
		(
			SELECT ISNULL(MAX(lesson_sid), 0) + 1
			FROM dbo.course_dtl
			WHERE course_sid = @li_course_sid
		);

		INSERT INTO dbo.lesson_hdr(course_sid, lesson_sid, lesson_id)
		VALUES (@li_course_sid, @li_lesson_sid, @as_lesson_id) ;

		INSERT INTO dbo.course_dtl(course_sid, lesson_sid)
		VALUES (@li_course_sid, @li_lesson_sid)

	END

	SELECT @li_course_sid, @li_lesson_sid;

END
GO
