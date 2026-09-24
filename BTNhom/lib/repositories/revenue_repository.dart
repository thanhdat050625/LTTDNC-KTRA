import '../models/revenue.dart';

/// Interface định nghĩa các thao tác thống kê doanh thu
abstract class RevenueRepository {
  /// Thống kê doanh thu theo ngày
  Future<RevenueStats> getByDay(DateTime date);

  /// Thống kê doanh thu theo tháng
  Future<RevenueStats> getByMonth(int year, int month);

  /// Doanh thu theo từng ngày trong tháng (cho chart)
  Future<List<RevenueDataPoint>> getDailyRevenueInMonth(int year, int month);

  /// Doanh thu theo từng tháng trong năm (cho chart)
  Future<List<RevenueDataPoint>> getMonthlyRevenueInYear(int year);

  /// Doanh thu trong khoảng thời gian
  Future<RevenueStats> getByDateRange(DateTime from, DateTime to);
}
