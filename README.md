# PetroQwiq Client — Flutter Code Audit

This repository contains a Flutter mobile app prototype for taking camera photos with compass and GPS information. The public product links are listed below; this README describes what is currently implemented in this repository, not every feature that may be available in the published product.

## Public links

- Website: [petroqwiq.com](https://petroqwiq.com/)
- Google Play: [PetroQwiq Client](https://play.google.com/store/apps/details?id=com.petroqwiq.user)
- App Store: [PetroQwiq Client](https://apps.apple.com/us/app/petroqwiq-client/id6590624622)

## What is implemented

The active app entry point is `lib/main.dart`. It displays a simple home screen with an **Open Camera Overlay** button, which opens the camera and sensor screen.

The active camera flow in `lib/camera_campus_overly.dart`:

1. Initializes the device's first available camera at medium resolution and displays its preview.
2. Subscribes to compass heading updates and requests the device's current location.
3. Displays the current heading, latitude/longitude, altitude, a timestamp, and a compass-style row of direction labels over the preview.
4. Captures a photo and prepares an image with direction, coordinates, altitude, and capture time drawn over it by `lib/overly_image_process.dart`.
5. Shows a confirmation preview with cancel and confirm controls.
6. On confirmation, adds the photo's temporary file path and metadata to an in-memory list. The screen displays thumbnails and offers **Discard All** and **Confirm** actions.

The camera screen cancels its timer and compass subscription and disposes of its camera controller when it is closed.

## Current implementation boundaries

The following details are important when evaluating or extending this code:

- The top-level **Confirm** action does not send files to a server. `_sendPhotos` only prints the queued photo paths and metadata to the debug console, then clears the in-memory list.
- The confirmation preview uses the processed image, but the queue stores the original camera file path. As a result, queued thumbnails and the logged file are not the composited/overlaid image.
- Confirmed images are not copied to the device's photo gallery or another durable location by this code. The queue is held only in memory and is lost when the screen or app state is discarded.
- The camera screen includes fixed sample labels (`39 BEXLEY GROVE, SB SNZ` and `IWI BEDROOM1`). They are not calculated from the GPS position.
- The compass heading text is updated from sensor events, but the direction-label strip is a repeated static list and is not rotated or scrolled to follow the heading.
- `lib/map_screen.dart`, `lib/inventry_profile.dart`, and `lib/custom_pin_widget.dart` contain commented-out code. They are not active screens or features in the app. In particular, the repository does not currently run a map, inventory transfer/PDF workflow, or backend integration.
- The package name and native display labels still use Flutter starter values such as `flutter_application_2`; the public links above identify the intended product, but branding has not been applied consistently throughout the native project configuration.

## Source layout

| Path | Purpose |
| --- | --- |
| `lib/main.dart` | App entry point and home screen. |
| `lib/camera_campus_overly.dart` | Camera preview, compass/location readings, capture confirmation, and in-memory photo queue. |
| `lib/overly_image_process.dart` | Draws heading, coordinates, altitude, and timestamp onto image bytes. |
| `lib/map_screen.dart` | Commented-out map experiment; not used by the running app. |
| `lib/inventry_profile.dart` | Commented-out inventory/PDF experiment; not used by the running app. |
| `lib/custom_pin_widget.dart` | Commented-out custom map-pin experiment. |
| `assets/` | App image assets declared in `pubspec.yaml`. |
| `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/` | Flutter platform runner projects. Their presence does not mean every platform has been validated for the camera flow. |

## Technology and dependencies

This is a Flutter/Dart application. `pubspec.yaml` sets the Dart SDK constraint to `^3.5.4`.

The active code uses these packages:

- [`camera`](https://pub.dev/packages/camera) — camera discovery, preview, and photo capture.
- [`flutter_compass`](https://pub.dev/packages/flutter_compass) — compass heading stream.
- [`geolocator`](https://pub.dev/packages/geolocator) — current location and altitude.
- [`intl`](https://pub.dev/packages/intl) — formatted capture timestamps.
- [`image`](https://pub.dev/packages/image) — reads image dimensions for queued photo metadata.

`path_provider`, `permission_handler`, `google_fonts`, and `cupertino_icons` are also declared dependencies, but are not used by the active Dart screens. Google Maps and PDF-related dependencies shown as comments in `pubspec.yaml` are not installed as active dependencies.

## Requirements and permissions

- Flutter SDK with Dart 3.5.4-compatible dependencies.
- A physical device with a camera is recommended. Compass and location readings depend on available device hardware and services.
- Camera and location access must be allowed for the relevant platform. If location permission is denied, the initial location read returns without a position; capture also attempts to read location again.
- The Android manifest declares camera, fine/coarse location, internet, and legacy external-storage permissions.
- The iOS `Info.plist` currently does not include camera or location usage-description strings. Add the appropriate `NSCameraUsageDescription` and location usage description before using the camera/location flow in an iOS build; otherwise iOS permission prompts or plugin use may fail.

The app also needs working location services for usable coordinates. The current implementation does not provide a complete in-app recovery or settings flow for denied permissions or disabled location services.

## Run locally

1. Install Flutter and the platform tools for your target device.
2. From the repository root, fetch packages:

   ```sh
   flutter pub get
   ```

3. Connect an Android or iOS device, then list available Flutter targets:

   ```sh
   flutter devices
   ```

4. Run the app:

   ```sh
   flutter run
   ```

Grant camera and location permissions when prompted. Simulator/emulator availability for camera, compass, and GPS depends on its configuration; a physical device is the most representative test target.

## Build

For example, build a release package with:

```sh
flutter build apk --release
```

For iOS, configure the required usage descriptions and signing in the Xcode project before building or distributing:

```sh
flutter build ios --release
```

The Android Gradle configuration currently uses the debug signing configuration for release builds. Set up a proper release keystore/signing configuration before publishing a release from this repository.

## Tests and verification notes

The checked-in `test/widget_test.dart` is still the default Flutter counter smoke test. It expects a counter and an increment button that the current app does not implement, so the test needs to be replaced with tests for the actual home and camera flow.

Useful project checks:

```sh
flutter analyze
flutter test
```

No claim is made here that the current repository passes those checks or that its Android/iOS builds have been validated on devices.
