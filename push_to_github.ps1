# Push Flutter app to GitHub
Set-Location 'c:\Study\2026-1st\android app\apiu bulletin\https---github.com-Niu-Boen-apiu-church-bulltin'

Write-Host "Initializing git repository..."
git init

Write-Host "Adding all files..."
git add .

Write-Host "Configuring git user..."
git config user.email "admin@apiu.edu"
git config user.name "Niu Boen"

Write-Host "Committing changes..."
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
- Resolved type casting issues in history screen
"

Write-Host "Setting up remote repository..."
git remote add origin https://github.com/Asia-Pacific-International-university/aiu-church-api-Niu-Boen.git

Write-Host "Renaming branch to main..."
git branch -M main

Write-Host "Pushing to GitHub..."
git push -u origin main

Write-Host "Done!"
