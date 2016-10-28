SELECT * FROM course_hdr; 

DELETE FROM dbo.course_hdr
WHERE course_sid = 5;

DELETE FROM dbo.course_dtl
WHERE course_sid = 5;

DELETE FROM dbo.lesson_hdr
WHERE course_sid = 5;

DELETE FROM dbo.lesson_dtl 
WHERE course_sid = 5;

SELECT * FROM course_hdr;
SELECT execute_code_flag, store_var_flag, solution FROM lesson_dtl; 