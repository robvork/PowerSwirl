DROP PROCEDURE IF EXISTS dbo.p_get_samples;
GO

CREATE PROCEDURE dbo.p_get_samples
(
	  @as_sample_table SYSNAME
	/*
		Table with following schema:
		(
			sample_type TINYINT NOT NULL -- the type of sample (corresponds to e.g. course, lesson, step)
			sample_sid BIGINT NOT NULL -- the unique identifier of the sampleect being sampled for
			min_val BIGINT NOT NULL -- the minimum value the sample can take
			max_val BIGINT NOT NULL -- the maximum value the sample can take
			sample_val BIGINT NULL -- the randomly sampled value (use seed if you want repeatability)
			PRIMARY KEY(sample_type, sample_sid) -- each combination of sample_type and sample_sid gets a unique sample
		)
	*/
	, @ai_sample_type_sid TINYINT
	, @ai_debug_level INT 
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ls_sql NVARCHAR(MAX);
	DECLARE @ls_params NVARCHAR(MAX); 

	SET @ls_sql = 
	CONCAT 
	(
	 N'UPDATE ', @as_sample_table, N' 
	   SET sample_val = min_val + (ABS(CHECKSUM(NEWID())) % (max_val - min_val) + 1)
	   WHERE sample_type_sid = ', @ai_sample_type_sid, N'
	   ;
	  ' 
	);

	EXEC(@ls_sql);

	IF @ai_debug_level > 1
	BEGIN
		SET @ls_sql = 
		CONCAT
		(
			N'SELECT sample_type_sid
			, sample_sid
			, min_val
			, max_val
			, sample_val FROM ', @as_sample_table, N' 
			WHERE sample_type_sid = ', @ai_sample_type_sid, N'
			;
			 '
		);
		EXEC(@ls_sql);
	END;
END
GO


