function importCsvFile {
  param (
    $Path
  )
  try {
    Import-Csv -Path $Path
  }
  catch {
    throw "What the Fuck"
  }
}