// Sample Firebase options for open-source distribution.
// Replace these placeholder values with your own Firebase project details.
// Placeholder config files are provided at:
//   - android/app/google-services.json
//   - ios/Runner/GoogleService-Info.plist

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

class FirebasePlaceholderConfig {
  static const apiKey = 'AIzaSyBGsxIXzz8hf0DOhk7JvnN7kMxLeSnwudc';
  static const senderId = '920449298432';
  static const projectId = 'frontier-store-e021a';
  static const storageBucket = 'frontier-store-e021a.firebasestorage.app';
  static const androidAppId = '1:920449298432:android:06131b93d26b4b79e4e8e5';
  static const iosAppId = '1:920449298432:ios:478cc96f76d28aa5e4e8e5';
  static const iosBundleId = 'com.frontier.ibs.store';
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) {
      return android;
    }
    if (Platform.isIOS) {
      return ios;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: FirebasePlaceholderConfig.apiKey,
    appId: FirebasePlaceholderConfig.androidAppId,
    messagingSenderId: FirebasePlaceholderConfig.senderId,
    projectId: FirebasePlaceholderConfig.projectId,
    storageBucket: FirebasePlaceholderConfig.storageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: FirebasePlaceholderConfig.apiKey,
    appId: FirebasePlaceholderConfig.iosAppId,
    messagingSenderId: FirebasePlaceholderConfig.senderId,
    projectId: FirebasePlaceholderConfig.projectId,
    storageBucket: FirebasePlaceholderConfig.storageBucket,
    iosBundleId: FirebasePlaceholderConfig.iosBundleId,
  );
}
