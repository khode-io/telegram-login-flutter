---
title: Installation
description: Install and set up the Telegram Login Flutter plugin.
---

## Prerequisites

- **iOS:** 15.0 or newer, Xcode 15 or newer
- **Android:** API 23+ (Android 6.0+)
- Flutter `>=3.3.0`, Dart SDK `^3.6.0`
- A registered Telegram bot via [@BotFather](https://t.me/botfather)

## Installation

Add the package to your app's `pubspec.yaml`:

```yaml
dependencies:
  telegram_login: ^1.0.1
```

Then run `flutter pub get`.

- **iOS:** On first build, CocoaPods / SwiftPM will resolve the underlying `telegram-login-ios` SDK automatically.
- **Android:** The Telegram Login SDK is automatically downloaded from Maven Central. No additional setup required.

## Setup

### 1. Register your bot with BotFather

1. Open [@BotFather](https://t.me/botfather)
2. Send `/newbot` (or pick an existing bot)
3. Go to **Bot Settings → Login Widget**
4. Register your app:
   - **iOS:** Provide Bundle ID and Apple Team ID
   - **Android:** Provide package name and SHA-256 fingerprint

BotFather will give you a bot client ID (a numeric string) and provision a secure domain of the form `app{CLIENT_ID}-login.tg.dev` for universal/app links.

### 2. Configure your app

#### iOS Setup

Pick **one** of the two URL delivery mechanisms.

##### Option A — Universal Links (recommended, iOS 17.4+)

1. In Xcode, select your app target → **Signing & Capabilities**
2. Click **+ Capability** → **Associated Domains**
3. Add **both** entries for your login domain:
   - `applinks:app{YOUR_CLIENT_ID}-login.tg.dev`
   - `webcredentials:app{YOUR_CLIENT_ID}-login.tg.dev`
4. For development builds, you may append `?mode=developer` to each entry.

> **Why `webcredentials:` is required.** On iOS 17.4 and newer,
> `ASWebAuthenticationSession` (used internally by the Telegram Login SDK)
> refuses to open an HTTPS callback unless the app is associated with the
> callback host via the `webcredentials` service type. If you add only
> `applinks:`, the session will immediately fail with
> `SFAuthenticationSession was cancelled by user` and the log will contain:
> _"Using HTTPS callbacks requires Associated Domains using the
> `webcredentials` service type for `<host>`."_

Use the `https://` URL as your `redirectUri`:

```dart
redirectUri: 'https://app12345-login.tg.dev'
```

##### Option B — Custom URL Scheme (fallback, also required on iOS < 17.4)

1. Open your app's `Info.plist`
2. Add a URL Type:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

Then use your scheme as the `redirectUri`, and pass the same scheme as `fallbackScheme`:

```dart
TelegramLoginConfiguration(
  clientId: '12345',
  redirectUri: 'myapp://auth',
  scopes: ['profile'],
  fallbackScheme: 'myapp',
)
```

#### Android Setup

1. Register your SHA-256 fingerprint with BotFather:

   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

   Copy the SHA256 value and provide it to BotFather.

2. Add an intent filter to your `AndroidManifest.xml` inside your main activity:

```xml
<activity android:name=".MainActivity">
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https"
              android:host="app{YOUR_CLIENT_ID}-login.tg.dev" />
    </intent-filter>
</activity>
```

Use the same `https://app{CLIENT_ID}-login.tg.dev` URL as your `redirectUri`.

### 3. URL callback forwarding

The plugin automatically registers itself as a delegate, so Telegram callbacks are forwarded to the native SDK without any code in your `AppDelegate` or `MainActivity`. If your app intercepts URLs somewhere else (for example from a router package), use [`handleUrl`](/usage#manual-url-forwarding) to hand them off.
