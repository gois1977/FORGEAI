#!/usr/bin/env bash
# Creates the Git repository and pushes it to your GitHub (macOS / Linux / Git Bash).
set -e
cd "$(dirname "$0")"
command -v git >/dev/null || { echo "Install Git first: https://git-scm.com/downloads"; exit 1; }

read -rp "GitHub username: " GH_USER
read -rp "Repository name [forge-app-builder]: " REPO; REPO=${REPO:-forge-app-builder}
read -rp "Visibility (public/private) [public]: " VIS; VIS=${VIS:-public}

[ -d .git ] || { git init -q; git symbolic-ref HEAD refs/heads/main; }
if [ -z "$(git config user.email)" ]; then
  read -rp "Your e-mail for Git commits: " GH_MAIL
  git config user.email "$GH_MAIL"; git config user.name "$GH_USER"
fi
git add .
git commit -m "Initial commit: Forge AI app builder" || echo "(nothing new to commit)"

if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
  gh repo create "$REPO" "--$VIS" --source=. --remote=origin --push
else
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/$GH_USER/$REPO.git"
  echo
  echo "Create an EMPTY repository named '$REPO' at https://github.com/new"
  echo "(do NOT add a README, .gitignore or license), then press Enter."
  read -r _
  git push -u origin main
fi

echo
echo "Done. Enable the site: Settings > Pages > Deploy from a branch > main / (root)"
echo "Your app will be at: https://$GH_USER.github.io/$REPO/"
