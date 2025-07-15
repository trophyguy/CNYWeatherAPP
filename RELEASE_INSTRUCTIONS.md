# How to Upload APK to GitHub Release

## Method 1: Using the PowerShell Script (Recommended)

1. **Get a GitHub Personal Access Token:**
   - Go to [GitHub.com](https://github.com) and sign in
   - Click your profile picture → Settings
   - Scroll down to "Developer settings" (bottom left)
   - Click "Personal access tokens" → "Tokens (classic)"
   - Click "Generate new token" → "Generate new token (classic)"
   - Give it a name like "CNY Weather App Release"
   - Select the "repo" permission (this gives full access to your repositories)
   - Click "Generate token"
   - **Copy the token immediately** (you won't see it again!)

2. **Run the upload script:**
   ```powershell
   .\upload_apk_to_github.ps1 -GitHubToken "your_token_here"
   ```

3. **The script will:**
   - Create a release for tag v1.2.0
   - Upload the APK file
   - Provide you with download links

## Method 2: Manual Upload via GitHub Web Interface

1. **Go to your repository on GitHub:**
   - Visit: https://github.com/trophyguy/CNYWeatherAPP

2. **Create a new release:**
   - Click on "Releases" in the right sidebar
   - Click "Create a new release"
   - Select the tag "v1.2.0" (should already exist)
   - Set the release title: "CNY Weather App v1.2.0"

3. **Add release notes:**
   ```
   ## CNY Weather App v1.2.0

   ### New Features:
   - Weather alerts and notifications
   - Improved UI and user experience
   - Enhanced weather data handling
   - Better error handling and caching

   ### Installation:
   Download the APK file below and install it on your Android device.

   ### Requirements:
   - Android 5.0 (API level 21) or higher
   - Internet connection for weather data
   - Location permissions for local weather

   ### Changes in this version:
   - Added weather alert notifications
   - Improved forecast display
   - Enhanced settings screen
   - Better handling of weather advisories
   - Updated dependencies and security patches
   ```

4. **Upload the APK:**
   - Drag and drop the `app-arm64-v8a-backup-release.apk` file into the "Attach binaries" section
   - Or click "Attach binaries" and select the file

5. **Publish the release:**
   - Click "Publish release"

## Current Status

✅ **Code committed and pushed to GitHub**
✅ **Tag v1.2.0 created and pushed**
⏳ **Ready for APK upload**

## Next Steps

1. Choose either Method 1 or Method 2 above
2. Upload the APK file
3. Share the release URL with users

## Release URL

Once uploaded, your release will be available at:
https://github.com/trophyguy/CNYWeatherAPP/releases/tag/v1.2.0

## Troubleshooting

- **If the script fails:** Make sure your GitHub token has "repo" permissions
- **If the APK is too large:** GitHub has a 100MB limit for individual files
- **If you get authentication errors:** Double-check your token is correct 