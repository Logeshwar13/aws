# Logo Setup Guide

## Where to Add Your Club Logo

Your logo can be added in **`lib/widgets/app_bar_widget.dart`** at line 26-38.

### Option 1: Using Local Asset (Recommended)

1. Add your logo image to `assets/images/logo.png`
2. In `app_bar_widget.dart`, replace lines 26-38 with:

```dart
// Replace the Container with this:
Image.asset(
  'assets/images/logo.png',
  height: 40,
  width: 40,
  errorBuilder: (_, __, ___) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF146EB4),
          Color(0xFF00A1C9),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(Icons.cloud, color: Colors.white, size: 24),
  ),
),
```

3. Make sure `pubspec.yaml` includes:
```yaml
flutter:
  assets:
    - assets/images/
```

### Option 2: Using Network Image (If logo is hosted online)

Replace the Container with:

```dart
Image.network(
  'YOUR_LOGO_URL_HERE',
  height: 40,
  width: 40,
  errorBuilder: (_, __, ___) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF146EB4),
          Color(0xFF00A1C9),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(Icons.cloud, color: Colors.white, size: 24),
  ),
),
```

### Option 3: Keep Current Placeholder

The current design uses a gradient container with a cloud icon. You can keep this if you prefer, or customize the colors to match your logo.

## Logo Specifications

- **Recommended size**: 40x40 pixels (or 2x/3x for retina displays)
- **Format**: PNG with transparent background (preferred)
- **Aspect ratio**: Square (1:1)
- **File location**: `assets/images/logo.png`

## After Adding Logo

Run:
```bash
flutter pub get
flutter run
```

