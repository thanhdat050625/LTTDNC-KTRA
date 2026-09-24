import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import 'invoice_detail.dart';

/// Model đại diện cho một hóa đơn bán hàng
class Invoice {
  final String id;
  final DateTime ngayBan;
  final String nhanVien;
  final double tongTien;   // Tổng thanh toán cuối cùng
  final double vat;        // Số tiền VAT
  final double giamGia;    // Số tiền được giảm
  final List<InvoiceDetail> details; // Chi tiết hóa đơn (optional, loaded separately)

  const Invoice({
    required this.id,
    required this.ngayBan,
    required this.nhanVien,
    required this.tongTien,
    required this.vat,
    required this.giamGia,
    this.details = const [],
  });

  /// Tạm tính (trước VAT và giảm giá)
  /// Được tính ngược lại từ: tongTien = tamTinh + vat - giamGia
  double get tamTinh => tongTien - vat + giamGia;

  /// Kiểm tra hóa đơn có được giảm giá không
  bool get hasDiscount => giamGia > 0;

  /// Tính tổng tiền từ danh sách InvoiceDetail
  static double calculateSubtotal(List<InvoiceDetail> details) {
    return details.fold(0.0, (sum, d) => sum + d.thanhTien);
  }

  /// Tính VAT từ tạm tính
  static double calculateVat(double subtotal) {
    return subtotal * AppConstants.vatRate;
  }

  /// Tính giảm giá từ tạm tính (áp dụng theo quy định)
  static double calculateDiscount(double subtotal) {
    return subtotal > AppConstants.discountThreshold
        ? subtotal * AppConstants.discountRate
        : 0.0;
  }

  /// Tính tổng thanh toán cuối
  static double calculateTotal(double subtotal, double vat, double discount) {
    return subtotal + vat - discount;
  }

  /// Factory method: tính toán tất cả từ danh sách InvoiceDetail
  factory Invoice.calculate({
    required String id,
    required DateTime ngayBan,
    required String nhanVien,
    required List<InvoiceDetail> details,
  }) {
    final subtotal = calculateSubtotal(details);
    final vat = calculateVat(subtotal);
    final discount = calculateDiscount(subtotal);
    final total = calculateTotal(subtotal, vat, discount);

    return Invoice(
      id: id,
      ngayBan: ngayBan,
      nhanVien: nhanVien,
      tongTien: total,
      vat: vat,
      giamGia: discount,
      details: details,
    );
  }

  /// Tạo bản sao với các trường được cập nhật
  Invoice copyWith({
    String? id,
    DateTime? ngayBan,
    String? nhanVien,
    double? tongTien,
    double? vat,
    double? giamGia,
    List<InvoiceDetail>? details,
  }) {
    return Invoice(
      id: id ?? this.id,
      ngayBan: ngayBan ?? this.ngayBan,
      nhanVien: nhanVien ?? this.nhanVien,
      tongTien: tongTien ?? this.tongTien,
      vat: vat ?? this.vat,
      giamGia: giamGia ?? this.giamGia,
      details: details ?? this.details,
    );
  }

  /// Chuyển từ Map
  factory Invoice.fromMap(String id, Map<String, dynamic> map) {
    return Invoice(
      id: id,
      ngayBan: DateTime.parse(map['ngayBan'] as String),
      nhanVien: map['nhanVien'] as String,
      tongTien: (map['tongTien'] as num).toDouble(),
      vat: (map['VAT'] as num).toDouble(),
      giamGia: (map['giamGia'] as num).toDouble(),
    );
  }

  /// Chuyển thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ngayBan': ngayBan.toIso8601String(),
      'nhanVien': nhanVien,
      'tongTien': tongTien,
      'VAT': vat,
      'giamGia': giamGia,
    };
  }

  /// Chuyển từ Firestore
  factory Invoice.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ngayBanRaw = data['ngayBan'];
    DateTime ngayBan;
    if (ngayBanRaw is Timestamp) {
      ngayBan = ngayBanRaw.toDate();
    } else if (ngayBanRaw is String) {
      ngayBan = DateTime.parse(ngayBanRaw);
    } else {
      ngayBan = DateTime.now();
    }

    return Invoice(
      id: doc.id,
      ngayBan: ngayBan,
      nhanVien: data['nhanVien'] as String,
      tongTien: (data['tongTien'] as num).toDouble(),
      vat: (data['VAT'] as num).toDouble(),
      giamGia: (data['giamGia'] as num).toDouble(),
    );
  }

  /// Chuyển thành Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'ngayBan': Timestamp.fromDate(ngayBan),
      'nhanVien': nhanVien,
      'tongTien': tongTien,
      'VAT': vat,
      'giamGia': giamGia,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Invoice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Invoice(id: $id, ngayBan: $ngayBan, tongTien: $tongTien)';
}
