DECLARE @li_debug_level INT = 0;
DECLARE @lb_show_snapshot BIT = 1;

EXEC dbo.p_insert_filler_data
	@ai_min_courses = 3
,	@ai_max_courses = 5
,	@ai_min_lessons_per_course = 2
,	@ai_max_lessons_per_course = 4
,	@ai_min_steps_per_lesson = 3 
,	@ai_max_steps_per_lesson = 6
,	@ai_min_users = 3
,	@ai_max_users = 6 
,	@ai_debug_level = @li_debug_level 
,	@af_probability_lesson_in_progress = 0.5
,	@af_probability_lesson_completed = 0.2
;


IF @lb_show_snapshot = 1
BEGIN
	SELECT 'Snapshot of data generated';
	-- Show users, courses, lessons, step counts
	SELECT 'Users'; 
	SELECT user_sid, user_id FROM dbo.user_hdr;
	
	SELECT CH.course_sid 
	,	   CD.lesson_sid  
	,	   CH.course_id AS course_name
	,	   LH.lesson_id AS lesson_name
	,	   LD.step_count 
	FROM dbo.course_hdr AS CH
		INNER JOIN dbo.course_dtl AS CD
			ON CH.course_sid = CD.course_sid
		INNER JOIN dbo.lesson_hdr AS LH
			ON CD.course_sid = LH.course_sid
			   AND 
			   CD.lesson_sid = LH.lesson_sid
		CROSS APPLY
		(
			SELECT COUNT(step_num) 
			FROM dbo.lesson_dtl AS LD
			WHERE LD.course_sid = CD.course_sid
				  AND 
				  LD.lesson_sid = CD.lesson_sid
		) AS LD(step_count)
	;


END; 
--SELECT * FROM dbo.course_dtl
