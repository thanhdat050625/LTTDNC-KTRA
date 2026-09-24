import '../models/invoice.dart';
import '../models/revenue.dart';
import '../repositories/invoice_repository.dart';
import '../repositories/revenue_repository.dart';
import '../utils/date_utils.dart';

/// Triển khai RevenueRepository tính toán trực tiếp từ dữ liệu hóa đơn thật
class CalculatedRevenueRepository implements RevenueRepository {
  final InvoiceRepository _invoiceRepository;

  CalculatedRevenueRepository(this._invoiceRepository);

  @override
  Future<RevenueStats> getByDay(DateTime date) async {
    final invoices = await _invoiceRepository.getByDate(date);
    return _aggregateStats(date, invoices);
  }

  @override
  Future<RevenueStats> getByMonth(int year, int month) async {
    final invoices = await _invoiceRepository.getByMonth(year, month);
    return _aggregateStats(DateTime(year, month, 1), invoices);
  }

  @override
  Future<List<RevenueDataPoint>> getDailyRevenueInMonth(
      int year, int month) async {
    final invoices = await _invoiceRepository.getByMonth(year, month);
    final days = AppDateUtils.getDaysInMonth(year, month);

    return days.map((day) {
      final dayInvoices = invoices
          .where((inv) => AppDateUtils.isSameDay(inv.ngayBan, day))
          .toList();
      final revenue =
          dayInvoices.fold(0.0, (sum, inv) => sum + inv.tongTien);
      return RevenueDataPoint(
        date: day,
        revenue: revenue,
        invoiceCount: dayInvoices.length,
      );
    }).toList();
  }

  @override
  Future<List<RevenueDataPoint>> getMonthlyRevenueInYear(int year) async {
    final results = <RevenueDataPoint>[];
    for (int month = 1; month <= 12; month++) {
      final invoices = await _invoiceRepository.getByMonth(year, month);
      final revenue =
          invoices.fold(0.0, (sum, inv) => sum + inv.tongTien);
      results.add(RevenueDataPoint(
        date: DateTime(year, month, 1),
        revenue: revenue,
        invoiceCount: invoices.length,
      ));
    }
    return results;
  }

  @override
  Future<RevenueStats> getByDateRange(DateTime from, DateTime to) async {
    final invoices = await _invoiceRepository.getByDateRange(from, to);
    return _aggregateStats(from, invoices);
  }

  RevenueStats _aggregateStats(DateTime date, List<Invoice> invoices) {
    final totalRevenue =
        invoices.fold(0.0, (sum, inv) => sum + inv.tongTien);
    final totalVat = invoices.fold(0.0, (sum, inv) => sum + inv.vat);
    final totalDiscount =
        invoices.fold(0.0, (sum, inv) => sum + inv.giamGia);

    return RevenueStats(
      date: date,
      totalRevenue: totalRevenue,
      invoiceCount: invoices.length,
      totalVat: totalVat,
      totalDiscount: totalDiscount,
    );
  }
}
