# PodePSHTML

This is an example for using pode and PSHTML with mySQLite and Pester.

![PodePSHTM-Index](./public/img/PodePSHTML.png)

Requires pode, PSHTML, Pester and mySQLite

````powershell
Install-Module -Name Pode, PSHTML, mySQLite, Pester -SkipPublisherCheck -Repository PSGallery -Force -Verbose
````

Create a root folder, for example PodePSHTML:

````powershell
New-Item -Path . -Name PodePSHTML -ItemType Directory -Force -Confirm:False
````

Change in to the new directory:

````powershell
Set-Location ./PodePSHTML
````

Clone the code from my repository:

````powershell
git clone https://github.com/tinuwalther/PodePSHTML.git
````

Start pode:

````powershell
pwsh ./PodePSHTML/PodeServer.ps1
````

Open your preffered browser and enter http://localhost:8080/ in the address - enjoy PodePSHTML!
