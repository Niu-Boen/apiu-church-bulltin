@echo off
cd /d "c:\Study\2026-1st\android app\apiu bulletin\https---github.com-Niu-Boen-apiu-church-bulltin"

echo Initializing git repository...
git init

echo Adding all files...
git add .

echo Committing changes...
git commit -m "Initial commit: AIU Church Bulletin Flutter App

- Complete Flutter mobile app for church bulletin viewing
- Authentication with JWT tokens
- Home screen with latest bulletin display
- History screen with saved bulletins
- User profile management
- Admin features for managing users
- Sunset calculator integration
- Beautiful UI with modern design
- Fixed lint errors and import paths
"

echo Setting up remote repository...
git remote add origin https://github.com/Asia-Pacific-International-university/aiu-church-api-Niu-Boen.git

echo Pushing to GitHub...
git push -u origin main

echo Done!
pause
