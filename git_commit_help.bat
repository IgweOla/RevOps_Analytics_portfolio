@echo off
REM Usage: git_commit_help.bat "relative\path\to\file" "Commit message"
if "%~1"=="" (
  echo Please provide the file path to commit.
  exit /b 1
)
if "%~2"=="" (
  echo Please provide a commit message.
  exit /b 1
)

set FILE=%~1
set MSG=%~2

REM Backup and untrack .env if it exists
if exist ".env" (
  echo Backing up .env to ..\env_backup.env
  copy /Y ".env" "..\env_backup.env" >nul
  echo Removing .env from git index (keeping local file)
  git rm --cached ".env" 2>nul
  findstr /I /C:".env" ".gitignore" >nul 2>nul
  if errorlevel 1 echo .env>>".gitignore"
  git add ".gitignore"
  git commit -m "Stop tracking .env and ignore it" 2>nul || echo ".gitignore change already committed or no change"
)

REM Stage and commit the requested file
git add "%FILE%"
if errorlevel 1 (
  echo git add failed. Check the file path: %FILE%
  exit /b 1
)

git commit -m "%MSG%"
if errorlevel 1 (
  echo git commit failed. Resolve any merge conflicts (git status) then run this script again.
  exit /b 1
)

echo Pushing to origin...
git push
if errorlevel 1 (
  echo git push failed. Check remote/authentication.
  exit /b 1
)

echo Done: committed %FILE% and pushed.
