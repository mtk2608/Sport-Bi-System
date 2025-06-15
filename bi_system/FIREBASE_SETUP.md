# Sport BI System - Firebase Setup

## Firebase Configuration

To complete the Firebase setup for authentication, follow these steps:

### 1. Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: "sport-bi-system"
4. Follow the setup wizard

### 2. Enable Authentication
1. In your Firebase project, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" provider

### 3. Configure Firebase for Flutter (Windows PowerShell)
1. Install Firebase CLI: `powershell -ExecutionPolicy Bypass -Command "npm install -g firebase-tools"`
2. Install FlutterFire CLI: `powershell -ExecutionPolicy Bypass -Command "dart pub global activate flutterfire_cli"`
3. Login to Firebase: `powershell -ExecutionPolicy Bypass -Command "firebase login"`

   **To make FlutterFire commands work directly:**
   
   Add the Dart pub cache bin directory to your PATH by running this in PowerShell (as Administrator):
   ```
   [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";$env:USERPROFILE\AppData\Local\Pub\Cache\bin", "User")
   ```
   Then restart your terminal. After this, you should be able to run `flutterfire` commands directly.

   **If you can't modify PATH, use the full path instead:**
   ```
   $env:USERPROFILE\AppData\Local\Pub\Cache\bin\flutterfire.bat configure --project=sport-bi-system
   ```

4. Run FlutterFire configure: `powershell -ExecutionPolicy Bypass -Command "$env:USERPROFILE\AppData\Local\Pub\Cache\bin\flutterfire.bat configure --project sport-bi-system"`

**Note:** If you receive PowerShell execution policy errors, use the `-ExecutionPolicy Bypass` flag as shown above. The FlutterFire CLI gets installed at `%USERPROFILE%\AppData\Local\Pub\Cache\bin\`, which may not be in your PATH by default.

### 4. Firebase Options
After running the FlutterFire configure command, the CLI should automatically create or update the `lib/firebase_options.dart` file with your specific Firebase configuration. This file contains the necessary API keys, app IDs, and other configuration options.

If you need to manually update any values in `lib/firebase_options.dart`, you can find your Firebase project's configuration in the Firebase Console:

1. Open your project in the [Firebase Console](https://console.firebase.google.com/)
2. Click on the gear icon (⚙️) in the top left and select "Project settings"
3. Scroll down to "Your apps" section where you can find configuration details

### 5. Enable Firestore (Optional)
1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode"
4. Select a location

## Features Implemented

### Authentication
- ✅ Email/Password Sign In
- ✅ Email/Password Sign Up
- ✅ Password Reset
- ✅ User Profile Creation in Firestore
- ✅ Authentication State Management
- ✅ Sign Out Functionality

### UI Components
- ✅ Modern Sign In Page
- ✅ Modern Sign Up Page
- ✅ Form Validation
- ✅ Loading States
- ✅ Error Handling
- ✅ Auth State Wrapper

### Integration
- ✅ Firebase Auth Service
- ✅ Firestore User Documents
- ✅ Sidebar Sign Out Option
- ✅ Protected Route Navigation

## Usage

1. **Sign Up**: New users can create accounts with email/password
2. **Sign In**: Existing users can log in with their credentials
3. **Password Reset**: Users can reset passwords via email
4. **Auto Navigation**: Users are automatically redirected based on auth state
5. **Sign Out**: Users can sign out from the sidebar menu

## File Structure

```
lib/
├── services/
│   └── auth_service.dart          # Firebase Auth service
├── pages/
│   ├── sign_in_page.dart         # Sign in UI
│   ├── sign_up_page.dart         # Sign up UI
│   └── homepage.dart             # Main dashboard
├── widgets/
│   ├── auth_wrapper.dart         # Auth state management
│   └── collapsible_sidebar.dart  # Sidebar with sign out
├── firebase_options.dart         # Firebase configuration
└── main.dart                     # App entry point
```

## Next Steps

1. Set up your Firebase project
2. Run `flutterfire configure` with appropriate parameters
3. Verify that `firebase_options.dart` was created correctly
4. Test the authentication flow
5. Customize the UI as needed

## Troubleshooting

### Common Issues

1. **PowerShell Execution Policy**: If you encounter execution policy errors, use the `-ExecutionPolicy Bypass` flag as shown in the commands.

2. **FlutterFire CLI Not Found** (`flutterfire: command not found`): This happens because the FlutterFire CLI is installed in `%USERPROFILE%\AppData\Local\Pub\Cache\bin\`, which is not in your PATH. You have two options:

   - **Option 1 (Quick)**: Use the full path to the executable:
     ```
     $env:USERPROFILE\AppData\Local\Pub\Cache\bin\flutterfire.bat configure --project=sport-bi-system
     ```

   - **Option 2 (Permanent)**: Add the Dart pub cache bin to your PATH:
     1. Open PowerShell as Administrator
     2. Run:
        ```
        [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";$env:USERPROFILE\AppData\Local\Pub\Cache\bin", "User")
        ```
     3. Close and reopen PowerShell
     4. Now you can run `flutterfire` commands directly

3. **Firebase Project Not Found**: Ensure you've created a project in Firebase Console and are using the correct project ID with the `--project` flag.

4. **Firebase Configuration Not Generated**: If the `firebase_options.dart` file isn't generated automatically, check that:
   - You're in the root directory of your Flutter project
   - Your authentication to Firebase is successful
   - You have selected the correct Firebase project

## Security Rules (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own documents
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```
