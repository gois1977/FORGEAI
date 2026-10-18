# Creates the Git repository and pushes it to your GitHub (Windows PowerShell).
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Write-Host "Install Git first: https://git-scm.com/downloads"; exit 1 }

$GhUser = Read-Host "GitHub username"
$Repo = Read-Host "Repository name [forge-app-builder]"; if (-not $Repo) { $Repo = "forge-app-builder" }
$Vis = Read-Host "Visibility (public/private) [public]"; if (-not $Vis) { $Vis = "public" }

if (-not (Test-Path ".git")) { git init -q; git symbolic-ref HEAD refs/heads/main }
if (-not (git config user.email)) {
  $Mail = Read-Host "Your e-mail for Git commits"
  git config user.email $Mail; git config user.name $GhUser
}
git add .
git commit -m "Initial commit: Forge AI app builder"
if ($LASTEXITCODE -ne 0) { Write-Host "(nothing new to commit)" }

$HasGh = (Get-Command gh -ErrorAction SilentlyContinue) -ne $null
if ($HasGh) { gh auth status *> $null; $HasGh = ($LASTEXITCODE -eq 0) }

if ($HasGh) {
  gh repo create $Repo "--$Vis" --source=. --remote=origin --push
} else {
  git remote remove origin 2>$null
  git remote add origin "https://github.com/$GhUser/$Repo.git"
  Write-Host ""
  Write-Host "Create an EMPTY repository named '$Repo' at https://github.com/new"
  Write-Host "(do NOT add a README, .gitignore or license), then press Enter."
  Read-Host | Out-Null
  git push -u origin main
}

Write-Host ""
Write-Host "Done. Enable the site: Settings > Pages > Deploy from a branch > main / (root)"
Write-Host "Your app will be at: https://$GhUser.github.io/$Repo/"
