# PodePSHTML

<!-- TOC -->

- [PodePSHTML](#podepshtml)
    - [Overview](#overview)
    - [File Watcher](#file-watcher)
        - [Index](#index)
        - [Pode](#pode)
        - [Asset](#asset)
        - [SQLite](#sqlite)
        - [Pester](#pester)
        - [Mermaid](#mermaid)
    - [API](#api)
        - [Index](#index)
        - [Pode](#pode)
        - [Asset](#asset)
        - [SQLite](#sqlite)
        - [Pester](#pester)
        - [Mermaid](#mermaid)

<!-- /TOC -->

## Overview

This is an example for using pode and PSHTML with mySQLite and Pester v5+.

![PodePSHTM-Index](./public/img/PodePSHTML.png)

Requires pode, PSHTML, PsNetTools, Pester and mySQLite

````powershell
Install-Module -Name Pode, PSHTML, mySQLite, PsNetTools, Pester -SkipPublisherCheck -Repository PSGallery -Force -Verbose
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

[TOP](#)

## File Watcher

There is a File Watcher registered on ./PodePSHTML/upload.

The File Watcher monitors files (with an extension) in the folder. It wait for events of type Changed, Created, Deleted, and Renamed.

### Index

Re-builds the Index.pode page:

````powershell
New-Item ./PodePSHTML/upload -Name index.txt -Force
````

### Pode

Re-builds the Pode-Server.pode page:

````powershell
New-Item ./PodePSHTML/upload -Name pode.txt -Force
````

### Asset

Re-builds the Update-Assets.pode page:

````powershell
New-Item ./PodePSHTML/upload -Name asset.txt -Force
````

### SQLite

The File Watcher monitors for a file sqlite.txt of the type Created or Changed (Move-Item, New-Item).

Re-builds the SQLite-Data.pode page:

````powershell
New-Item ./PodePSHTML/upload -Name sqlite.txt -Force
````

Re-builds the SQLite-Data.pode page with the following Sql-Statement:

````powershell
'SELECT * FROM "classic_ESXiHosts" Limit 10' | Set-Content -Path ./PodePSHTML/upload/sqlite.txt -Force
````

### Pester

Re-builds the Pester-Result.pode page:

````powershell
Import-Module Pester
$config = [PesterConfiguration]@{
    Should = @{
        ErrorAction = 'Continue'
    }
    Run = @{
        Path = './PodePSHTML/bin/Invoke-PesterResult.Tests.ps1'
    }
    Output = @{
        Verbosity = 'None'
    }
    TestResult = @{
        Enabled      = $true
        OutputFormat = 'NUnitXml'
        OutputPath   = './PodePSHTML/upload/pester.xml'
    }
}
Invoke-Pester -Configuration $config
````

### Mermaid

Re-builds the Mermaid-Diagram.pode page:

````powershell
New-Item ./PodePSHTML/upload -Name mermaid.txt -Force
````

[TOP](#)

## API

It's also possible, to send REST API requests to pode.

### Index

Re-builds the Index.pode page:

````powershell
Invoke-WebRequest -Uri http://localhost:8080/api/index -Method Post
````

````powershell
StatusCode        : 200
StatusDescription : OK
Content           : Page created: Index.pode
````

### Pode

Re-builds the Pode-Server.pode page:

````powershell
Invoke-WebRequest -Uri http://localhost:8080/api/pode -Method Post
````

````powershell
StatusCode        : 200
StatusDescription : OK
Content           : Page created: Pode-Server.pode
````

### Asset

Re-builds the Update-Assets.pode page:

````powershell
Invoke-WebRequest -Uri http://localhost:8080/api/asset -Method Post
````

````powershell
StatusCode        : 200
StatusDescription : OK
Content           : Page created: Update-Assets.pode
````

### SQLite

Re-builds the SQLite-Data.pode page with the following Sql-Statement:

````powershell
Invoke-WebRequest -Uri http://localhost:8080/api/sqlite -Method Post -Body 'SELECT * FROM "classic_ESXiHosts" Limit 10'
````

````powershell
StatusCode        : 200
StatusDescription : OK
Content           : Page created: SQLite-Data.pode
````

### Pester

Re-builds the Pester-Result.pode page:

````powershell
Invoke-WebRequest -Uri http://localhost:8080/api/pester -Method Post
````

````powershell
StatusCode        : 200
StatusDescription : OK
Content           : Page created: Pester-Result.pode
````

### Mermaid

Re-builds the Mermaid-Diagram.pode page:

````powershell
Invoke-WebRequest -Uri http://localhost:8080/api/mermaid -Method Post
````

````powershell
StatusCode        : 200
StatusDescription : OK
Content           : Page created: Mermaid-Diagram.pode
````
