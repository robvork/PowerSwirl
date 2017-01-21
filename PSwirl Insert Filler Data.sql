--CREATE TABLE dbo.next_sid

--INSERT INTO dbo.Nums
--SELECT n FROM TSQL2012.dbo.Nums;  


--INSERT INTO dbo.course_hdr(course_sid, course_id)
--SELECT nums.n, 'Course ' + CONVERT(VARCHAR(5), nums.n) 
--FROM dbo.Nums AS nums
--WHERE nums.n <= 4;

--INSERT INTO dbo.course_dtl
--	   (course_sid, 
--	    lesson_sid)
--VALUES (1, 1), 
--	   (2, 1), 
--	   (3, 1),
--	   (4, 1),
--	   (4, 2);



--INSERT INTO dbo.lesson_dtl
--		(
--			course_sid,  lesson_sid, step_num, step_prompt, 
--			requires_input_flag, execute_code_flag, store_var_flag, 
--			solution, variable
--		)
--SELECT C.course_sid, 
--	   C.lesson_sid, 
--	   nums.n,
--		'C' + CONVERT(VARCHAR(5), C.course_sid)
--		+ ' L' + CONVERT(VARCHAR(5), C.lesson_sid) 
--		+ ' S' + CONVERT(VARCHAR(5), nums.n) ,
--		0,
--		0,
--		0,
--		NULL,
--		NULL
--FROM dbo.course_dtl AS C
--	CROSS APPLY 
--		(
--			SELECT n 
--			FROM dbo.Nums
--			WHERE n <= ABS(CHECKSUM(NEWID())) % 15 + 5
--		) AS nums

--INSERT INTO dbo.lesson_hdr(course_sid, lesson_sid, lesson_id)
--SELECT course_sid, ROW_NUMBER() OVER (PARTITION BY course_sid ORDER BY course_sid),
--		 'Course ' + CONVERT(VARCHAR(5), course_sid) +
--		 ' Lesson ' + CONVERT(VARCHAR(5), ROW_NUMBER() OVER (PARTITION BY course_sid ORDER BY course_sid))
--FROM dbo.course_dtl;


--SELECT * FROM dbo.course_hdr;
--SELECT * FROM dbo.course_dtl;
--SELECT * FROM dbo.lesson_hdr;
--SELECT * FROM dbo.lesson_dtl;


----ALTER TABLE dbo.course
----ADD CONSTRAINT fk_course_to_lesson
----FOREIGN KEY   (course_sid, lesson_sid, step_num) 
----	REFERENCES
----	dbo.lesson(course_sid, lesson_sid, step_num)

----SELECT * FROM dbo.lesson_dtl
----WHERE course_sid = 4 AND lesson_sid = 2;

----SELECT ABS(CHECKSUM(NEWID())) % 15 + 5

--BEGIN TRAN
--DELETE FROM dbo.user_hdr;
--SELECT * FROM dbo.user_hdr;
--SELECT * FROM dbo.user_course
--ROLLBACK TRAN

--INSERT INTO dbo.user_hdr(user_id) 
--VALUES ('Rob'), ('Jim')

--DELETE FROM user_pause_state

--SELECT * FROM dbo.user_hdr

--SELECT * FROM dbo.user_course
--SELECT * FROM dbo.lesson_dtl

--SET FMTONLY ON;
--SELECT * FROM dbo.lesson_dtl
--SET FMTONLY OFF;

--SELECT * FROM dbo.user_pause_state