Get-Content .env | foreach {
  $name, $value = $_.split('=')
  if ([string]::IsNullOrWhiteSpace($name) -or $name.Contains('#')) {
    continue
  }
  New-Variable -Name "$name" -Value $value
}
if (Test-Path $env:USERPROFILE\Downloads\Unity_v"$VERSION".ulf) {
    $FILENAME = "Unity_v$VERSION.ulf"
} elseif (($Year = $VERSION.Split(".")[0]) -match "^\d{4}$") {
    # assume default download name
    $FILENAME = "Unity_v$Year.x.ulf"
} else {
    $FILENAME = Read-Host "Type the full name of the ULF file in your Downloads folder (ex: Unity_v2022.x.ulf)"
    if (-Not (Test-Path $env:USERPROFILE\Downloads\"$FILENAME")) {
        Write-Host "File path is invalid!"
        exit
    }
}
docker cp $env:USERPROFILE\Downloads\"$FILENAME" unity-builder-jenkins-1:/var/jenkins_home/Unity/Hub/Editor/"$VERSION"/Editor/"$FILENAME"