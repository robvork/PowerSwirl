IF EXISTS (SELECT * FROM sys.procedures WHERE name = N'p_create_new_user') 
	DROP PROCEDURE dbo.p_create_new_user;
GO

CREATE PROCEDURE dbo.p_create_new_user
(
	  @ai_debug_level INT = 0
	, @as_user_id ID
)
AS
/*******************************************************************************
Procedure
p_create_new_user

Description 
Creates a new user and returns its sid

--------------------------------Interface-----------------------------------------
Input Parameter(s)
@as_user_id : ID of user

Output Parameter(s)
None

Result Set(s)
A one row user set containing the following attributes
user_sid : the sid of the user with ID @as_user_id. 
		   either created or retrieved
user_exists : a bit indicating whether the user already existed prior to the procedure call.
		1 => user existed and sid retrieved
		2 => user did not exist
--------------------------------History-----------------------------------------
Date : 2017-01-14 12:24:45
Comment : 
Initial submission
*******************************************************************************/
BEGIN
	DECLARE @li_user_sid AS SID;
	DECLARE @ls_error_msg NVARCHAR(200);

	BEGIN TRY
		IF EXISTS(SELECT * FROM dbo.user_hdr WHERE user_id = @as_user_id)
		BEGIN
			RAISERROR(N'User ID already exists', 16, 1);
		END;

		INSERT INTO dbo.user_hdr 
		(
			user_sid
		,	user_id 
		)
		SELECT 
			(SELECT ISNULL(MAX(user_sid), 0) + 1 FROM dbo.user_hdr)
		,	@as_user_id
		;

		SELECT @li_user_sid AS [user_sid];
	END TRY
	BEGIN CATCH
		SET @ls_error_msg = ERROR_MESSAGE();
		
		RAISERROR(@ls_error_msg, 16, 1);
	END CATCH
END
GO
