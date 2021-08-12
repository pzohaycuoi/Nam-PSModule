function Create-NamBulkAdUser {

  [CmdletBinding(SupportsShouldProcess = $true)]
  param (
    # Path to csv file
    [Parameter(Mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      HelpMessage = 'Enter path to Csv file')]
    [Alias("FilePath", "P")]
    [string]
    $Path,

    # Logging file location
    [string]
    $LogFile = $null
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
      $ErrLog = ($Error[0]).Exception
      Write-NamLog -Level "ERROR" -Function "Import-Csv" -LogFile $LogFile -Message $ErrLog
      Break
    }

    # Check header of csv file
    $CsvHeader = $ImportCsv[0].PsObject.Properties.Name
    $RequiredHeader = @("SamAccountName", "UPN", "OuPath", "FirstName", "LastName")
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
      $Name = "$($user.FirstName),$($user.LastName)"
      $DisplayName = "$($user.FirstName),$($user.LastName)"

      # Check if user exist yet
      if ($null -ne (Get-ADUser -filter { UserPrincipalname -eq $UserPrincipalName })) {
        Write-NamLog -Level "ERROR" -Function "Get-ADUser" -LogFile $LogFile -Message "User is already exist, stop creating user with UserPrincipalName $UserPrincipalName"
        Continue
      } 
      elseif ($null -ne (Get-ADUser -filter { SamAccountName -eq $SamAccountName })) {
        Write-NamLog -Level "ERROR" -Function "Get-ADUser" -LogFile $LogFile -Message "User is already exist, stop creating user with SamAccountName $SamAccountName"
        Continue
      } 
      elseif ($null -ne (Get-ADUser -filter { Name -eq $Name })) {
        Write-NamLog -Level "ERROR" -Function "Get-ADUser" -LogFile $LogFile -Message "User is already exist, stop creating user with Name $Name"
        Continue
      } 
      elseif ($null -eq (Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $OuPath })) {
        Write-NamLog -Level "ERROR" -Function "Get-ADUser" -LogFile $LogFile -Message "OUpath $OuPath is not exist, stop stop creating user $UserPrincipalName"
        Continue
      }
      else {
        # If not exist then create user with basic information
        try {
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
            -ErrorAction SilentlyContinue -ErrorVariable ErrLog
          $ErrLog
          Write-NamLog -Level "INFO" -Function "New-ADUser" -LogFile $LogFile -Message "Creating user with UserPrincipalName $UserPrincipalname : Succeed"
        }
        catch {
          Write-NamLog -Level "ERROR" -Function "New-ADUser" -LogFile $LogFile -Message "FAILED - Create user $UserPrincipalname - $ErroLog"
          Continue  
        }
        # Done AD user creation

        Organization information to set for created user
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
            Write-NamLog -Level "INFO" -Function "Get-ADUser" -LogFile $LogFile -Message "Found manager with SamAccountName $SamAccountName"

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
              Write-NamLog -Level "ERROR" -Function "Set-ADUser" -LogFile $LogFile -Message "Set organization information for user with UserPrincipalName $UserPrincipalname : FAILED"
              Continue
            }  
          }
        }
      }
    }
  }
}

function Import-NamCsvAdCreateBulkAdUser {
  param (
  )
  
}


# Write log function
Function Write-NamLog {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $False)]
    [ValidateSet("INFO", "WARN", "ERROR")]
    [String]
    $Level = "INFO",

    [Parameter(Mandatory = $False)]
    [string]
    $Function,

    [Parameter(Mandatory = $True,
      ValueFromPipeline = $True,
      ValueFromPipelineByPropertyName = $True)]
    [string]
    $Message,

    [Parameter(Mandatory = $False)]
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
