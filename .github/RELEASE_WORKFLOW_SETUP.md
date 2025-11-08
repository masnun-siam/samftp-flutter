# GitHub Release Workflow Setup

This document explains how to set up the automated release workflow for building and publishing APK files.

## Overview

The workflow automatically:
1. Builds a signed release APK when code is pushed to the `main` branch
2. Creates a GitHub release with automatic version tagging
3. Uploads the APK to the release
4. Generates changelog from commit messages

## Required GitHub Secrets

You need to add the following secrets to your GitHub repository:

### 1. KEYSTORE_FILE

This is your `key.jks` file encoded in base64.

**To create this secret:**

```bash
# Navigate to your keystore file location
cd path/to/your/keystore

# Encode the keystore file to base64
base64 -w 0 key.jks > keystore_base64.txt

# On macOS, use:
base64 -i key.jks -o keystore_base64.txt
```

Copy the contents of `keystore_base64.txt` and add it as a secret named `KEYSTORE_FILE`.

### 2. KEYSTORE_PASSWORD

The password for your keystore file (storePassword).

### 3. KEY_ALIAS

The alias of the key in your keystore.

### 4. KEY_PASSWORD

The password for the key alias.

## How to Add Secrets to GitHub

1. Go to your GitHub repository
2. Click on **Settings**
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Add each secret with the exact names listed above

## Workflow Behavior

### Triggering a Release

The workflow triggers automatically on every push to the `main` branch.

### Version Tagging

- The workflow reads the version from `pubspec.yaml` (e.g., `1.0.0+1`)
- Creates a git tag in the format `vX.Y.Z` (e.g., `v1.0.0`)
- If a tag already exists, it appends `-buildN` (e.g., `v1.0.0-build1`)

### Changelog Generation

The workflow automatically generates a changelog from commit messages since the last tag.

### APK Naming

The APK is named: `samftp-vX.Y.Z.apk` (e.g., `samftp-v1.0.0.apk`)

## Updating the Version

To create a new release with a new version:

1. Update the `version` field in `pubspec.yaml`:
   ```yaml
   version: 1.1.0+2
   ```

2. Commit and push to `main`:
   ```bash
   git add pubspec.yaml
   git commit -m "chore: bump version to 1.1.0"
   git push origin main
   ```

3. The workflow will automatically build and create a release with tag `v1.1.0`

## Testing the Workflow

Before pushing to `main`, you can test the build locally:

```bash
# Create a test key.properties file
echo "storePassword=YOUR_STORE_PASSWORD" > android/key.properties
echo "keyPassword=YOUR_KEY_PASSWORD" >> android/key.properties
echo "keyAlias=YOUR_KEY_ALIAS" >> android/key.properties
echo "storeFile=../key.jks" >> android/key.properties

# Build the APK
flutter build apk --release

# Clean up
rm android/key.properties
```

## Security Notes

- **Never commit** `key.jks` or `key.properties` files to the repository
- These files should be in `.gitignore`
- The workflow creates these files temporarily during build and removes them afterward
- All sensitive data is stored securely in GitHub Secrets

## Troubleshooting

### Build Fails with "keystore not found"

- Verify that `KEYSTORE_FILE` secret is correctly base64 encoded
- Check that the base64 encoding doesn't have line breaks (use `-w 0` flag)

### Build Fails with "signing configuration error"

- Verify all four secrets are set correctly
- Check that `KEY_ALIAS` matches the alias in your keystore
- Verify passwords are correct

### Release Already Exists

If you push multiple times without changing the version in `pubspec.yaml`, the workflow will append `-buildN` to the tag to avoid conflicts.

## Manual Release Creation

If you need to create a release manually, you can use the GitHub CLI:

```bash
gh release create v1.0.0 \
  build/app/outputs/flutter-apk/app-release.apk \
  --title "Release v1.0.0" \
  --notes "Release notes here"
```
