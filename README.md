# 🧮 Calculator App (Flutter)

A sleek, modern calculator app built with **Flutter**. Beautiful UI, scientific mode, history, and animations!

## ✨ Features

| Feature | Description |
|---------|------------|
| 🧮 **Standard Calculator** | +, -, ×, ÷, % with clean layout |
| 🔬 **Scientific Mode** | sin, cos, tan, log, ln, √, π, e, powers |
| 📜 **History** | All calculations saved, tap to reuse |
| 🌙 **Dark/Light Mode** | Toggle between themes (defaults to dark) |
| ✨ **Animations** | Press effects, result scaling, smooth transitions |
| 🔢 **Smart Display** | Auto-sizing text for long numbers |
| 🗑️ **Backspace** | Fix mistakes with ⌫ button |
| 🔒 **Privacy** | No data leaves your device |

## 📱 Screenshots Preview

```
┌─────────────────────┐
│  History  Sci  Dark  │  ← Top bar
│                      │
│        42 × 3 + 7   │  ← Expression
│            133       │  ← Result (large)
│                      │
│  AC  +/-   %    ÷   │
│   7    8    9    ×   │
│   4    5    6    -   │
│   1    2    3    +   │
│   0    .    ⌫    =   │
└─────────────────────┘

Scientific Mode:
┌─────────────────────┐
│  sin  cos  tan   ÷  │
│  log   ln   √    ×  │
│  x²   xʸ   π    -  │
│   (    )   e    +   │
│  AC    0   .    =   │
└─────────────────────┘
```

## 📁 Project Structure

```
my_ios_app/
├── lib/
│   ├── main.dart                  # App entry & theme
│   ├── models/
│   │   ├── calculator_engine.dart # Expression parser & evaluator
│   │   └── calc_history.dart      # History model with persistence
│   ├── screens/
│   │   └── calculator_screen.dart # Main calculator UI
│   └── widgets/
│       ├── calc_button.dart       # Animated button component
│       └── display_area.dart      # Expression & result display
├── ios/                           # iOS native config
├── codemagic.yaml                 # Cloud build (Codemagic)
├── .github/workflows/build.yml    # Cloud build (GitHub Actions)
└── BUILD_GUIDE.md                 # Step-by-step build instructions
```

## 🚀 Build Your .IPA (No Mac!)

### ⭐ Codemagic (Free, Recommended)
1. Push to GitHub
2. Sign up at [codemagic.io](https://codemagic.io)
3. Connect repo → Start build
4. Download `Calculator.ipa`

### GitHub Actions (Free for public repos)
1. Push to **public** GitHub repo
2. Actions → Build Flutter iOS IPA → Run workflow
3. Download `.ipa` from artifacts

## 🔐 Sign & Install

- **AltStore** ([altstore.io](https://altstore.io)) → Install → tap **+** → select .ipa
- **Sideloadly** ([sideloadly.io](https://sideloadly.io)) → drag .ipa → Apple ID → Start
- **TrollStore** → Permanent install (check trollstore.app)

## 🎨 Customization

- **App name**: Edit `ios/Runner/Info.plist` → `CFBundleDisplayName`
- **Theme color**: Change `colorSchemeSeed` in `lib/main.dart`
- **Button colors**: Edit `_getBackgroundColor()` in `calc_button.dart`

## 📋 Requirements
- iOS 12.0+
- Flutter 3.x (for building)
