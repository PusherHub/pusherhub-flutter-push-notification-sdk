# PusherHub Flutter SDK — push notifications for Android and iOS

Push notifications and in-app messages for your Flutter app on **Android and iOS**: a free push notification service that sends through your own Firebase project — Firebase Cloud Messaging (FCM) for Android and the Apple Push Notification service (APNs) for iPhones — with [PusherHub](https://pusherhub.com).

[Website](https://pusherhub.com) · [Guides](https://pusherhub.com/docs) · [Pricing](https://pusherhub.com/pricing)

## What it does

- Registers each phone with PusherHub and keeps its FCM token up to date
- Links a phone to your own user id with `login()` — remembered across restarts until `logout()`
- Reports notification opens and clicks for your delivery stats
- Hands your app each tapped notification's Custom Data, so you can open the right screen
- Shows in-app messages (banner, modal, full screen, center popup, bottom sheet) on app open, fitted to portrait and landscape screens
- Optional device details (brand, model, app version, language, country, time zone); state and city come from the phone's IP address
- No location code and no location permission: an app that already uses location can add the optional `pusher_hub_location.dart` for GPS-accurate state and city

The SDK is a single file, `pusher_hub.dart`.

## Before you start

1. A PusherHub account with your app added — it's free to start at [pusherhub.com](https://pusherhub.com).
2. Your app added to a Firebase project, with the Firebase service account key uploaded to your app in PusherHub. The [getting-started guide](https://pusherhub.com/docs/getting-started) walks through it.
3. Your **app key** and **public key** — on your app's **SDK Integration** tab in PusherHub, which also shows every step below with your keys already filled in.

## Install

1. Add the dependencies to `pubspec.yaml`:

   ```yaml
   dependencies:
     firebase_core: ^4.14.0
     firebase_messaging: ^16.6.0
     http: ^1.6.0
     shared_preferences: ^2.3.0
     device_info_plus: ^11.1.1
     package_info_plus: ^8.1.2
     flutter_timezone: ^5.1.0
     url_launcher: ^6.3.1
     webview_flutter: ^4.10.0
   ```

   `pusher_hub.dart` needs all of these to compile, even the ones for features you don't use. None of them uses location.

2. Copy [`pusher_hub.dart`](pusher_hub.dart) into your app's `lib/` folder.

3. Finish the Firebase setup for Android and iOS (Google services files, permissions, and on iOS the push capability) — see your app's SDK Integration tab or the [guides](https://pusherhub.com/docs).

## Quick start

```dart
import 'package:flutter/material.dart';
import 'pusher_hub.dart';

final pusherHub = PusherHub(
  appKey: 'YOUR_APP_KEY',
  publicKey: 'YOUR_PUBLIC_KEY',
  baseUrl: 'https://pusherhub.com/api',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Required: gets an FCM token and registers this phone.
  await pusherHub.registerDevice();

  // Optional: brand, model, app version, language, country, time zone.
  await pusherHub.collectDeviceMetadata();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Shows your in-app messages on app open and resume. Keep it, or
      // they never appear. It wraps a screen inside MaterialApp: with
      // routes or a router, wrap the main screen people stay on.
      home: PusherHubMessageHost(
        pusherHub: pusherHub,
        child: const MyHomePage(),
      ),
    );
  }
}
```

## Location (only if your app already uses it)

PusherHub finds each phone's state and city from its IP address, so most apps skip this. Don't add a location permission just for PusherHub: Google Play and the App Store then ask you to explain why your app uses location.

An app that already asks for location can copy [`pusher_hub_location.dart`](pusher_hub_location.dart) next to `pusher_hub.dart` (it needs `geolocator` and `geocoding`, which such an app usually has) and pass it in:

```dart
import 'pusher_hub_location.dart';

final pusherHub = PusherHub(
  appKey: 'YOUR_APP_KEY',
  publicKey: 'YOUR_PUBLIC_KEY',
  baseUrl: 'https://pusherhub.com/api',
  location: pusherHubLocation,
);
```

It never asks for location: it reads it only when the person has already allowed it for your app.

## Signed-in users

```dart
// When someone signs in — links this phone to your user id:
await pusherHub.login(currentUserId);

// When they sign out:
await pusherHub.logout();
```

## Opening a screen when a notification is tapped

Put your own data in **Custom Data** when you create a notification — say `{"campaign_id": "232"}` — and get it back on every tap, whether the app was open, in the background or closed:

```dart
final navigatorKey = GlobalKey<NavigatorState>(); // MaterialApp(navigatorKey: navigatorKey)

final pusherHub = PusherHub(
  appKey: 'YOUR_APP_KEY',
  publicKey: 'YOUR_PUBLIC_KEY',
  baseUrl: 'https://pusherhub.com/api',
  onNotificationOpened: (data) {
    final campaignId = data['campaign_id'];
    if (campaignId != null) {
      navigatorKey.currentState?.pushNamed('/campaign', arguments: campaignId);
    }
  },
);
```

Every value arrives as text (`"232"`). A tap that opened a closed app is handed over once `runApp()` has built your app; if it starts on a splash screen that moves on by itself, keep the data and open the screen after it.

## Keys

The **public key** is meant to be built into your app. Never put your **secret key** in an app — it's only for your own server, with PusherHub's REST API.

## Help

- Step-by-step guides: [pusherhub.com/docs](https://pusherhub.com/docs)
- Your app's **SDK Integration** tab in PusherHub has every step with your keys filled in.

## License

[MIT](LICENSE)
