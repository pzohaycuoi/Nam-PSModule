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
    $LogFile = ".\namModule.log"  
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
        Write-NamLog -Level "ERROR" -Function "New-ADUser" -LogFile $LogFile -Message "User is already exist, stop creating user with UserPrincipalName $UserPrincipalName"
        Continue
      } 
      elseif ($null -ne (Get-ADUser -filter { SamAccountName -eq $SamAccountName })) {
        Write-NamLog -Level "ERROR" -Function "New-ADUser" -LogFile $LogFile -Message "User is already exist, stop creating user with SamAccountName $SamAccountName"
        Continue
      } 
      elseif ($null -ne (Get-ADUser -filter { Name -eq $Name })) {
        Write-NamLog -Level "ERROR" -Function "New-ADUser" -LogFile $LogFile -Message "User is already exist, stop creating user with Name $Name"
        Continue
      } 
      elseif ($null -eq (Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $OuPath })) {
        Write-NamLog -Level "ERROR" -Function "New-ADUser" -LogFile $LogFile -Message "OUpath $OuPath is not exist, stop stop creating user $UserPrincipalName"
        Continue
      }
      else {
        # If not exist then create user with basic information
        try {
          Write-NamLog -Level "INFO" -Function "Create-ADUser" -LogFile $LogFile -Message "Creating user with UserPrincipalName $UserPrincipalname"
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
          Write-NamLog -Level "INFO" -Function "Create-ADUser" -LogFile $LogFile -Message "Creating user with UserPrincipalName $UserPrincipalname : Succeed"
        }
        catch {
          Write-NamLog -Level "ERROR" -Function "Create-ADUser" -LogFile $LogFile -Message "Create user with UserPrincipalName $UserPrincipalname : Failed"
          Continue  
        }
      }
      # Done AD user creation
      # Set user department's info
    }
  }
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
  If ($LogFile) {
    $Line | Add-Content -Path $LogFile -Force
    Write-Verbose $Line
  }
  Else {
    Write-Output $Line
  }
}
