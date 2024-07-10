Write-Host "Remove unnecessary packages"

$packages = @(
  "7EE7776C.LinkedInforWindows",
  "Clipchamp.Clipchamp",
  "Disney.37853FC22B2CE",
  "Microsoft.549981C3F5F10",
  "Microsoft.BingNews",
  "Microsoft.BingWeather",
  "Microsoft.GamingApp",
  "Microsoft.GetHelp",
  "Microsoft.Getstarted",
  "Microsoft.MicrosoftOfficeHub",
  "Microsoft.MicrosoftSolitaireCollection",
  "Microsoft.MicrosoftStickyNotes",
  "Microsoft.OutlookForWindows",
  "Microsoft.People",
  "Microsoft.Todos",
  "Microsoft.Windows.DevHome",
  "Microsoft.Windows.Photos",
  "Microsoft.WindowsAlarms",
  "Microsoft.WindowsCamera",
  "Microsoft.WindowsFeedbackHub",
  "Microsoft.WindowsMaps",
  "Microsoft.WindowsSoundRecorder",
  "Microsoft.YourPhone",
  "Microsoft.ZuneMusic",
  "Microsoft.ZuneVideo",
  "MicrosoftCorporationII.MicrosoftFamily",
  "MicrosoftCorporationII.QuickAssist",
  "MicrosoftTeams",
  "MicrosoftWindows.Client.WebExperience",
  "SpotifyAB.SpotifyMusic",
  "microsoft.windowscommunicationsapps"
)

foreach ($package in $packages) {
  Write-Host "Remove: $package"
  Get-AppxPackage $package | Remove-AppxPackage
}
