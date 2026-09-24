import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../models/product.dart';
import '../../repositories/product_repository.dart';
import '../../utils/constants.dart';

/// Triển khai ProductRepository dùng mock/in-memory data
/// Dùng khi Firebase chưa được cấu hình
class MockProductRepository implements ProductRepository {
  final _uuid = const Uuid();
  final List<Product> _products = [];
  final _streamController = StreamController<List<Product>>.broadcast();

  MockProductRepository() {
    _seedData();
  }

  /// Khởi tạo dữ liệu mẫu
  void _seedData() {
    for (final data in AppConstants.mockProducts) {
      final product = Product.fromMap(_uuid.v4(), data);
      _products.add(product);
    }
    _notify();
  }

  void _notify() {
    _streamController.add(List.unmodifiable(_products));
  }

  @override
  Future<List<Product>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate async
    return List.unmodifiable(_products);
  }

  @override
  Future<Product?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Product> add(Product product) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final newProduct = product.copyWith(id: _uuid.v4());
    _products.add(newProduct);
    _notify();
    return newProduct;
  }

  @override
  Future<void> update(Product product) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index == -1) throw Exception('Sản phẩm không tồn tại');
    _products[index] = product;
    _notify();
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) throw Exception('Sản phẩm không tồn tại');
    _products.removeAt(index);
    _notify();
  }

  @override
  Future<void> updateStock(String productId, int delta) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) throw Exception('Sản phẩm không tồn tại');

    final current = _products[index];
    final newStock = current.soLuongTon + delta;
    if (newStock < 0) {
      throw Exception(
          'Không đủ tồn kho. Hiện có: ${current.soLuongTon}, cần giảm: ${delta.abs()}');
    }
    _products[index] = current.copyWith(soLuongTon: newStock);
    _notify();
  }

  @override
  Stream<List<Product>> watchAll() => _streamController.stream;

  void dispose() {
    _streamController.close();
  }
}
