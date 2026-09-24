/// Firebase Service - Scaffold cho tích hợp Firebase sau này
///
/// Hiện tại đây là placeholder. Khi Firebase được cấu hình:
/// 1. Chạy: flutterfire configure
/// 2. Uncomment import firebase_core và firebase_options
/// 3. Set AppConfig.isFirebaseEnabled = true
/// 4. Uncomment initializeApp() trong main.dart

class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Khởi tạo Firebase
  /// Gọi trước khi dùng bất kỳ Firebase service nào
  static Future<void> initialize() async {
    // TODO: Uncomment sau khi có firebase_options.dart
    //
    // import 'package:firebase_core/firebase_core.dart';
    // import '../../firebase_options.dart';
    //
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    // _initialized = true;

    // Placeholder - Firebase chưa được cấu hình
    _initialized = false;
  }
}
