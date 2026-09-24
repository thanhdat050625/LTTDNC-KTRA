/// Cấu hình Firebase
///
/// File này là placeholder cho Firebase configuration.
/// Để enable Firebase:
/// 1. Chạy `flutterfire configure` để tạo firebase_options.dart tự động, HOẶC
/// 2. Tạo file firebase_options.dart thủ công với thông tin từ Firebase Console
///
/// Sau khi có firebase_options.dart:
/// 1. Bật cờ [isFirebaseEnabled] = true trong AppConfig
/// 2. Uncomment Firebase.initializeApp() trong main.dart
/// 3. Thay MockProductRepository bằng FirebaseProductRepository trong provider

class FirebaseConfig {
  FirebaseConfig._();

  // ==================== COLLECTIONS ====================
  static const String productsCollection = 'products';
  static const String invoicesCollection = 'invoices';
  static const String invoiceDetailsCollection = 'invoice_details';

  // ==================== CONFIG ====================
  /// Kết nối trực tiếp Firestore (không dùng emulator)
  static const bool useEmulator = false;
  static const String emulatorHost = 'localhost';
  static const int firestoreEmulatorPort = 8080;
}
