Write-Host "Remove unnecessary packages"

$packages = @(
  "Clipchamp.Clipchamp",
  "Disney.37853FC22B2CE",
  "Microsoft.549981C3F5F10",
  "Microsoft.BingWeather",
  "Microsoft.GamingApp ",
  "Microsoft.Getstarted",
  "Microsoft.MicrosoftOfficeHub",
  "Microsoft.MicrosoftSolitaireCollection",
  "Microsoft.MicrosoftStickyNotes",
  "Microsoft.Todos",
  "Microsoft.Windows.Photos",
  "Microsoft.WindowsAlarms",
  "Microsoft.WindowsCamera",
  "Microsoft.WindowsFeedbackHub",
  "Microsoft.WindowsMaps",
  "Microsoft.WindowsSoundRecorder",
  "Microsoft.YourPhone",
  "Microsoft.ZuneMusic",
  "Microsoft.ZuneVideo",
  "MicrosoftTeams",
  "SpotifyAB.SpotifyMusic",
  "microsoft.windowscommunicationsapps"
)

foreach ($package in $packages) {
  Write-Host "Remove: $package"
  Get-AppxPackage $package | Remove-AppxPackage
}
