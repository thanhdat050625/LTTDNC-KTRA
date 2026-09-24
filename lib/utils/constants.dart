/// Các hằng số toàn cục của ứng dụng
class AppConstants {
  AppConstants._();

  // ==================== BUSINESS RULES ====================

  /// Thuế VAT: 10%
  static const double vatRate = 0.10;

  /// Ngưỡng áp dụng giảm giá (VNĐ)
  static const double discountThreshold = 500000;

  /// Tỉ lệ giảm giá khi đủ điều kiện: 5%
  static const double discountRate = 0.05;

  // ==================== INVENTORY ====================

  /// Ngưỡng cảnh báo sắp hết hàng
  static const int lowStockThreshold = 5;

  // ==================== UI ====================

  /// Tên ứng dụng
  static const String appName = 'Grocery Store';

  /// Tên ứng dụng đầy đủ
  static const String appFullName = 'Quản Lý Cửa Hàng Tạp Hóa';

  // ==================== FIRESTORE COLLECTIONS ====================
  static const String productsCollection = 'products';
  static const String invoicesCollection = 'invoices';
  static const String invoiceDetailsCollection = 'invoice_details';

  // ==================== MOCK DATA ====================

  static const String mockEmployee = 'Nhân viên A';

  /// Mock products seed data
  static const List<Map<String, dynamic>> mockProducts = [
    {
      'tenSanPham': 'Sữa tươi 1L',
      'donGia': 28000.0,
      'soLuongTon': 50,
    },
    {
      'tenSanPham': 'Bánh mì',
      'donGia': 12000.0,
      'soLuongTon': 100,
    },
    {
      'tenSanPham': 'Nước ngọt',
      'donGia': 15000.0,
      'soLuongTon': 80,
    },
    {
      'tenSanPham': 'Gạo 5kg',
      'donGia': 150000.0,
      'soLuongTon': 30,
    },
    {
      'tenSanPham': 'Dầu ăn 1L',
      'donGia': 45000.0,
      'soLuongTon': 25,
    },
    {
      'tenSanPham': 'Mì tôm (gói)',
      'donGia': 5000.0,
      'soLuongTon': 200,
    },
    {
      'tenSanPham': 'Trứng gà (vỉ 10)',
      'donGia': 35000.0,
      'soLuongTon': 40,
    },
    {
      'tenSanPham': 'Muối tinh',
      'donGia': 8000.0,
      'soLuongTon': 3,
    },
  ];
}
