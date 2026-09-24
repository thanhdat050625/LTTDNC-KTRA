import 'package:cloud_firestore/cloud_firestore.dart';

/// Model đại diện cho chi tiết một dòng trong hóa đơn
class InvoiceDetail {
  final String id;
  final String invoiceId;
  final String productId;
  final String tenSanPham; // Lưu snapshot tên sản phẩm lúc bán
  final int soLuong;
  final double donGia;    // Snapshot đơn giá lúc bán

  const InvoiceDetail({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.tenSanPham,
    required this.soLuong,
    required this.donGia,
  });

  /// Thành tiền = số lượng × đơn giá
  double get thanhTien => soLuong * donGia;

  /// Tạo bản sao với các trường được cập nhật
  InvoiceDetail copyWith({
    String? id,
    String? invoiceId,
    String? productId,
    String? tenSanPham,
    int? soLuong,
    double? donGia,
  }) {
    return InvoiceDetail(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      tenSanPham: tenSanPham ?? this.tenSanPham,
      soLuong: soLuong ?? this.soLuong,
      donGia: donGia ?? this.donGia,
    );
  }

  /// Chuyển từ Map
  factory InvoiceDetail.fromMap(String id, Map<String, dynamic> map) {
    return InvoiceDetail(
      id: id,
      invoiceId: map['invoiceId'] as String,
      productId: map['productId'] as String,
      tenSanPham: map['tenSanPham'] as String? ?? '',
      soLuong: (map['soLuong'] as num).toInt(),
      donGia: (map['donGia'] as num).toDouble(),
    );
  }

  /// Chuyển thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'productId': productId,
      'tenSanPham': tenSanPham,
      'soLuong': soLuong,
      'donGia': donGia,
      'thanhTien': thanhTien,
    };
  }

  /// Chuyển từ Firestore
  factory InvoiceDetail.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvoiceDetail(
      id: doc.id,
      invoiceId: data['invoiceId'] as String,
      productId: data['productId'] as String,
      tenSanPham: data['tenSanPham'] as String? ?? '',
      soLuong: (data['soLuong'] as num).toInt(),
      donGia: (data['donGia'] as num).toDouble(),
    );
  }

  /// Chuyển thành Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'invoiceId': invoiceId,
      'productId': productId,
      'tenSanPham': tenSanPham,
      'soLuong': soLuong,
      'donGia': donGia,
      'thanhTien': thanhTien,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceDetail &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'InvoiceDetail(id: $id, productId: $productId, soLuong: $soLuong, donGia: $donGia)';
}
