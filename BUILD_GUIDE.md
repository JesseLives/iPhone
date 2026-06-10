# 🛠️ Complete Build Guide — Flutter iOS IPA

## 🌟 Why Flutter?
- ✅ Build from **Windows, Linux, or Mac**
- ✅ Excellent **cloud build** support (Codemagic is built by Flutter team!)
- ✅ Beautiful cross-platform UI
- ✅ Huge ecosystem of packages
- ✅ Hot reload for fast development

---

## Option A: Codemagic Cloud Build ⭐ RECOMMENDED (Free)

### Step 1: Create GitHub Repository
1. Go to [github.com](https://github.com) → **New repository**
2. Name it `my-ios-app`
3. Upload ALL project files (drag & drop)
4. Verify structure:
   ```
   my-ios-app/
   ├── lib/
   ├── ios/
   ├── pubspec.yaml
   ├── codemagic.yaml
   └── .github/
   ```

### Step 2: Set Up Codemagic
1. Go to [codemagic.io](https://codemagic.io) → **Start free**
2. Click **Add application**
3. Select **GitHub** → authorize
4. Select your `my-ios-app` repository
5. Choose **Flutter App** as the project type
6. Select **codemagic.yaml** as the configuration source

### Step 3: Configure (Optional)
- The `codemagic.yaml` file has everything pre-configured
- Optionally change the email in the `publishing` section
- No need to set up code signing — we build **unsigned**

### Step 4: Build!
1. Click **Start new build**
2. Select **main** branch
3. Click **Start build**
4. Wait ~10-15 minutes
5. Download `MyIOSApp.ipa` from **Artifacts**

> 💡 Codemagic free tier gives you **500 build minutes/month** on macOS — plenty!

---

## Option B: GitHub Actions (Free for Public Repos)

### Step 1: Create PUBLIC GitHub Repository
1. **New repository** on GitHub
2. Make it **PUBLIC** (required for free macOS runners)
3. Upload all project files

### Step 2: Trigger Build
1. Go to your repo → **Actions** tab
2. Click **Build Flutter iOS IPA**
3. Click **Run workflow** → **Run workflow**

### Step 3: Download IPA
1. Wait ~15-20 minutes for build
2. Click the completed workflow run (green ✓)
3. Scroll to **Artifacts** → click `MyIOSApp.ipa`
4. Extract the ZIP → you get `MyIOSApp.ipa`

---

## Option C: Build Locally on Windows/Linux + Codemagic CLI

If you want to develop locally but still build in the cloud:

```bash
# 1. Install Flutter on your machine
# Windows: https://docs.flutter.dev/get-started/install/windows
# Linux: https://docs.flutter.dev/get-started/install/linux

# 2. Install Codemagic CLI
pip3 install codemagic-cli-tools

# 3. Test the app (runs on Windows/Linux as a desktop app or Chrome)
flutter run -d windows    # Windows
flutter run -d linux      # Linux
flutter run -d chrome     # Web preview

# 4. Push to GitHub and use cloud build for iOS .ipa
```

---

## Option D: Build on a Mac

```bash
# 1. Install Flutter
brew install flutter

# 2. Get dependencies
cd my_ios_app
flutter pub get

# 3. Install iOS pods
cd ios && pod install && cd ..

# 4. Build unsigned IPA
flutter build ios --release --no-codesign

# 5. Create .ipa manually
mkdir -p /tmp/Payload
cp -r build/ios/iphoneos/Runner.app /tmp/Payload/
cd /tmp && zip -r ~/Desktop/MyIOSApp.ipa Payload

echo "✅ IPA saved to ~/Desktop/MyIOSApp.ipa"
```

---

## 🔐 Signing & Installing on iPhone

### Method 1: AltStore (Easiest — Auto-Resigns)

**One-time setup:**
1. Download **AltServer** from [altstore.io](https://altstore.io)
2. Install on your Windows PC or Mac
3. Connect iPhone via USB
4. Click AltServer in system tray → **Install AltStore** → select device
5. AltStore appears on your iPhone!

**Install your app:**
1. Open **AltStore** on iPhone
2. Tap **+** (top right)
3. Select `MyIOSApp.ipa`
4. App installs automatically! 🎉

**Auto-refresh:** AltStore re-signs apps automatically in the background.

### Method 2: Sideloadly (Windows or Mac)

1. Download from [sideloadly.io](https://sideloadly.io)
2. Connect iPhone via USB
3. Open Sideloadly → drag `MyIOSApp.ipa`
4. Enter your **Apple ID** email
5. Click **Start**
6. On iPhone: Settings → General → VPN & Device Management → Trust your ID
7. Done! App is on home screen 🎉

> ⚠️ Free signing lasts 7 days. Re-sign with Sideloadly or use AltStore.

### Method 3: TrollStore (Permanent!)

If your iPhone supports TrollStore:
1. Check compatibility at [trollstore.app](https://trollstore.app)
2. Install TrollStore
3. Open TrollStore → **+** → select `MyIOSApp.ipa`
4. **Permanently installed** — no 7-day limit! 🎉

---

## 🐛 Troubleshooting

### "Untrusted Developer" Error
Settings → General → VPN & Device Management → tap Apple ID → **Trust**

### App Expires After 7 Days
Normal with free signing. Use **AltStore** (auto-refresh) or **TrollStore** (permanent).

### Build Fails on Codemagic
- Make sure `pubspec.yaml` is valid
- Check that all files are uploaded (especially `ios/` folder)
- Verify `codemagic.yaml` is in root directory

### Flutter Build Error
- Make sure `ios/Runner/Info.plist` exists
- Run `flutter pub get` before building
- Check iOS deployment target in `AppFrameworkInfo.plist`

### Can't Find IPA After Build
- Codemagic: Check **Artifacts** section of the build
- GitHub Actions: Check **Artifacts** in the workflow run
- Local: Check `build/ios/iphoneos/` directory

---

## 🎯 Next Steps

1. **Customize** the app — edit files in `lib/screens/`
2. **Change the app name** — edit `ios/Runner/Info.plist`
3. **Change the bundle ID** — search and replace `com.example.myIosApp`
4. **Add your own icon** — replace images in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
5. **Build & sign** — follow the steps above!
