# 🍎 Apple App Store Setup Guide

## Step 1: Get an Apple Developer Account

1. Go to https://developer.apple.com/programs/
2. Sign up ($99/year)
3. Wait for approval (usually 24-48 hours)

## Step 2: Create Signing Certificate & Provisioning Profile

### On any Mac (or rent one temporarily):

```bash
# 1. Create a Certificate Signing Request (CSR)
#    Open Keychain Access → Certificate Assistant → Request a Certificate From a Certificate Authority
#    Save to disk as CertificateSigningRequest.certSigningRequest

# 2. Go to https://developer.apple.com/account/resources/certificates/add
#    Choose "Apple Distribution" certificate
#    Upload the CSR
#    Download the .cer file

# 3. Double-click the .cer to install in Keychain
#    Then export as .p12:
#    Keychain Access → My Certificates → Right-click → Export
#    Save as distribution.p12 (set a password)

# 4. Create an App ID at:
#    https://developer.apple.com/account/resources/identifiers/add
#    Bundle ID: com.gentoondar.app

# 5. Create a Provisioning Profile at:
#    https://developer.apple.com/account/resources/profiles/add
#    Type: App Store Distribution
#    App ID: com.gentoondar.app
#    Download the .mobileprovision file
```

## Step 3: Create App Store Connect API Key

1. Go to https://appstoreconnect.apple.com/access/integrations/api
2. Click "Generate API Key"
3. Name: "Gentoondar CI"
4. Access: "App Manager"
5. Download the .p8 key file
6. Note the **Key ID** and **Issuer ID**

## Step 4: Add Secrets to GitHub

Go to: https://github.com/ainews1/gentoondar/settings/secrets/actions

Add these repository secrets:

| Secret Name | Value | How to get it |
|-------------|-------|---------------|
| `IOS_P12_BASE64` | Base64 of your .p12 certificate | `base64 -i distribution.p12` |
| `IOS_P12_PASSWORD` | Password you set when exporting .p12 | The password you chose |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 of .mobileprovision | `base64 -i profile.mobileprovision` |
| `IOS_KEYCHAIN_PASSWORD` | Any random password | `openssl rand -hex 16` |
| `APP_STORE_CONNECT_KEY_ID` | API Key ID from Step 3 | From App Store Connect |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from Step 3 | From App Store Connect |
| `APP_STORE_CONNECT_API_KEY` | Contents of the .p8 file | `cat AuthKey_XXXXX.p8` |

## Step 5: Create the App in App Store Connect

1. Go to https://appstoreconnect.apple.com/apps
2. Click "+" → "New App"
3. Fill in:
   - Platform: iOS
   - Name: **Gentoondar**
   - Primary Language: English
   - Bundle ID: `com.gentoondar.app`
   - SKU: `gentoondar`
4. Save

## Step 6: Trigger the Build

Once secrets are added, either:

```bash
# Push a version tag to trigger automatic build + TestFlight deploy
git tag v1.0.0
git push origin v1.0.0
```

Or go to **Actions** tab → **iOS Build & Deploy** → **Run workflow** → check "Deploy to TestFlight"

## Step 7: Submit for Review

1. After TestFlight upload, go to App Store Connect
2. Select Gentoondar → App Store tab
3. Fill in:
   - Screenshots (take from app running on simulator)
   - Description, keywords, categories
   - Privacy policy URL
4. Click "Submit for Review"
5. Apple reviews in 1-3 days typically

## Without a Mac?

If you don't own a Mac, these services provide temporary access:
- **MacStadium** — cloud Mac hosting (from $50/month)
- **MacinCloud** — pay-per-hour Mac access
- **GitHub Actions** — ✅ already set up! Just add the secrets above

The GitHub Actions workflow handles the entire build on Apple's cloud hardware. You only need a Mac briefly for Step 2 (creating the certificate), or you can use a friend's Mac for 10 minutes.
