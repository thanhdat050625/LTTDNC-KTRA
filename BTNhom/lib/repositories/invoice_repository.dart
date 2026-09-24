import '../models/invoice.dart';
import '../models/invoice_detail.dart';

/// Interface định nghĩa các thao tác với Invoice
abstract class InvoiceRepository {
  /// Lấy tất cả hóa đơn (không có details)
  Future<List<Invoice>> getAll();

  /// Lấy hóa đơn theo id (có details)
  Future<Invoice?> getById(String id);

  /// Lấy hóa đơn theo khoảng thời gian
  Future<List<Invoice>> getByDateRange(DateTime from, DateTime to);

  /// Lấy hóa đơn theo ngày
  Future<List<Invoice>> getByDate(DateTime date);

  /// Lấy hóa đơn theo tháng
  Future<List<Invoice>> getByMonth(int year, int month);

  /// Tạo hóa đơn mới kèm các InvoiceDetail
  /// Trả về Invoice đã được lưu (với id)
  Future<Invoice> create(Invoice invoice, List<InvoiceDetail> details);

  /// Lấy danh sách InvoiceDetail theo invoiceId
  Future<List<InvoiceDetail>> getDetailsByInvoiceId(String invoiceId);

  /// Stream danh sách hóa đơn (realtime cho Firestore)
  Stream<List<Invoice>> watchAll();
}
