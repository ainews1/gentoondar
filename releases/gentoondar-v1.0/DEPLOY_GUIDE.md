# Gentoondar v1.0 — Deployment Guide 🐄📅

## Build Artifacts

| Platform | File | Size | Status |
|----------|------|------|--------|
| **Android APK** | `gentoondar-v1.0-signed.apk` | 51 MB | ✅ Signed, ready to sideload |
| **Android AAB** | `gentoondar-v1.0-signed.aab` | 42 MB | ✅ Signed, ready for Google Play |
| **Web App** | `web/` | — | ✅ Live on port 8080 |
| **Linux x64** | `gentoondar-v1.0-linux-x64.tar.gz` | 19 MB | ✅ Gentoo/Linux binary |
| **iOS** | — | — | ⚠️ Requires macOS + Xcode (see below) |

---

## 1. Google Play Store (Android)

### Prerequisites
- Google Play Developer account ($25 one-time fee): https://play.google.com/console/signup
- The signed AAB file: `gentoondar-v1.0-signed.aab`

### Steps
1. Go to [Google Play Console](https://play.google.com/console/)
2. Click **"Create app"**
   - App name: **Gentoondar**
   - Default language: English
   - App or Game: **App**
   - Free or Paid: **Free**
3. Complete the **Store listing**:
   - Title: Gentoondar — Task Calendar
   - Short description: Gentoo-themed task calendar with productivity analytics
   - Full description: (see below)
   - Screenshots: Take from the running web app
   - App icon: 512x512 PNG
   - Feature graphic: 1024x500 PNG
4. Go to **Release** → **Production** → **Create new release**
5. Upload `gentoondar-v1.0-signed.aab`
6. Complete **Content rating**, **Target audience**, **Data safety** questionnaires
7. Submit for review (typically 1-7 days)

### Store Description
```
🐄 Gentoondar — Your Gentoo-Themed Task Calendar

Manage your tasks with style! Gentoondar brings the power of Gentoo Linux's 
philosophy to your daily planning.

Features:
📅 Month, Week & Day calendar views
✅ Create, edit, and track tasks with time blocks
📊 Productivity analytics with interactive charts
🔍 Real-time search and smart filtering
♿ Full accessibility (WCAG 2.1 AA)
🎨 Beautiful Material 3 design with Gentoo purple theme

Built with Flutter for blazing performance across all platforms.
```

### Upload Signing Key
- Keystore: `gentoondar-upload.jks`
- Key alias: `gentoondar`
- **IMPORTANT**: Back up this keystore securely! You cannot publish updates without it.

---

## 2. Apple App Store (iOS/iPhone)

### Prerequisites
- Apple Developer account ($99/year): https://developer.apple.com/programs/
- A Mac with Xcode installed
- The iOS project directory from this repo (`ios/`)

### Steps (on a Mac)
```bash
# Clone the project to your Mac
git clone <repo-url>
cd task_calendar_app

# Install dependencies
flutter pub get

# Open in Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select Runner target → Signing & Capabilities
# 2. Set Team to your Apple Developer account
# 3. Bundle ID is already set: com.gentoondar.app
# 4. Select "Any iOS Device" as target
# 5. Product → Archive
# 6. Distribute App → App Store Connect
```

### App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Create new app with bundle ID `com.gentoondar.app`
3. Fill in metadata (same as Google Play description)
4. Upload the archive from Xcode
5. Submit for review (typically 1-3 days)

---

## 3. Web App (PWA)

### Currently Live
- **Local**: http://localhost:8080
- **LAN**: http://192.168.178.109:8080
- **Tailscale**: http://100.108.136.84:8080

### Deploy to Production

#### Option A: GitHub Pages (Free)
```bash
cd releases/gentoondar-v1.0/web
git init
git add .
git commit -m "Deploy Gentoondar web app"
git remote add origin https://github.com/<user>/gentoondar.github.io
git push -u origin main
# Visit: https://<user>.github.io
```

#### Option B: Netlify/Vercel (Free tier)
1. Drag & drop the `web/` folder to https://app.netlify.com/drop
2. Get instant URL like `https://gentoondar.netlify.app`

#### Option C: Self-hosted (nginx)
```bash
# Copy web files
sudo cp -r web/ /var/www/gentoondar/

# nginx config
server {
    listen 80;
    server_name gentoondar.example.com;
    root /var/www/gentoondar;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## 4. Linux Desktop

### Direct Install
```bash
tar xzf gentoondar-v1.0-linux-x64.tar.gz
cd linux/
./task_calendar_app
```

### Create .desktop Entry
```bash
cat > ~/.local/share/applications/gentoondar.desktop << 'EOF'
[Desktop Entry]
Name=Gentoondar
Comment=Gentoo-Themed Task Calendar
Exec=/opt/gentoondar/task_calendar_app
Icon=/opt/gentoondar/data/flutter_assets/assets/icon.png
Terminal=false
Type=Application
Categories=Office;Calendar;
EOF

# Install
sudo mkdir -p /opt/gentoondar
sudo tar xzf gentoondar-v1.0-linux-x64.tar.gz -C /opt/gentoondar --strip-components=1
```

### Gentoo Ebuild (for Portage)
A custom ebuild can be created in a local overlay for `emerge gentoondar`.

---

## Signing Key Backup

**CRITICAL**: Back up these files securely:
- `gentoondar-upload.jks` — Android signing keystore
- `key.properties` — keystore passwords (in `android/` directory)

Without these, you cannot publish updates to Google Play.

---

## Quick Download Links (when servers running)

| Platform | Download |
|----------|----------|
| Android APK | http://192.168.178.109:8081/gentoondar-v1.0-signed.apk |
| Linux x64 | http://192.168.178.109:8081/gentoondar-v1.0-linux-x64.tar.gz |
| Web App | http://192.168.178.109:8080/ |
