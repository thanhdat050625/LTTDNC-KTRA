import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../models/invoice.dart';
import '../../models/invoice_detail.dart';
import '../../repositories/invoice_repository.dart';
import '../../utils/date_utils.dart';

/// Triển khai InvoiceRepository dùng mock/in-memory data
class MockInvoiceRepository implements InvoiceRepository {
  final _uuid = const Uuid();
  final List<Invoice> _invoices = [];
  final List<InvoiceDetail> _details = [];
  final _streamController = StreamController<List<Invoice>>.broadcast();

  MockInvoiceRepository() {
    _seedData();
  }

  /// Khởi tạo dữ liệu mẫu để test thống kê
  void _seedData() {
    // Tạo một số hóa đơn mẫu trong tháng hiện tại
    final now = DateTime.now();

    // Hóa đơn ngày hôm nay
    final inv1Id = _uuid.v4();
    final d1 = [
      InvoiceDetail(
        id: _uuid.v4(),
        invoiceId: inv1Id,
        productId: 'mock-1',
        tenSanPham: 'Gạo 5kg',
        soLuong: 2,
        donGia: 150000,
      ),
      InvoiceDetail(
        id: _uuid.v4(),
        invoiceId: inv1Id,
        productId: 'mock-2',
        tenSanPham: 'Sữa tươi 1L',
        soLuong: 3,
        donGia: 28000,
      ),
    ];
    final inv1 = Invoice.calculate(
      id: inv1Id,
      ngayBan: now,
      nhanVien: 'Nhân viên A',
      details: d1,
    );
    _invoices.add(inv1);
    _details.addAll(d1);

    // Hóa đơn hôm qua
    final inv2Id = _uuid.v4();
    final d2 = [
      InvoiceDetail(
        id: _uuid.v4(),
        invoiceId: inv2Id,
        productId: 'mock-3',
        tenSanPham: 'Nước ngọt',
        soLuong: 5,
        donGia: 15000,
      ),
      InvoiceDetail(
        id: _uuid.v4(),
        invoiceId: inv2Id,
        productId: 'mock-4',
        tenSanPham: 'Bánh mì',
        soLuong: 4,
        donGia: 12000,
      ),
    ];
    final inv2 = Invoice.calculate(
      id: inv2Id,
      ngayBan: now.subtract(const Duration(days: 1)),
      nhanVien: 'Nhân viên B',
      details: d2,
    );
    _invoices.add(inv2);
    _details.addAll(d2);

    // Hóa đơn 3 ngày trước
    final inv3Id = _uuid.v4();
    final d3 = [
      InvoiceDetail(
        id: _uuid.v4(),
        invoiceId: inv3Id,
        productId: 'mock-1',
        tenSanPham: 'Gạo 5kg',
        soLuong: 4,
        donGia: 150000,
      ),
      InvoiceDetail(
        id: _uuid.v4(),
        invoiceId: inv3Id,
        productId: 'mock-2',
        tenSanPham: 'Sữa tươi 1L',
        soLuong: 6,
        donGia: 28000,
      ),
      InvoiceDetail(
        id: _uuid.v4(),
        invoiceId: inv3Id,
        productId: 'mock-3',
        tenSanPham: 'Nước ngọt',
        soLuong: 10,
        donGia: 15000,
      ),
    ];
    final inv3 = Invoice.calculate(
      id: inv3Id,
      ngayBan: now.subtract(const Duration(days: 3)),
      nhanVien: 'Nhân viên A',
      details: d3,
    );
    _invoices.add(inv3);
    _details.addAll(d3);

    _notify();
  }

  void _notify() {
    _streamController.add(List.unmodifiable(_invoices));
  }

  @override
  Future<List<Invoice>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final sorted = List<Invoice>.from(_invoices)
      ..sort((a, b) => b.ngayBan.compareTo(a.ngayBan));
    return sorted;
  }

  @override
  Future<Invoice?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      final invoice = _invoices.firstWhere((inv) => inv.id == id);
      final details = _details.where((d) => d.invoiceId == id).toList();
      return invoice.copyWith(details: details);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Invoice>> getByDateRange(DateTime from, DateTime to) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final startDay = AppDateUtils.startOfDay(from);
    final endDay = AppDateUtils.endOfDay(to);
    return _invoices
        .where((inv) =>
            inv.ngayBan.isAfter(startDay) &&
            inv.ngayBan.isBefore(endDay))
        .toList()
      ..sort((a, b) => b.ngayBan.compareTo(a.ngayBan));
  }

  @override
  Future<List<Invoice>> getByDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _invoices
        .where((inv) => AppDateUtils.isSameDay(inv.ngayBan, date))
        .toList()
      ..sort((a, b) => b.ngayBan.compareTo(a.ngayBan));
  }

  @override
  Future<List<Invoice>> getByMonth(int year, int month) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _invoices
        .where((inv) => inv.ngayBan.year == year && inv.ngayBan.month == month)
        .toList()
      ..sort((a, b) => b.ngayBan.compareTo(a.ngayBan));
  }

  @override
  Future<Invoice> create(Invoice invoice, List<InvoiceDetail> details) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final newId = _uuid.v4();

    // Cập nhật invoiceId cho các details
    final newDetails = details
        .map((d) => d.copyWith(
              id: _uuid.v4(),
              invoiceId: newId,
            ))
        .toList();

    final newInvoice = invoice.copyWith(id: newId, details: newDetails);
    _invoices.add(newInvoice);
    _details.addAll(newDetails);
    _notify();
    return newInvoice;
  }

  @override
  Future<List<InvoiceDetail>> getDetailsByInvoiceId(String invoiceId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _details.where((d) => d.invoiceId == invoiceId).toList();
  }

  @override
  Stream<List<Invoice>> watchAll() => _streamController.stream;

  void dispose() {
    _streamController.close();
  }
}
