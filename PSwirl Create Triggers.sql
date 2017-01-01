USE PowerSwirl;

IF OBJECT_ID(N'tI_user_hdr', N'TR') IS NOT NULL
	DROP TRIGGER tI_user_hdr;
GO

CREATE TRIGGER dbo.tI_user_hdr 
ON dbo.user_hdr
AFTER
INSERT
AS
BEGIN
	INSERT INTO dbo.user_course(user_sid, course_sid, lesson_sid)
	SELECT I.user_sid, chdr.course_sid, lhdr.lesson_sid 
	FROM INSERTED AS I
		CROSS JOIN dbo.course_hdr AS chdr
		INNER JOIN dbo.lesson_hdr AS lhdr
			ON chdr.course_sid = lhdr.course_sid
END

IF OBJECT_ID(N'tD_user_hdr', N'TR') IS NOT NULL
	DROP TRIGGER tD_user_hdr;
GO

CREATE TRIGGER dbo.tD_user_hdr 
ON dbo.user_hdr
AFTER
DELETE
AS
BEGIN
	DELETE uc 
	FROM dbo.user_course AS uc
		INNER JOIN DELETED AS d
			ON uc.user_sid = d.user_sid
END




