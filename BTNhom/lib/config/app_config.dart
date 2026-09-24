/// Cấu hình tổng quát của ứng dụng
class AppConfig {
  AppConfig._();

  /// Bật/tắt Firebase
  /// - false: sử dụng mock/local data (mặc định khi chưa cấu hình Firebase)
  /// - true: sử dụng Firestore (cần firebase_options.dart)
  static const bool isFirebaseEnabled = false;

  /// Tên ứng dụng
  static const String appName = 'Grocery Store';

  /// Phiên bản ứng dụng
  static const String appVersion = '1.0.0';

  /// Môi trường
  static const String environment = 'development';
}
