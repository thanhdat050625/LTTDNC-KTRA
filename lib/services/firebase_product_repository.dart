import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase/firebase_config.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore;

  FirebaseProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _checkAndSeedInitialProducts();
  }

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirebaseConfig.productsCollection);

  /// Tự động nạp danh mục sản phẩm mẫu theo đề bài nếu Firestore đang trống
  Future<void> _checkAndSeedInitialProducts() async {
    try {
      final snapshot = await _collection.limit(1).get();
      if (snapshot.docs.isEmpty) {
        final initialProducts = [
          {'tenSanPham': 'Sữa tươi 1L', 'donGia': 28000.0, 'soLuongTon': 50},
          {'tenSanPham': 'Bánh mì', 'donGia': 12000.0, 'soLuongTon': 100},
          {'tenSanPham': 'Nước ngọt', 'donGia': 15000.0, 'soLuongTon': 80},
          {'tenSanPham': 'Gạo 5kg', 'donGia': 150000.0, 'soLuongTon': 30},
        ];
        for (final item in initialProducts) {
          await _collection.add(item);
        }
      }
    } catch (_) {}
  }

  @override
  Future<List<Product>> getAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  @override
  Future<Product?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Product.fromFirestore(doc);
  }

  @override
  Future<Product> add(Product product) async {
    final docRef = await _collection.add(product.toFirestore());
    return product.copyWith(id: docRef.id);
  }

  @override
  Future<void> update(Product product) async {
    await _collection.doc(product.id).update(product.toFirestore());
  }

  @override
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<void> updateStock(String productId, int delta) async {
    final docRef = _collection.doc(productId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception('Sản phẩm không tồn tại');
      }
      final currentStock = (snapshot.data()?['soLuongTon'] as num?)?.toInt() ?? 0;
      final newStock = currentStock + delta;
      if (newStock < 0) {
        throw Exception('Không đủ tồn kho. Tồn: $currentStock, cần trừ: ${delta.abs()}');
      }
      transaction.update(docRef, {'soLuongTon': newStock});
    });
  }

  @override
  Stream<List<Product>> watchAll() {
    return _collection.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
    );
  }
}
