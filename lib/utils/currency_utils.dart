import 'package:intl/intl.dart';

/// Tiện ích định dạng tiền tệ VNĐ
class CurrencyUtils {
  CurrencyUtils._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final NumberFormat _formatterNoSymbol = NumberFormat.decimalPattern('vi_VN');

  /// Format số tiền thành chuỗi VNĐ, ví dụ: ₫28.000
  static String format(double amount) {
    return _formatter.format(amount);
  }

  /// Format số tiền không có ký hiệu, ví dụ: 28.000
  static String formatNoSymbol(double amount) {
    return _formatterNoSymbol.format(amount.toInt());
  }

  /// Parse chuỗi số về double
  static double? parse(String value) {
    try {
      final cleaned = value.replaceAll('.', '').replaceAll(',', '.').replaceAll('₫', '').trim();
      return double.parse(cleaned);
    } catch (_) {
      return null;
    }
  }
}
