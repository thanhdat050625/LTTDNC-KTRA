import 'package:cloud_firestore/cloud_firestore.dart';

/// Model đại diện cho một sản phẩm trong cửa hàng
class Product {
  final String id;
  final String tenSanPham;
  final double donGia;
  final int soLuongTon;

  const Product({
    required this.id,
    required this.tenSanPham,
    required this.donGia,
    required this.soLuongTon,
  });

  /// Kiểm tra sản phẩm có còn hàng không
  bool get isInStock => soLuongTon > 0;

  /// Kiểm tra sản phẩm sắp hết hàng (dưới 5)
  bool get isLowStock => soLuongTon > 0 && soLuongTon <= 5;

  /// Kiểm tra sản phẩm có đủ số lượng cần mua không
  bool hasEnoughStock(int quantity) => soLuongTon >= quantity;

  /// Tạo bản sao với các trường được cập nhật
  Product copyWith({
    String? id,
    String? tenSanPham,
    double? donGia,
    int? soLuongTon,
  }) {
    return Product(
      id: id ?? this.id,
      tenSanPham: tenSanPham ?? this.tenSanPham,
      donGia: donGia ?? this.donGia,
      soLuongTon: soLuongTon ?? this.soLuongTon,
    );
  }

  /// Chuyển từ Map (dùng cho mock data)
  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      tenSanPham: map['tenSanPham'] as String,
      donGia: (map['donGia'] as num).toDouble(),
      soLuongTon: (map['soLuongTon'] as num).toInt(),
    );
  }

  /// Chuyển thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenSanPham': tenSanPham,
      'donGia': donGia,
      'soLuongTon': soLuongTon,
    };
  }

  /// Chuyển từ Firestore DocumentSnapshot
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      tenSanPham: data['tenSanPham'] as String,
      donGia: (data['donGia'] as num).toDouble(),
      soLuongTon: (data['soLuongTon'] as num).toInt(),
    );
  }

  /// Chuyển thành Firestore data map (không có 'id' field)
  Map<String, dynamic> toFirestore() {
    return {
      'tenSanPham': tenSanPham,
      'donGia': donGia,
      'soLuongTon': soLuongTon,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Product(id: $id, tenSanPham: $tenSanPham, donGia: $donGia, soLuongTon: $soLuongTon)';
}
