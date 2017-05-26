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

    Describe "Write-CourseHeaders" {
	    Context "One course" {
            BeforeAll {
                $CourseHeaders = [CourseHeader[]] @()
                $CourseHeaders += [CourseHeader]::new(1, "The First Course", 45)
                $CourseHeaders += [CourseHeader]::new(2, "The Second Course", 29)
                $CourseHeaders += [CourseHeader]::new(3, "The Third Course", 188)

                $CourseHeaders1 = $CourseHeaders[0]
                $CourseHeaders2 = $CourseHeaders[0..1]
                $CourseHeaders3 = $CourseHeaders[0..2]

                $CourseHeadersList = @($CourseHeaders1, $CourseHeaders2, $CourseHeaders3)
                $CourseCountList = @{}
                $PreHeaderList = @{} 
                $CourseHeaderStringsList = @{}
                $CourseHeader2AllData = @{}

                foreach($ch in $CourseHeadersList)
                {
                    Write-CourseHeaders -CourseHeaders $ch -InformationVariable iv
                    $CourseCountList[$ch] = $iv | 
                                            Where-Object {$_.Tags -eq "CourseCount"}
                    $PreHeaderList[$ch] = $iv | 
                                          Where-Object {$_.Tags -eq "PreHeader"}
                    $CourseHeaderStringsList[$ch] = $iv | 
                                                    Where-Object {$_.Tags -eq "CourseHeader"} |
                                                    Sort-Object
                    $CourseHeader2AllData[$ch] = @{CourseCount=$CourseCountList[$ch]  
                                                   PreHeader=$PreHeaderList[$ch]
                                                   CourseHeaderStrings=$CourseHeaderStringsList[$ch]
                                                  }
                    
                }             
                               
                $PreHeaderMessage = "Choose a course from the following"                
            }

            It "should write a message m1 into the information stream with tag 'CourseCount'" {
                param($CourseCount)
                $CourseCount | Should not benullorempty
            }

            It "should write exactly one message with tag 'CourseCount'" {
                param($CourseCount)
                $CourseCount.Length | Should be 1
            }

            It "should write an int for Coursecount" {
                param($CourseCount)
                $CourseCount.MessageData | Should beoftype [int]
            }

            It "should write a course count equal to the number of course headers" {
                param($CourseCount, $CourseHeaderStrings)
                $CourseCount.MessageData | Should be $CourseHeaderStrings.Length
            }

            It "should write a message m2 into the information stream with tag 'PreHeader'" {
                param($PreHeader)
                $PreHeader | Should not benullorempty
            }

            It "should write exactly one message with tag 'PreHeader'" {
                param($PreHeader)
                $PreHeader.Length | Should be 1
            }
            
            It "should write a string for the message with tag 'PreHeader'" {
                param($PreHeader)
                $PreHeader.MessageData | Should beoftype [String]
            }

            It "should write a predetermined message to the message with tag 'PreHeader'" {
                param($PreHeader)
                $PreHeader.MessageData | Should be $PreHeaderMessage
            }

            It "should write at least one message into the information stream with tag 'CourseHeader'" {
                param($CourseHeaderStrings)
                $CourseHeaderStrings | Should not benullorempty
            }

            It "should write exactly one message with tag 'CourseHeader'" {
                param($CourseHeaderStrings)
                $CourseHeaderStrings.Length | Should be 1
            }

            
        }

        Context "Two courses" {
            BeforeAll {
                $CourseHeaders = [CourseHeader[]] @()
                $CourseHeaders += [CourseHeader]::new(1, "The First Course", 45)
                $CourseHeaders += [CourseHeader]::new(2, "The Second Course", 29)

                Write-CourseHeaders -CourseHeaders $CourseHeaders -InformationVariable iv
                
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
                $CourseHeaders = [CourseHeader[]] @()
                $CourseHeaders += [CourseHeader]::new(1, "The First Course", 45)
                $CourseHeaders += [CourseHeader]::new(2, "The Second Course", 29)
                $CourseHeaders += [CourseHeader]::new(3, "The Third Course", 188)

                Write-CourseHeaders -CourseHeaders $CourseHeaders -InformationVariable iv

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
