# Dhanur AI App Features (Flutter)

Flutter parity implementation of the React prototype in `../dhanur-ai-app-features`.

## Implemented Scope

- 3-tab app shell (`Live Caption`, `Mic Control`, `Player`)
- Shared dark gradient theme and component styling parity
- Live captioning with speech permission flow and interim/final transcript handling
- Microphone control with permission status, enable/disable, release, and input level meter
- Video player with seek, skip 10s, speed control (0.5x-2.0x), and in-app mini-player mode

## Architecture

- State management: Riverpod + Flutter Hooks
- Feature-first modules:
  - `lib/features/live_captioning`
  - `lib/features/mic_control`
  - `lib/features/player`
- Shared design system:
  - `lib/core/theme`
  - `lib/core/widgets`

## Setup

1. Install Flutter SDK (stable) and Android toolchain.
2. From this folder:

```bash
flutter pub get
```

3. Run on Android:

```bash
flutter run
```

## Notes

- This repo was created from an empty folder; if your local environment needs full generated platform scaffolding, run:

```bash
flutter create .
```

Then re-run `flutter pub get`.

- Android microphone permission is declared in:
  - `android/app/src/main/AndroidManifest.xml`

## Testing

```bash
flutter test
```

flutter pub get
flutter build apk --release

flutter build apk --release --split-per-abi
