# Setup for new Ubuntu, macOS, and Windows

## For Ubuntu or macOS

```
git clone https://github.com/LamiumAmplexicaule/Setup
cd Setup && bash ./setup.sh
```

## For Windows

```
Set-ExecutionPolicy RemoteSigned -Scope Process; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/LamiumAmplexicaule/Setup/main/setup.ps1"))
```