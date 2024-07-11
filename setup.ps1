Write-Host "Remove unnecessary packages"

$unnecessaryPackages = @(
  "7EE7776C.LinkedInforWindows",
  "Clipchamp.Clipchamp",
  "Disney.37853FC22B2CE",
  "Microsoft.549981C3F5F10",
  "Microsoft.BingNews",
  "Microsoft.BingWeather",
  "Microsoft.GamingApp",
  "Microsoft.GetHelp",
  "Microsoft.Getstarted",
  "Microsoft.Microsoft3DViewer",
  "Microsoft.MicrosoftOfficeHub",
  "Microsoft.MicrosoftSolitaireCollection",
  "Microsoft.MicrosoftStickyNotes",
  "Microsoft.MixedReality.Portal",
  "Microsoft.OutlookForWindows",
  "Microsoft.People",
  "Microsoft.Print3D",
  "Microsoft.SkypeApp",
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

foreach ($unnecessaryPackage in $unnecessaryPackages) {
  Write-Host "Remove: $unnecessaryPackage"
  Get-AppxPackage $unnecessaryPackage | Remove-AppxPackage
}

$wingetPackages = @(
  "AgileBits.1Password",
  "ElectronicArts.EADesktop",
  "Mozilla.Firefox.DeveloperEdition",
  "RiotGames.Valorant.AP",
  "Valve.Steam"
)

if (Get-Command -Name winget -ErrorAction SilentlyContinue)
{
  foreach ($wingetPackage in $wingetPackages) {
    Write-Host "Install: $wingetPackage"
    winget install -e --id  $wingetPackage
  }
}