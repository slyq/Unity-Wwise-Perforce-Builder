Get-Content .env | foreach {
  $name, $value = $_.split('=')
  if ([string]::IsNullOrWhiteSpace($name) -or $name.Contains('#')) {
    continue
  }
  New-Variable -Name "$name" -Value $value
}
docker cp unity-builder-jenkins-1:/var/jenkins_home/Unity/Hub/Editor/"$VERSION"/Editor/Unity_v"$VERSION".alf $env:USERPROFILE\Downloads\Unity_v"$VERSION".alf