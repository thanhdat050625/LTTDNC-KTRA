import 'package:intl/intl.dart';

/// Tiện ích xử lý ngày tháng
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy', 'vi_VN');
  static final DateFormat _dateTimeFormatter = DateFormat('HH:mm dd/MM/yyyy', 'vi_VN');
  static final DateFormat _monthFormatter = DateFormat('MM/yyyy', 'vi_VN');
  static final DateFormat _monthNameFormatter = DateFormat('MMMM yyyy', 'vi_VN');
  static final DateFormat _dayNameFormatter = DateFormat('EEEE, dd MMMM yyyy', 'vi_VN');

  /// Format ngày: 24/09/2026
  static String formatDate(DateTime date) => _dateFormatter.format(date);

  /// Format ngày giờ: 08:30 24/09/2026
  static String formatDateTime(DateTime date) => _dateTimeFormatter.format(date);

  /// Format tháng: 09/2026
  static String formatMonth(DateTime date) => _monthFormatter.format(date);

  /// Format tên tháng: Tháng 9 2026
  static String formatMonthName(DateTime date) => _monthNameFormatter.format(date);

  /// Format ngày đầy đủ: Thứ Năm, 24 Tháng 9 2026
  static String formatDayName(DateTime date) => _dayNameFormatter.format(date);

  /// Kiểm tra xem 2 ngày có cùng ngày không
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Kiểm tra xem 2 ngày có cùng tháng không
  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  /// Lấy danh sách các ngày trong tháng
  static List<DateTime> getDaysInMonth(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0);
    return List.generate(
      lastDay.day,
      (i) => DateTime(year, month, i + 1),
    );
  }

  /// Lấy ngày đầu tháng
  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  /// Lấy ngày cuối tháng
  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59);

  /// Lấy ngày đầu ngày
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Lấy ngày cuối ngày
  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);
}
