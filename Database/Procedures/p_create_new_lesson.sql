IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_create_new_lesson') 
	DROP PROCEDURE dbo.p_create_new_lesson;
GO

CREATE PROCEDURE dbo.p_create_new_lesson
(
	  @ai_debug_level INT = 0
	, @ai_course_sid ID
	, @as_lesson_id ID
)
AS
/*******************************************************************************
Procedure
p_create_new_lesson

Description 
Create a new lesson in an existing course with a specified name.

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

	-- Check whether course exists
	SET @lb_course_exists = 
	(
	  SELECT 
		CASE 
			 WHEN EXISTS 
			 (
				SELECT * 
				FROM dbo.course_hdr 
				WHERE course_sid = @ai_course_sid
			 )
			 THEN 
					1 
			 ELSE 
					0
		END 
	); 
		
	-- If course does not exist, raise error and halt
	IF @lb_course_exists = 0
	BEGIN
		SET @ls_error_message = CONCAT('A course with SID ', @ai_course_sid, ' does not exist');
		RAISERROR(@ls_error_message, 16, 1);
	END;  
	-- Otherwise, check whether lesson exists
	ELSE 
	BEGIN
		SET @lb_lesson_exists = 
		(
			SELECT 
				CASE 
					WHEN EXISTS 
					(
						SELECT * 
						FROM dbo.lesson_hdr
						WHERE course_sid = @ai_course_sid 
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
			SET @ls_error_message = 
			CONCAT('The course with SID '
				  ,	@ai_course_sid
				  , ' already has a lesson named '''
				  , @as_lesson_id
				  , N''''
				  );

			RAISERROR(@ls_error_message, 16, 1);
		END;
		ELSE 
		BEGIN
			SET @li_lesson_sid = 
			(
				-- Get the maximum lesson sid for the course if it exists
				-- If it doesn't exist, just use 0
				-- Then add 1 to get the new lesson sid
				SELECT ISNULL(MAX(lesson_sid), 0) + 1 
				FROM dbo.lesson_hdr 
				WHERE course_sid = @ai_course_sid
			); 

			INSERT INTO dbo.course_dtl 
			(
				course_sid
			,	lesson_sid 
			)
			VALUES 
			(
				@ai_course_sid
			,	@li_lesson_sid
			)
			;

			INSERT INTO dbo.lesson_hdr
			(
				course_sid
			,	lesson_sid 
			,	lesson_id 
			)
			VALUES 
			(
				@ai_course_sid
			,	@li_lesson_sid
			,	@as_lesson_id
			); 

			SELECT @li_lesson_sid AS lesson_sid;
		END; 


	END; 
	

END
GO
