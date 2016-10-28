IF OBJECT_ID('dbo.c_list', 'V') IS NOT NULL
	DROP VIEW dbo.c_list;

GO

CREATE VIEW dbo.c_list
AS
(
	SELECT course_id AS course_name
	FROM dbo.course_hdr
);
GO

IF OBJECT_ID('dbo.cl_list', 'V') IS NOT NULL
	DROP VIEW dbo.cl_list;
GO

CREATE VIEW dbo.cl_list
AS
(
	SELECT course_id AS course_name, lesson_id AS lesson_name
	FROM dbo.course_hdr AS CH
		INNER JOIN dbo.lesson_hdr AS LH
			ON CH.course_sid = LH.course_sid
)
