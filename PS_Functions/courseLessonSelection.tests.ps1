Import-Module "C:\Users\ROBVK\Documents\Workspace\Projects\PowerSwirl" -Force 

InModuleScope "PowerSwirl" {
    Describe "Write-RetryPrompt" {
        Context "Non-empty message" {
            BeforeAll {
                $message = "The course you selected is not valid"
                $postMessage = "Please try again."
                Write-RetryPrompt -Message $message -InformationVariable iv

                $messageWritten = $iv | 
                                  Where-Object {$_.Tags -eq "message"} | 
                                  Select-Object -ExpandProperty MessageData
                $postMessageWritten = $iv | 
                                  Where-Object {$_.Tags -eq "postmessage"} | 
                                  Select-Object -ExpandProperty MessageData    
            }

            It "should not throw" {
                {Write-RetryPrompt $message} | should not throw
            }

            It "should put a message m1 into the information stream with tag 'message'" {
                 $messageWritten | should not be nulllorempty   
	        }

            It "should put a string into m1 (defined above)" {
                 $messageWritten | should beoftype [string]  
	        }

            It "should put the string specified into m1 (defined above)" {
                 $messageWritten | should be $message
	        }
            
            It "should put a message m2 into the information stream with tag 'postmessage'" {
                 $postMessageWritten | should not be nulllorempty     
	        }

            It "should put a string into m2 (defined above)" {
                 $postMessageWritten | should beoftype [string]  
	        }

            It "should put the string specified into m2 (defined above)" {
                 $postMessageWritten | should be $postMessage 
	        }

            
        }
        Context "Empty or null message" {
            BeforeAll {
                $ErrorMessage = "Message must be not null and not empty"
            }
            
            It "should throw when message is empty" { 
                {Write-RetryPrompt -Message ""} | should throw $ErrorMessage 
            }

            It "should throw when message is null" { 
                {Write-RetryPrompt -Message $null} | should throw $ErrorMessage 
            }
        }
    }

    Describe "Read-MenuSelection" {
	    It "should..." -Pending {

	    }
    }

    <#
        function Write-CourseHeaders
        {
            [CmdletBinding()]
            param
            (
                $Courses
            )

            Write-Information -MessageData $Courses.Length -Tags CourseCount -InformationAction SilentlyContinue
            Write-Information -MessageData "Choose a course from the following" -Tags PreHeaders
            foreach($Course in $Courses)
            {
                $CourseLine = $Course.selection.ToString() + ": " + $Course.course_id
                Write-Information -MessageData $CourseLine -Tags CourseLine 
            }
        }
    #>
    Describe "Write-CourseHeaders" {
	    Context "One course" {
            BeforeAll {
                $Courses = [CourseHeader[]] @()
                $Courses += [CourseHeader]::new(1, "The First Course", 45)

                Write-CourseHeaders -Courses $Courses -InformationVariable iv
                $CourseCount = $iv | 
                               Where-Object {$_.Tags -eq "CourseCount"}
                $PreHeader = $iv | 
                               Where-Object {$_.Tags -eq "PreHeader"}
                $CourseHeaders = $iv | 
                               Where-Object {$_.Tags -eq "CourseHeader"} |
                               Sort-Object 
            }

            It "should write a message m1 into the information stream with tag 'CourseCount'" {
                $CourseCount | Should not benullorempty
            }

            It "should write a message m2 into the information stream with tag 'PreHeader'" {
                $PreHeader | Should not benullorempty
            }

            It "should write at least one message into the information stream with tag 'CourseHeader'" {
                $CourseHeaders | Should not benullorempty
            }

            
        }

        Context "Two courses" {
            BeforeAll {
                $Courses = [CourseHeader[]] @()
                $Courses += [CourseHeader]::new(1, "The First Course", 45)
                $Courses += [CourseHeader]::new(2, "The Second Course", 29)

                Write-CourseHeaders -Courses $Courses -InformationVariable iv
                
                $CourseCount = $iv | 
                               Where-Object {$_.Tags -eq "CourseCount"}
                $PreHeader = $iv | 
                               Where-Object {$_.Tags -eq "PreHeader"}
                $CourseHeaders = $iv | 
                               Where-Object {$_.Tags -eq "CourseHeader"} |
                               Sort-Object 
                 
            }

            It "should write a message m1 into the information stream with tag 'CourseCount'" {
                $CourseCount | Should not benullorempty
            }

            It "should write a message m2 into the information stream with tag 'PreHeader'" {
                $PreHeader | Should not benullorempty
            }

            It "should write at least one message into the information stream with tag 'CourseHeader'" {
                $CourseHeaders | Should not benullorempty
            }
        }

        Context "Three courses" { 
            BeforeAll {
                $Courses += [CourseHeader]::new(1, "The First Course", 45)
                $Courses += [CourseHeader]::new(2, "The Second Course", 29)
                $Courses += [CourseHeader]::new(3, "The Third Course", 188)

                Write-CourseHeaders -Courses $Courses -InformationVariable iv

                $CourseCount = $iv | 
                               Where-Object {$_.Tags -eq "CourseCount"}
                $PreHeader = $iv | 
                               Where-Object {$_.Tags -eq "PreHeader"}
                $CourseHeaders = $iv | 
                               Where-Object {$_.Tags -eq "CourseHeader"} |
                               Sort-Object 
            }

            It "should write a message m1 into the information stream with tag 'CourseCount'" {
                $CourseCount | Should not benullorempty
            }

            It "should write a message m2 into the information stream with tag 'PreHeader'" {
                $PreHeader | Should not benullorempty
            }

            It "should write at least one message into the information stream with tag 'CourseHeader'" {
                $CourseHeaders | Should not benullorempty
            }
        }

        Context "0 courses" {
            BeforeAll {
                $Courses = 
            }
        }

        It "should..." {
            
	    }
    }

    Describe "Write-LessonHeaders" {
	    It "should..." {

	    }
    }

    Describe "Test-PSwirlCourse" {
	    It "should..." {

	    }
    }

    Describe "Test-PSwirlLesson" {
	    It "should..." {

	    }
    }

    Describe "Test-MenuSelection" {
	    It "should..." {

	    }
    }

    Describe "Get-CourseHeaders" {
	    It "should..." {

	    }
    }

    Describe "Get-LessonHeaders" {
	    It "should..." {

	    }
    }


}
