function Create-NamBulkAdUser {

  <#
.SYNOPSIS

Create multiple active directory user from csv file

.DESCRIPTION

The `Create-NamBulkAdUser` cmdlet gets information from csv file in a specified location, csv file needs to have all required headers.
For each line in the csv file - it creates AD user with required attribute and set organization information for that user.

The `LogFile` parameter let you log all the information of the script to a file in a specified location.
If it doesn't have argument it will not log anything.

.EXAMPLE

PS C:\Users\MyAccount\Desktop> Create-NamBulkAdUser -Path .\test.csv

.EXAMPLE

PS C:\Users\MyAccount\Desktop> Create-NamBulkAdUser -Path .\test.csv -verbose
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Test-Path] - [INFO] - .\test.csv exist
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Check-Extension] - [INFO] - Filetype of .\test.csv is .csv
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Import-Csv] - [INFO] - Importing .\test.csv
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Import-Csv] - [INFO] - Importing .\test.csv : Succeed
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Check-CsvHeader] - [INFO] - CSV's header contains all required header
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Get-ADUser] - [ERROR] - User MyAccount@DOMAIN.com is already exist, stop creating user with UserPrincipalName MyAccount@DOMAIN.com
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [New-ADUser] - [INFO] - Creating user with UserPrincipalName testUser@DOMAIN.com
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [New-ADUser] - [INFO] - Creating user with UserPrincipalName testUser@DOMAIN.com : Succeed
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Get-ADUser] - [INFO] - Found user testUser@DOMAIN.com, Setting user's organization info
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Get-ADUser] - [INFO] - Found manager with SamAccountName MyAccount
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Set-ADUser] - [INFO] - Setting organization information for user with UserPrincipalName testUser@DOMAIN.com
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Set-ADUser] - [INFO] - Set organization user with UserPrincipalName testUser@DOMAIN.com : Succeed
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Get-ADUser] - [ERROR] - User Test,User is already exist, stop creating user with Name Test,User
VERBOSE: 2021-08-16 06:42:55 - DOMAIN\MyAccount - [Get-ADUser] - [ERROR] - OUpath CN=NotExist,DC=DOMAIN,DC=com is not exist, stop stop creating user testUser6@DOMAIN.com

.EXAMPLE

PS C:\Users\MyAccount\Desktop> Create-NamBulkAdUser -Path .\test.csv -LogFile test.log

.EXAMPLE

PS C:\Users\MyAcccount\Desktop> Create-NamBulkAdUser -Path .\test.csv -LogFile testRun.log -Verbose
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Test-Path] - [INFO] - .\test.csv exist
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Check-Extension] - [INFO] - Filetype of .\test.csv is .csv
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Import-Csv] - [INFO] - Importing .\test.csv
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Import-Csv] - [INFO] - Importing .\test.csv : Succeed
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Check-CsvHeader] - [INFO] - CSV's header contains all required header
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Get-ADUser] - [ERROR] - User MyAccount@DOMAIN.com is already exist, stop creating user with UserPrincipalName MyAccount@DOMAIN.com
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [New-ADUser] - [INFO] - Creating user with UserPrincipalName testUser@DOMAIN.com
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [New-ADUser] - [INFO] - Creating user with UserPrincipalName testUser@DOMAIN.com : Succeed
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Get-ADUser] - [INFO] - Found user testUser@DOMAIN.com, Setting user's organization info
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Get-ADUser] - [INFO] - Found manager with SamAccountName MyAccount
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Set-ADUser] - [INFO] - Setting organization information for user with UserPrincipalName testUser@DOMAIN.com
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Set-ADUser] - [INFO] - Set organization user with UserPrincipalName testUser@DOMAIN.com : Succeed
VERBOSE: 2021-08-16 06:42:54 - DOMAIN\MyAccount - [Get-ADUser] - [ERROR] - User Test,User is already exist, stop creating user with Name Test,User
VERBOSE: 2021-08-16 06:42:55 - DOMAIN\MyAccount - [Get-ADUser] - [ERROR] - OUpath CN=NotExist,DC=DOMAIN,DC=com is not exist, stop stop creating user testUser6@DOMAIN.com

.LINK

https://github.com/pzohaycuoi/IntuneAutoPilot

