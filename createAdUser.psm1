function Create-NamBulkAdUser {

  [CmdletBinding()]
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
      # Check if file extension is .csv
      if ([IO.Path]::GetExtension($Path) -eq ".csv") {
        # Import Csv file
        try {
          Write-NamLog -Level "INFO" -logfile $LogFile -Message "Importing Csv: $Path"
          $ImportCsv = Import-Csv -path $Path -ErrorAction Stop -ErrorVariable ErrLog
          Write-NamLog -Level "INFO" -logfile $LogFile -Message "Imported Csv: $Path"
        }
        catch {
          $ErrLog = ($Error[0]).Exception
          Write-NamLog -Level "ERROR" -logfile $LogFile -Message $ErrLog
          Break
        }
      }
      else {
        Write-NamLog -Level "ERROR" -LogFile $LogFile -Message "Filetype: Is not .csv"
        Break
      }
    }
    else {
      Write-NamLog -Level "ERROR" -LogFile $LogFile -Message "$Path do not exist"
      Break
    }


  }
}

Function Write-NamLog {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $False)]
    [ValidateSet("INFO", "WARN", "ERROR", "FATAL", "DEBUG")]
    [String]
    $Level = "INFO",

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

  $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
  $Line = [PSCustomObject]@{
    TimeStamp = $Stamp
    Level     = $Level
    Message   = $Message
  }
  If ($LogFile) {
    $Line | Export-Csv -Path $LogFile -Append -Force -NoTypeInformation
  }
  Else {
    Write-Output $Line
  }
}