# PowerSwirl

## What is PowerSwirl? 
PowerSwirl is an interactive environment for learning how to code. 
It is hosted in the PowerShell command line shell, formerly a Windows exclusive but now open-source and cross platform. 

The core idea behind PowerSwirl is that **programming is learned best by doing**. 
Each PowerSwirl lesson teaches new concepts one small bite at a time with practice questions and coding exercises to ensure you 
understand what you're learning. Lessons are designed to be short and repeatable, so you can get the most out of whatever time you have. 

## Prerequisites 
PowerSwirl currently has the following prerequisites:
* Microsoft Windows
* SQL Server 2012 or later
* Windows PowerShell 5

You can obtain the latest versions of SQL Server Developer Edition and PowerShell for free from Microsoft's website.
Future versions of PowerSwirl will support Linux and MacOS as well as other relational database management systems. 

## Installation
To import the PowerSwirl module and install all required database objects, run the 'install.ps1' script in your local PowerShell environment. Substitute your local module root and SQL Server Instance into the parameters. 

```powershell
.\install.ps1 -ServerInstance "ROBVK\SQL16" -ModuleRoot $Modules\PowerSwirl
```

## Taking your first lesson
After you've run install.ps1, you can take your first lesson. 

Type the following into your PowerShell console:
```powershell
Start-PowerSwirl
```

You will see one course "PowerShell Orientation" available with two courses: "Using the Help System" and "Wildcards". If you're new to PowerShell, you should take "Using the Help System". If you've had some experience, try "Wildcards". These lessons will get you familiar with the structure and mechanics of taking PowerSwirl lessons and teach you a few things!

## Writing your own lessons with PowerSwirl Lesson Markup (PSLM)
You can easily create your own lessons for PowerShell or other languages/technologies by using a simple markup language based in XML. 
Each lesson XML file contains a header and a body. The header specifies the course and lesson names for the lesson being imported. The body specifies one or more sections, each containing a number of steps with text prompts and optional code execution and practice exercises. 

To learn more about the format for PSLM, read the importGuide.txt document at the module root.

**You don't need to know any PowerShell to create lessons with multiple choice and free response questions, but you will need to know a bit to create code exercises in your target language, whether it's PowerShell or anything else.**

## Importing PowerSwirl lessons from PSLM
Once you've created a lesson in your topic of choice, you can use the ```ConvertFrom-LessonMarkup``` and ```Import-Lesson``` PowerSwirl commands to import the lesson into your hosting database: 

```powershell
# List paths to one or more lesson markup file
$LessonMarkupPaths = @(
".\database\Data\Lessons\PowerShell Orientation\using_the_help_system.xml"
".\database\Data\Lessons\PowerShell Orientation\wildcards.xml"
)

# Feed your lesson markup paths to ConvertFrom-PowerSwirlLessonMarkup and Import-PowerSwirlLesson
$LessonMarkupPaths | 
Select-Object @{n="Path"; e={$_}} | 
Get-Content -Raw | 
ConvertFrom-PowerSwirlLessonMarkup | 
Import-PowerSwirlLesson -CreateNewCourse -OverWriteLesson -Verbose 
```