#>

  [CmdletBinding(SupportsShouldProcess = $true)]
  param (
    <#
      Path to file the csv file contains information to create AD user.
      Can be relative path or absolute path.
    #>
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias("FilePath", "P")]
    [string]
    $Path,

    <# 
      Logging file Path.
      If arguement exist all logging will be output to the file.
      If the file is not exist yet, a new file will be created.
      Can be realtive or absolute path.
    #>
    [string]
    $LogFile = $null,

    <#
      Output file path, contains all successfully created AD user.
      If argument exist all successfully created AD user will be output to the file
      If the file is not exsit yet, a new file will be created
      Can be relative or absolute path.
    #>
    [string]
    $OutputFile = $null
  )

  Process {

    # Check if path exist
    if (Test-Path -Path $Path) {
      Write-NamLog -Level "INFO" -Function "Test-Path" -LogFile $LogFile -Message "$Path exist"
    }
    else {
      Write-NamLog -Level "ERROR" -Function "Test-Path" -LogFile $LogFile -Message "$Path do not exist"
      Break
    }

    # Check if file extension is .csv
    if ([IO.Path]::GetExtension($Path) -eq ".csv") {
      Write-NamLog -Level "INFO" -Function "Check-Extension" -LogFile $LogFile -Message "Filetype of $Path is .csv"
    }
    else {
      Write-NamLog -Level "ERROR" -Function "Check-Extension" -LogFile $LogFile -Message "Filetype of $Path is not .csv"
      Break
    }

    # Import Csv file
    try {
      Write-NamLog -Level "INFO" -Function "Import-Csv" -LogFile $LogFile -Message "Importing $Path"
      $ImportCsv = Import-Csv -path $Path -ErrorAction Stop -ErrorVariable ErrLog
      Write-NamLog -Level "INFO" -Function "Import-Csv" -LogFile $LogFile -Message "Importing $Path : Succeed"
    }
    catch {
      Write-NamLog -Level "ERROR" -Function "Import-Csv" -LogFile $LogFile -Message "FAILED: Import-csv - $($_.Exception.Message)"
      Break
    }

    # Check header of csv file
    $CsvHeader = $ImportCsv[0].PsObject.Properties.Name
    $RequiredHeader = @(
      "SamAccountName", 
      "UPN", 
      "OuPath", 
      "FirstName", 
      "LastName",
      "Title",
      "Department",
      "Company",
      "Manager",
      "Location",
      "Address",
      "Region",
      "PostalCode",
      "Country"
    )

    foreach ($header in $Requiredheader) {
      if (-not($CsvHeader -contains $header)) {
        $Checker = $false
        Write-NamLog -Level "ERROR" -Function "Check-CsvHeader" -LogFile $LogFile -Message "CSV's header doesn't contain required header"
        Break
      }
      else { $Checker = $true }
    }
    if ($Checker -eq $false) { break }
    Write-NamLog -Level "INFO" -Function "Check-CsvHeader" -LogFile $LogFile -Message "CSV's header contains all required header"

    # Create AD User
    foreach ($user in $ImportCsv) {
      # Basic information to create AD user
      $SamAccountName = $user.SamAccountName
      $UserPrincipalName = $user.UPN
      $OuPath = $user.OuPath
      $GivenName = $user.FirstName
      $SurName = $user.LastName
      $Name = "$($user.FirstName), $($user.LastName)"
      $DisplayName = "$($user.FirstName), $($user.LastName)"

      # Check if user exist yet
      if ($null -ne (Get-ADUser -filter { UserPrincipalname -eq $UserPrincipalName })) {
        Write-NamLog -Level "ERROR" -Function "Get-ADUser" -LogFile $LogFile -Message "User $UserPrincipalName is already exist, stop creating user with UserPrincipalName $UserPrincipalName"
        Continue
      } 
      elseif ($null -ne (Get-ADUser -filter { SamAccountName -eq $SamAccountName })) {
        Write-NamLog -Level "ERROR" -Function "Get-ADUser" -LogFile $LogFile -Message "User $SamAccountName is already exist, stop creating user with SamAccountName $SamAccountName"
        Continue
      } 
      elseif ($null -ne (Get-ADUser -filter { Name -eq $Name })) {
        Write-NamLog -Level "ERROR" -Function "Get-ADUser" -LogFile $LogFile -Message "User $Name is already exist, stop creating user with Name $Name"
        Continue
      } 
      elseif ($null -eq (Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $OuPath })) {
        Write-NamLog -Level "ERROR" -Function "Get-ADUser" -LogFile $LogFile -Message "OUpath $OuPath is not exist, stop stop creating user $UserPrincipalName"
        Continue
      }
      else {
        # If not exist then create user with basic information
        try {
          $createState = $true
          Write-NamLog -Level "INFO" -Function "New-ADUser" -LogFile $LogFile -Message "Creating user with UserPrincipalName $UserPrincipalname"
          New-ADUser `
            -SamAccountName $SamAccountName `
            -UserPrincipalName $UserPrincipalName `
            -Path $OuPath `
            -GivenName $GivenName `
            -Surname $SurName `
            -Name $Name `
            -DisplayName $DisplayName `
            -ChangePasswordAtLogon $true `
            -Enabled $true `
            -AccountPassword (ConvertTo-SecureString "Welcome10" -AsPlainText -Force) `
            -ErrorAction Stop
          Write-NamLog -Level "INFO" -Function "New-ADUser" -LogFile $LogFile -Message "Creating user with UserPrincipalName $UserPrincipalname : Succeed"
        }
        catch {
          Write-NamLog -Level "ERROR" -Function "New-ADUser" -LogFile $LogFile -Message "FAILED - Create user $UserPrincipalname - $($_.Exception.Message)"
          $createState = $false
          Continue  
        }
        if ($true -eq $createState) {
          # Done AD user creation

          # Organization information to set for created user
          $Title = $user.Title
          $Department = $user.Department
          $Company = $user.Company
          $Manager = $user.Manager
          $Office = $user.Location
          $StreetAddress = $user.Address
          $City = $user.Region
          $PostalCode = $user.PostalCode
          $Country = $user.Country

          # Check if user exist yet
          if ($null -eq (Get-ADUser -filter { UserPrincipalname -eq $UserPrincipalName })) {
            Write-NamLog -Level "WARN" -Function "Get-ADUser" -LogFile $LogFile -Message "Can't find user with UserPrincipalname $UserPrincipalName"
            Continue
          }
          elseif ($null -eq (Get-ADUser -filter { SamAccountName -eq $SamAccountName })) {
            Write-NamLog -Level "WARN" -Function "Get-ADUser" -LogFile $LogFile -Message "Can't find user with SamAccountName $SamAccountName"
            Continue
          }
          elseif ($null -eq (Get-ADUser -filter { Name -eq $Name })) {
            Write-NamLog -Level "WARN" -Function "Get-ADUser" -LogFile $LogFile -Message "Can't find user with Name $Name"
            Write-NamLog -Level "ERROR" -Function "Set-ADUser" -LogFile $LogFile -Message "Can't find user $UserPrincipalName to set organization info"
            Continue
          }
          else {
            Write-NamLog -Level "INFO" -Function "Get-ADUser" -LogFile $LogFile -Message "Found user $UserPrincipalName, Setting user's organization info"

            # Check if manager exist
            if ($null -eq (Get-ADUser -filter { SamAccountName -eq $Manager })) {
              Write-NamLog -Level "ERROR" -Function "Get-ADUser" -LogFile $LogFile -Message "Can't find manager with SamAccountName $SamAccountName"
              Continue
            }
            else {
              # Manager exist continue the script
              Write-NamLog -Level "INFO" -Function "Get-ADUser" -LogFile $LogFile -Message "Found manager with SamAccountName $Manager"

              # Set user organization info
              try {
                Write-NamLog -Level "INFO" -Function "Set-ADUser" -LogFile $LogFile -Message "Setting organization information for user with UserPrincipalName $UserPrincipalname"
                Set-ADUser `
                  -Identity $SamAccountName `
                  -Title $Title `
                  -Department $Department `
                  -Company $Company `
                  -Manager $Manager `
                  -Office $Office `
                  -StreetAddress $StreetAddress `
                  -City $City `
                  -PostalCode $PostalCode `
                  -Country $Country `
                  -ErrorAction Stop
                Write-NamLog -Level "INFO" -Function "Set-ADUser" -LogFile $LogFile -Message "Set organization user with UserPrincipalName $UserPrincipalname : Succeed"
              }
              catch {
                Write-NamLog -Level "ERROR" -Function "Set-ADUser" -LogFile $LogFile -Message "FAILED : Set organization information for user with UserPrincipalName $UserPrincipalname - $($_.Exception.Message)"
                Continue
              }  
            }
          }
        }
        else {
          Write-NamLog -Level "ERROR" -Function "Set-ADUser" -LogFile $LogFile -Message "STOP modifying organization info - because Create user $SamAccountName Failed "
          Continue
        }
      }
    }
  }
}

function Export-NamCsvFile {
  param (
    <#
      Output file path.
      If the file not exist yet, a new file will be created.
      Can be relative or absolute path.
    #>
    [Parameter(Mandatory)]
    [String]
    $Path
  )
  
}


# Write log function
Function Write-NamLog {
  [CmdletBinding()]
  Param(
    [ValidateSet("INFO", "WARN", "ERROR")]
    [String]
    $Level = "INFO",

    [string]
    $Function,

    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [string]
    $Message,

    [Alias("FilePath", "Path")]
    [string]
    $LogFile
  )

  $Stamp = (Get-Date).toString("yyyy-MM-dd HH:mm:ss")
  $LogProperties = [PSCustomObject]@{
    TimeStamp = $Stamp
    User      = "$env:USERDOMAIN\$env:USERNAME"
    Function  = $Function
    Level     = $Level
    Message   = $Message
  }

  $Line = "$($LogProperties.TimeStamp) - $($LogProperties.User) - [$($LogProperties.Function)] - [$($LogProperties.Level)] - $($LogProperties.Message)"

  If ($LogFile -ne '') {
    $Line | Add-Content -Path $LogFile -Force
    Write-Verbose $Line
  }
  Else {
    Write-Verbose $Line
  }
}
