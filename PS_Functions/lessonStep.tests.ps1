Import-Module PowerSwirl -Force 

InModuleScope PowerSwirl {
    $TestServerInstance = "ASPIRING\SQL16"
    $TestDatabase = "PowerSwirl_test"

    Describe "Get-LessonInfo" {
        BeforeAll {
            $Query = "TRUNCATE TABLE dbo.course_hdr;"
            $Params = @{
                ServerInstance = $TestServerInstance;
                Database=$TestDatabase;
                Query=$Query;
            }
            Invoke-Sqlcmd2 @Params 

            $Query = "INSERT INTO dbo.course_hdr(course_sid, course_id)
                      VALUES
                        (1, 'Course A')
                      , (2, 'Course B')
                      , (3, 'Course C')
                      ;
            " 
            $Params["Query"] = $Query 
            Invoke-Sqlcmd2 @Params 

            $Query = "TRUNCATE TABLE dbo.lesson_hdr;"
            $Params["Query"] = $Query 
            Invoke-Sqlcmd2 @Params 

            $Query = "INSERT INTO dbo.lesson_hdr (course_sid, lesson_sid, lesson_id)
                      VALUES 
                        (1, 1, 'A1')
                      , (2, 1, 'B1')
                      , (3, 1, 'C1')
                      ;
            "
            $Params["Query"] = $Query 
            Invoke-Sqlcmd2 @Params

            $Query = "TRUNCATE TABLE dbo.lesson_dtl;"
            $Params["Query"] = $Query
            Invoke-Sqlcmd2 @Params

            $Query = "INSERT INTO dbo.lesson_dtl 
            (
                course_sid
            ,   lesson_sid
            ,   step_num
            ,   step_prompt
            ,   requires_input_flag
            ,   execute_code_flag
            ,   store_var_flag
            )
            VALUES 
              (1,1,1,'A1 S1',0,0,0)
            , (1,1,2,'A1 S1',0,0,0)
            , (1,1,3,'A1 S1',0,0,0)

            , (2,1,1,'B1 S1',0,0,0)
            , (2,1,2,'B1 S1',0,0,0)
            , (2,1,3,'B1 S1',0,0,0)
            , (2,1,4,'B1 S1',0,0,0)
            
            , (3,1,1,'C1 S1',0,0,0)
            , (3,1,2,'C1 S1',0,0,0)
            , (3,1,3,'C1 S1',0,0,0)
            , (3,1,4,'C1 S1',0,0,0)
            , (3,1,5,'C1 S1',0,0,0)
            , (3,1,6,'C1 S1',0,0,0)
            ;
            "
            $Params["Query"] = $Query 
            Invoke-Sqlcmd2 @Params
        }
        Context "Course/lesson with 3 steps" {
            BeforeAll {
                $CourseSID = 1
                $LessonSID = 1
                $CourseIDExpected = 'Course A'
                $LessonIDExpected = 'A1'
                $NumStepsExpected = 3

                $Params = @{
                    ServerInstance=$TestServerInstance;
                    Database=$TestDatabase;
                    CourseSID=$CourseSID;
                    LessonSID=$LessonSID;
                }
                $Result = Get-LessonInfo @Params
                $Properties = $Result | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
            }       

            It "should write an object with property CourseID to the pipeline" {
                "CourseID" | Should BeIn $Properties 
            }

            It "should write CourseID as a string" {
                $Result | Select-Object -ExpandProperty CourseID | Should BeOfType [String]
            }

            It "should write an object with property LessonID to the pipeline" {
                "LessonID" | Should BeIn $Properties 
            }

            It "should write LessonID as a string" {
                $Result | Select-Object -ExpandProperty LessonID | Should BeOfType [String]
            }

            It "should write an object with property StepCount to the pipeline" {
                "StepCount" | Should BeIn $Properties 
            }

            It "should write StepCount as an int" {
                $Result | Select-Object -ExpandProperty StepCount | Should BeOfType [int]
            }

            It "should write CourseID = '$CourseIDExpected'" {
                $Result | Select-Object -ExpandProperty CourseID | Should be $CourseIDExpected
            }

            It "should write LessonID = '$LessonIDExpected'" {
                $Result | Select-Object -ExpandProperty LessonID | Should be $LessonIDExpected
            }

            It "should write StepCount = $NumStepsExpected" {
                $Result | Select-Object -ExpandProperty StepCount | Should be $NumStepsExpected
            }
            
        }

        Context "Course/lesson with 4 steps" {
            BeforeAll {
                $CourseSID = 2
                $LessonSID = 1
                $CourseIDExpected = 'Course B'
                $LessonIDExpected = 'B1'
                $NumStepsExpected = 4

                $Params = @{
                    ServerInstance=$TestServerInstance;
                    Database=$TestDatabase;
                    CourseSID=$CourseSID;
                    LessonSID=$LessonSID;
                }
                $Result = Get-LessonInfo @Params
                $Properties = $Result | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
            }

            It "should write an object with property CourseID to the pipeline" {
                "CourseID" | Should BeIn $Properties 
            }

            It "should write CourseID as a string" {
                $Result | Select-Object -ExpandProperty CourseID | Should BeOfType [String]
            }

            It "should write an object with property LessonID to the pipeline" {
                "LessonID" | Should BeIn $Properties 
            }

            It "should write LessonID as a string" {
                $Result | Select-Object -ExpandProperty LessonID | Should BeOfType [String]
            }

            It "should write an object with property StepCount to the pipeline" {
                "StepCount" | Should BeIn $Properties 
            }

            It "should write StepCount as an int" {
                $Result | Select-Object -ExpandProperty StepCount | Should BeOfType [int]
            }

            It "should write CourseID = '$CourseIDExpected'" {
                $Result | Select-Object -ExpandProperty CourseID | Should be $CourseIDExpected
            }

            It "should write LessonID = '$LessonIDExpected'" {
                $Result | Select-Object -ExpandProperty LessonID | Should be $LessonIDExpected
            }

            It "should write StepCount = $NumStepsExpected" {
                $Result | Select-Object -ExpandProperty StepCount | Should be $NumStepsExpected
            }
        }

        Context "Course/lesson with 6 steps" {
            BeforeAll {
                $CourseSID = 3
                $LessonSID = 1
                $CourseIDExpected = 'Course C'
                $LessonIDExpected = 'C1'
                $NumStepsExpected = 6

                $Params = @{
                    ServerInstance=$TestServerInstance;
                    Database=$TestDatabase;
                    CourseSID=$CourseSID;
                    LessonSID=$LessonSID;
                }
                $Result = Get-LessonInfo @Params
                $Properties = $Result | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
            }

            It "should write an object with property CourseID to the pipeline" {
                "CourseID" | Should BeIn $Properties 
            }

            It "should write CourseID as a string" {
                $Result | Select-Object -ExpandProperty CourseID | Should BeOfType [String]
            }

            It "should write an object with property LessonID to the pipeline" {
                "LessonID" | Should BeIn $Properties 
            }

            It "should write LessonID as a string" {
                $Result | Select-Object -ExpandProperty LessonID | Should BeOfType [String]
            }

            It "should write an object with property StepCount to the pipeline" {
                "StepCount" | Should BeIn $Properties 
            }

            It "should write StepCount as an int" {
                $Result | Select-Object -ExpandProperty StepCount | Should BeOfType [int]
            }

            It "should write CourseID = '$CourseIDExpected'" {
                $Result | Select-Object -ExpandProperty CourseID | Should be $CourseIDExpected
            }

            It "should write LessonID = '$LessonIDExpected'" {
                $Result | Select-Object -ExpandProperty LessonID | Should be $LessonIDExpected
            }

            It "should write StepCount = $NumStepsExpected" {
                $Result | Select-Object -ExpandProperty StepCount | Should be $NumStepsExpected
            }
        }


	    It "should..." {

	    }
    }

    Describe "Get-LessonContent" {
	    It "should..." {

	    }
    }

    Describe "Write-LessonPrompt" {
	    It "should..." {

	    }
    }

    Describe "Read-StepInput" {
	    It "should..." {

	    }
    }

    Describe "Test-StepInput" {
	    It "should..." {

	    }
    }

    Describe "Write-UserIncorrect" {
	    It "should..." {

	    }
    }

    Describe "Write-UserCorrect" {
	    It "should..." {

	    }
    }

}