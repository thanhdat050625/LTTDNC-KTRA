import '../models/product.dart';

/// Interface định nghĩa các thao tác với Product
/// Giúp dễ dàng chuyển đổi giữa mock data và Firestore
abstract class ProductRepository {
  /// Lấy tất cả sản phẩm
  Future<List<Product>> getAll();

  /// Lấy sản phẩm theo id
  Future<Product?> getById(String id);

  /// Thêm sản phẩm mới, trả về sản phẩm đã được thêm (với id)
  Future<Product> add(Product product);

  /// Cập nhật sản phẩm
  Future<void> update(Product product);

  /// Xóa sản phẩm theo id
  Future<void> delete(String id);

  /// Cập nhật số lượng tồn kho
  /// [delta] có thể âm (giảm tồn) hoặc dương (tăng tồn)
  Future<void> updateStock(String productId, int delta);

  /// Stream danh sách sản phẩm (realtime cho Firestore)
  Stream<List<Product>> watchAll();
}
