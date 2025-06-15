# GitHub Actions Setup for Firebase Deployment

This document provides instructions for setting up GitHub Actions to deploy your Sport BI System to Firebase Hosting.

## Prerequisites

Before you begin, make sure you have:

1. A GitHub repository for your project
2. A Firebase project (already configured in your app)
3. Firebase CLI installed locally (for generating deployment token)

## Setup Instructions

### 1. Generate Firebase Token for CI/CD

You'll need to generate a Firebase token that GitHub Actions can use for deployment:

```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Generate CI token
firebase login:ci
```

This will open a browser for authentication and then return a token. Copy this token.

### 2. Add Firebase Token to GitHub Secrets

1. Go to your GitHub repository
2. Click on "Settings" > "Secrets and variables" > "Actions"
3. Click on "New repository secret"
4. Name: `FIREBASE_TOKEN`
5. Value: [Paste the token you generated]
6. Click "Add secret"

### 3. Push Your Code to GitHub

Make sure your repository includes:

- All your Flutter app code
- The `.github/workflows/firebase-hosting-deploy.yml` file
- `firebase.json` configuration file
- `package.json` and `package-lock.json` files

### 4. Monitor Deployment

After pushing your code:

1. Go to your GitHub repository
2. Click on the "Actions" tab
3. You should see your workflow running
4. Once complete, your app will be deployed to Firebase Hosting

## Troubleshooting

### Common Issues:

1. **Missing package-lock.json**: 
   - Error: "The job failed because the npm ci command requires a package-lock.json"
   - Solution: Generate with `npm install --package-lock-only`

2. **Invalid Firebase Token**:
   - Error: "Firebase CLI Error: Authentication Error"
   - Solution: Generate a new token and update the GitHub Secret

3. **Build Errors**:
   - Check the workflow logs for specific Flutter build issues
   - Make sure your Flutter app builds successfully locally first

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)
- [Firebase GitHub Action](https://github.com/FirebaseExtended/action-hosting-deploy)
