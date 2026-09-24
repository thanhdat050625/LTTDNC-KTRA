/// Model thống kê doanh thu theo khoảng thời gian
class RevenueStats {
  final DateTime date;
  final double totalRevenue;
  final int invoiceCount;
  final double totalVat;
  final double totalDiscount;

  const RevenueStats({
    required this.date,
    required this.totalRevenue,
    required this.invoiceCount,
    required this.totalVat,
    required this.totalDiscount,
  });

  /// Doanh thu thuần (trước VAT và giảm giá)
  double get netRevenue => totalRevenue - totalVat + totalDiscount;

  @override
  String toString() =>
      'RevenueStats(date: $date, totalRevenue: $totalRevenue, invoiceCount: $invoiceCount)';
}

/// Model một điểm dữ liệu trên chart
class RevenueDataPoint {
  final DateTime date;
  final double revenue;
  final int invoiceCount;

  const RevenueDataPoint({
    required this.date,
    required this.revenue,
    required this.invoiceCount,
  });
}
