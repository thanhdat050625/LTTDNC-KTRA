import 'package:cloud_firestore/cloud_firestore.dart';

/// Chạy hàm này một lần (ví dụ trong main.dart) sau khi đã cấu hình Firebase 
/// để đẩy dữ liệu mẫu lên Cloud Firestore.
Future<void> seedFirebaseData() async {
  final firestore = FirebaseFirestore.instance;
  final productsCollection = firestore.collection('products');

  final products = [
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
  ];

  for (final product in products) {
    await productsCollection.add(product);
  }
  
  print('Đã tạo data mẫu trên Firebase thành công!');
}
