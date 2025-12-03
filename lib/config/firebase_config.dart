// lib/config/firebase_config.dart
class FirebaseConfig {
  // Firebase configuration values
  static const String apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyBU0Wz9mBHYdIOuT-kDKAwXq8_wnJwwSMo', // Fallback for local dev if needed, but ideally remove this for prod
  );
  static const String authDomain = "first-aws-de44a.firebaseapp.com";
  static const String projectId = "first-aws-de44a";
  static const String storageBucket = "first-aws-de44a.firebasestorage.app";
  static const String messagingSenderId = "400850122296";
  static const String appId = "1:400850122296:web:8e0d0d12aa0d0e2aab58cd";
  static const String measurementId = "G-ZEBKCLFL70";

  // Storage bucket paths
  static const String eventImagesBucket = 'event-images';
  static const String galleryImagesBucket = 'gallery-images';
  static const String speakerImagesBucket = 'speaker-images';
}

