Get-Module -Name "PowerSwirl" -All | Remove-Module -Force 
Import-Module "PowerSwirl" -Force -ErrorAction Stop 

InModuleScope PowerSwirl {

    Describe "Get-LessonInfo" {
        BeforeAll {
            $PowerSwirlConnection = Get-PowerSwirlConnection
            $ServerInstance = $PowerSwirlConnection.ServerInstance 
            $Database = $PowerSwirlConnection.Database 
            $Query = "TRUNCATE TABLE dbo.course_hdr;"
            $Params = @{
                ServerInstance = $ServerInstance;
                Database=$Database;
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
            ,   requires_solution
            ,   requires_code_execution
            ,   requires_set_variable
            ,   requires_solution_execution
            ,   requires_pause
            )
            VALUES 
              (1,1,1,'A1 S1',0,0,0,0,0)
            , (1,1,2,'A1 S2',0,0,0,0,0)
            , (1,1,3,'A1 S3',0,0,0,0,0)

            , (2,1,1,'B1 S1',0,0,0,0,0)
            , (2,1,2,'B1 S2',0,0,0,0,0)
            , (2,1,3,'B1 S3',0,0,0,0,0)
            , (2,1,4,'B1 S4',0,0,0,0,0)
            
            , (3,1,1,'C1 S1',0,0,0,0,0)
            , (3,1,2,'C1 S2',0,0,0,0,0)
            , (3,1,3,'C1 S3',0,0,0,0,0)
            , (3,1,4,'C1 S4',0,0,0,0,0)
            , (3,1,5,'C1 S5',0,0,0,0,0)
            , (3,1,6,'C1 S6',0,0,0,0,0)
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
                    ServerInstance=$ServerInstance;
                    Database=$Database;
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
                    ServerInstance=$ServerInstance;
                    Database=$Database;
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
                    ServerInstance=$ServerInstance;
                    Database=$Database;
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
    }

    Describe "Get-LessonContent" {
        BeforeAll {
            $PowerSwirlConnection = Get-PowerSwirlConnection
            $ServerInstance = $PowerSwirlConnection.ServerInstance 
            $Database = $PowerSwirlConnection.Database 
            $Params = @{
                ServerInstance=$ServerInstance;
                Database=$Database;
            }
            $Query = "TRUNCATE TABLE dbo.lesson_dtl;"
            $Params["Query"] = $Query
            Invoke-Sqlcmd2 @Params

            $Query = "INSERT INTO dbo.lesson_dtl 
            (
                course_sid
            ,   lesson_sid
            ,   step_num
            ,   step_prompt

            ,   requires_solution
            ,   requires_code_execution
            ,   requires_set_variable
            ,   requires_pause
            ,   requires_solution_execution
            
            ,   code_to_execute
            ,   variable_to_set
            ,   solution_expression
            )
            VALUES 
              (1,1,1,'A1 S1',1,0,0,0,0, NULL, NULL, 'A_ans1')
            , (1,1,2,'A1 S2',1,1,0,0,0, NULL, NULL, 'A_ans2')
            , (1,1,3,'A1 S3',0,0,0,0,0, NULL, NULL, NULL)
            , (1,1,4,'A1 S4',1,0,1,0,0, NULL, 'A_var4', 'A_ans4')
            , (1,1,5,'A1 S5',0,0,0,0,0, NULL, NULL, NULL)

            , (2,1,1,'B1 S1',0,0,0,0,0, NULL, NULL, NULL)
            , (2,1,2,'B1 S2',1,0,1,0,0, NULL, 'B_var2', 'B_ans2')
            , (2,1,3,'B1 S3',0,1,1,0,0, NULL, 'B_var3', 'B_ans3')
            , (2,1,4,'B1 S4',1,0,1,0,0, NULL, 'B_var4', 'B_ans4')
            ;
            "
            $Params["Query"] = $Query 
            Invoke-Sqlcmd2 @Params


            $CourseContentA1 = Get-LessonContent -CourseSid 1 -LessonSid 1
            $CourseContentB1 = Get-LessonContent -CourseSid 2 -LessonSid 1
        }
	    Context "Course A Lesson A1" {
            It "should write 5 objects to the pipeline" {
                $CourseContentA1.Count | Should be 5
            }

            $tc = @(
                @{propertyName='stepNum'}
                @{propertyName='stepPrompt'}
                @{propertyName='requiresPause'}
                @{propertyName='requiresSolution'}
                @{propertyName='requiresCodeExecution'}
                @{propertyName='requiresSetVariable'}
                @{propertyName='requiresSolutionExecution'}
                @{propertyName='codeToExecute'}
                @{propertyName='variableToSet'}
                @{propertyName='solutionExpression'}
            )
            It "should write objects that have a '<propertyName>' property" -TestCases $tc {
                param 
                (
                    [String] $propertyName
                )
                $propertyName | Should BeIn ($CourseContentA1 | 
                                                Get-Member -MemberType Properties | 
                                                Select-Object -ExpandProperty Name 
                                            )
            }

            $tc = @(
                @{propertyName='stepNum'; expectedType="int"},
                @{propertyName='stepPrompt'; expectedType="string"},
                @{propertyName='requiresPause'; expectedType="bool"},
                @{propertyName='requiresSolution'; expectedType="bool"},
                @{propertyName='requiresCodeExecution'; expectedType="bool"},
                @{propertyName='requiresSetVariable'; expectedType="bool"},
                @{propertyName='requiresSolutionExecution'; expectedType="bool"}
            )
            It "should write <propertyName> as type <expectedType>" -TestCases $tc {
                param
                (
                    [String] $propertyName
                ,
                    [String] $expectedType
                )
                
                Invoke-Expression "`$CourseContentA1 | Select-Object -ExpandProperty $propertyName | Should BeOfType [$expectedType]"
            }

            
            $tc = @(
                @{propertyName='codeToExecute'; expectedType="string"},
                @{propertyName='variableToSet'; expectedType="string"},
                @{propertyName='solutionExpression'; expectedType="string"}
            )
            It "should write <propertyName> as <expectedType> or `$null" -TestCases $tc {
                param
                (
                    [String] $propertyName
                ,
                    [String] $expectedType
                )
                
                Invoke-Expression "`$notNull = `$CourseContentA1 | 
                                    Select-Object -ExpandProperty $propertyName | 
                                    Where-Object {`$_} 

                                    if(`$notNull)
                                    {
                                        `$notNull | Should BeOfType [$expectedType]
                                    }
                                    "
            }

            $answersCSV = 
@'
                        stepNum, stepPrompt, requiresPause, requiresSolution, requiresCodeExecution, requiresSetVariable, requiresSolutionExecution, variableToSet, solutionExpression
                        1,"'A1 S1'",$false,$true,$false,$false,$false, $null,"'A_ans1'"
                        2,"'A1 S2'",$false,$true,$true,$false,$false, $null,"'A_Ans2'"
                        3,"'A1 S3'",$false,$false,$false,$false,$false, $null,$null
                        4,"'A1 S4'",$false,$true,$false,$true,$false,"'A_Var4'","'A_Ans4'"
                        5,"'A1 S5'",$false,$false,$false,$false,$false,$null,$null
'@
            $tc = @()

            $answers = ConvertFrom-Csv $answersCSV

            $properties = $answers | 
                            Get-Member -MemberType Properties | 
                            Select-Object -ExpandProperty Name | 
                            Where-Object {$_ -ne "stepNum"}

            foreach($answer in $answers)
            {
                foreach($property in $properties)
                {
                    $tc += @{stepNum=$answer.stepNum; 
                             propertyName=$property; 
                             expectedValue=(iex (iex "`$answer.$property"))}
                }
            }

            It "should in step <stepNum> have <propertyName> value = <expectedValue>" -TestCases $tc {
                param
                (
                    [Int] $stepNum
                ,
                    [String] $propertyName
                ,
                    $expectedValue 
                )
                $CourseContentA1 | 
                    Where-Object {$_.stepNum -eq $stepNum} | 
                    Select-Object -ExpandProperty $propertyName |
                    Should be $expectedValue
            }

                
        }
        Context "Course B Lesson B1" {
            It "should write 4 objects to the pipeline" {
                $CourseContentB1.Count | Should be 4
            }

            $tc = @(
                @{propertyName='stepNum'}
                @{propertyName='stepPrompt'}
                @{propertyName='requiresPause'}
                @{propertyName='requiresSolution'}
                @{propertyName='requiresCodeExecution'}
                @{propertyName='requiresSetVariable'}
                @{propertyName='requiresSolutionExecution'}
                @{propertyName='codeToExecute'}
                @{propertyName='variableToSet'}
                @{propertyName='solutionExpression'}
            )
            It "should write objects that have a '<propertyName>' property" -TestCases $tc {
                param 
                (
                    [String] $propertyName
                )
                $propertyName | Should BeIn ($CourseContentB1 | 
                                                Get-Member -MemberType Properties | 
                                                Select-Object -ExpandProperty Name 
                                            )
            }

            $tc = @(
                 @{propertyName='stepNum'; expectedType="int"},
                @{propertyName='stepPrompt'; expectedType="string"},
                @{propertyName='requiresPause'; expectedType="bool"},
                @{propertyName='requiresSolution'; expectedType="bool"},
                @{propertyName='requiresCodeExecution'; expectedType="bool"},
                @{propertyName='requiresSetVariable'; expectedType="bool"},
                @{propertyName='requiresSolutionExecution'; expectedType="bool"}
            )
            It "should write <propertyName> as type <expectedType>" -TestCases $tc {
                param
                (
                    [String] $propertyName
                ,
                    [String] $expectedType
                )
                
                Invoke-Expression "`$CourseContentB1 | Select-Object -ExpandProperty $propertyName | Should BeOfType [$expectedType]"
            }

            
            $tc = @(
                @{propertyName='codeToExecute'; expectedType="string"},
                @{propertyName='variableToSet'; expectedType="string"},
                @{propertyName='solutionExpression'; expectedType="string"}
            )
            It "should write <propertyName> as <expectedType> or `$null" -TestCases $tc {
                param
                (
                    [String] $propertyName
                ,
                    [String] $expectedType
                )

                Invoke-Expression "`$notNull = `$CourseContentB1 | 
                                    Select-Object -ExpandProperty $propertyName | 
                                    Where-Object {`$_} 

                                    if(`$notNull)
                                    {
                                        `$notNull | Should BeOfType [$expectedType]
                                    }
                                    "
            }

            $answersCSV = 
@'
                        stepNum, stepPrompt, requiresPause, requiresSolution, requiresCodeExecution, requiresSetVariable, requiresSolutionExecution, variableToSet, solutionExpression
                         1,"'B1 S1'",$false,$false,$false,$false,$false, $null, $null
                         2,"'B1 S2'",$false,$true,$false,$true,$false, "'B_var2'", "'B_ans2'"
                         3,"'B1 S3'",$false,$false,$true,$true,$false, "'B_var3'", "'B_ans3'"
                         4,"'B1 S4'",$false,$true,$false,$true,$false, "'B_var4'", "'B_ans4'"
'@
            $tc = @()

            $answers = ConvertFrom-Csv $answersCSV

            $properties = $answers | 
                            Get-Member -MemberType Properties | 
                            Select-Object -ExpandProperty Name | 
                            Where-Object {$_ -ne "stepNum"}

            foreach($answer in $answers)
            {
                foreach($property in $properties)
                {
                    $tc += @{stepNum=$answer.stepNum; 
                             propertyName=$property; 
                             expectedValue=(iex (iex "`$answer.$property"))}
                }
            }

            It "should in step <stepNum> have <propertyName> value = <expectedValue>" -TestCases $tc {
                param
                (
                    [Int] $stepNum
                ,
                    [String] $propertyName
                ,
                    $expectedValue 
                )
                $CourseContentB1 | 
                    Where-Object {$_.stepNum -eq $stepNum} | 
                    Select-Object -ExpandProperty $propertyName |
                    Should be $expectedValue
            }
        }
    }

    Describe "Test-StepInput" -Tag TestStepInput {
        BeforeAll {
            $ErrorMessageDoesNotMatch = "Input does not match solution"
        }
        Context "Single character" {
            It "should not throw if the answer and input are single characters that match" {
                {Test-StepInput -UserInput 'a' -Solution 'a'} | Should not throw
	        }
            
            It "should not throw if the answer and input are single characters that differ only in casing" {
                {Test-StepInput -UserInput 'a' -Solution 'A'} | Should not throw
	        }

            It "should not throw if the answer is an integer and the input is the same integer but in string form" {
                {Test-StepInput -UserInput '1' -Solution 1} | Should not throw
	        }

            It "should not throw if the answer is a string representing an integer and the input is the same integer but in non-string form" {
                {Test-StepInput -UserInput 1 -Solution '1'} | Should not throw
	        }
                
            It "should not throw if the answer and the input differ only in whitespace" {
                {Test-StepInput -UserInput 'a   ' -Solution 'a'} | Should not throw
            }

            It "should throw if the answer and input are single characters that don't match "{
                {Test-StepInput -UserInput 'a' -Solution 'b'} | Should throw $ErrorMessageDoesNotMatch
            }

            It "should throw if the answer is a single character and the input is null" {
                {Test-StepInput -UserInput $null -Solution 'a'} | Should throw $ErrorMessageDoesNotMatch
            }
        }

        Context "Multiple characters" {
            It "should not throw if the answer and the input are multiple-character strings that match exactly" {
                {Test-StepInput -UserInput "Cashews" -Solution "Cashews"} | Should not throw
            }

            It "should not throw if the answer and the input are multiple character strings differ only in casing" {
                {Test-StepInput -UserInput "CaShEwS" -Solution "cashews"} | Should not throw
            }

            It "should not throw if the answer and the input are the same except for whitespace" {
                {Test-StepInput -UserInput "      cashews    " -Solution "cashews"} | Should not throw
            }

            It "should throw if the answer and the input are different strings (disregarding casing and whitespace)" {
                {Test-StepInput -UserInput "peanuts" -Solution "cashews"} | Should throw $ErrorMessageDoesNotMatch
            }

            It "should throw if the answer is not null and the input is null" {
                {Test-StepInput -UserInput $null -Solution "cashews"} | Should throw $ErrorMessageDoesNotMatch
            }

            It "should throw if the answer is null and the input is not null" {
                {Test-StepInput -UserInput "peanuts" -Solution $null} | Should throw $ErrorMessageDoesNotMatch
            }
        }

        Context "Code solution" {
            It "should not throw when the answer and input are code strings that are exactly the same" {
                {Test-StepInput -UserInput "(1+1)" -Solution "(1+1)" -ExecuteCode} | 
                    Should not throw
            }

            It "should not throw when the answer and input are code strings that have the same effect, but are achieved in logically different ways" {
                {Test-StepInput -UserInput "0+1" -Solution "3-2" -ExecuteCode} | 
                    Should not throw
            }

            It "should throw when the answer and input evaluate to integers which are not equal" {
                {Test-StepInput -UserInput "1+1" -Solution "1*1" -ExecuteCode} | 
                    Should throw $ErrorMessageDoesNotMatch
            }

            It "should throw when the answer and input evaluate to strings which are not equal" {
                {Test-StepInput -UserInput "'abc' + 'xyz'" -Solution "'xyz' + 'abc'" -ExecuteCode} | 
                    Should throw $ErrorMessageDoesNotMatch
            }
        }
	    
    }

}