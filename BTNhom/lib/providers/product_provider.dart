import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

/// Trạng thái tải dữ liệu
enum LoadingState { idle, loading, success, error }

/// Provider quản lý state cho sản phẩm
class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  ProductProvider(this._repository) {
    loadProducts();
  }

  // ==================== STATE ====================
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  LoadingState _state = LoadingState.idle;
  String _errorMessage = '';
  String _searchQuery = '';
  ProductSortType _sortType = ProductSortType.name;
  ProductFilterType _filterType = ProductFilterType.all;

  // ==================== GETTERS ====================
  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  LoadingState get state => _state;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  ProductSortType get sortType => _sortType;
  ProductFilterType get filterType => _filterType;
  bool get isLoading => _state == LoadingState.loading;
  bool get hasError => _state == LoadingState.error;
  bool get isEmpty => _products.isEmpty && _state == LoadingState.success;

  int get totalProducts => _products.length;
  int get totalStock =>
      _products.fold(0, (sum, p) => sum + p.soLuongTon);
  List<Product> get lowStockProducts =>
      _products.where((p) => p.isLowStock).toList();
  List<Product> get outOfStockProducts =>
      _products.where((p) => !p.isInStock).toList();

  // ==================== ACTIONS ====================

  /// Tải danh sách sản phẩm
  Future<void> loadProducts() async {
    _setState(LoadingState.loading);
    try {
      final fetched = await _repository.getAll();
      _products = List.from(fetched);
      _applyFilters();
      _setState(LoadingState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(LoadingState.error);
    }
  }

  /// Tìm kiếm sản phẩm
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Sắp xếp sản phẩm
  void sort(ProductSortType type) {
    _sortType = type;
    _applyFilters();
    notifyListeners();
  }

  /// Lọc sản phẩm
  void filter(ProductFilterType type) {
    _filterType = type;
    _applyFilters();
    notifyListeners();
  }

  /// Thêm sản phẩm mới
  Future<bool> addProduct(Product product) async {
    try {
      final newProduct = await _repository.add(product);
      _products.add(newProduct);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  /// Cập nhật sản phẩm
  Future<bool> updateProduct(Product product) async {
    try {
      await _repository.update(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        _applyFilters();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  /// Xóa sản phẩm
  Future<bool> deleteProduct(String id) async {
    try {
      await _repository.delete(id);
      _products.removeWhere((p) => p.id == id);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  /// Lấy sản phẩm theo id
  Product? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ==================== PRIVATE HELPERS ====================

  void _applyFilters() {
    List<Product> result = List.from(_products);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((p) => p.tenSanPham
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply filter
    switch (_filterType) {
      case ProductFilterType.inStock:
        result = result.where((p) => p.isInStock).toList();
        break;
      case ProductFilterType.lowStock:
        result = result.where((p) => p.isLowStock).toList();
        break;
      case ProductFilterType.outOfStock:
        result = result.where((p) => !p.isInStock).toList();
        break;
      case ProductFilterType.all:
        break;
    }

    // Apply sort
    switch (_sortType) {
      case ProductSortType.name:
        result.sort((a, b) => a.tenSanPham.compareTo(b.tenSanPham));
        break;
      case ProductSortType.nameDesc:
        result.sort((a, b) => b.tenSanPham.compareTo(a.tenSanPham));
        break;
      case ProductSortType.priceAsc:
        result.sort((a, b) => a.donGia.compareTo(b.donGia));
        break;
      case ProductSortType.priceDesc:
        result.sort((a, b) => b.donGia.compareTo(a.donGia));
        break;
      case ProductSortType.stockAsc:
        result.sort((a, b) => a.soLuongTon.compareTo(b.soLuongTon));
        break;
      case ProductSortType.stockDesc:
        result.sort((a, b) => b.soLuongTon.compareTo(a.soLuongTon));
        break;
    }

    _filteredProducts = result;
  }

  void _setState(LoadingState state) {
    _state = state;
    notifyListeners();
  }

  // Refresh stock for a specific product from repository
  Future<void> refreshProduct(String id) async {
    final updated = await _repository.getById(id);
    if (updated != null) {
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updated;
        _applyFilters();
        notifyListeners();
      }
    }
  }
}

enum ProductSortType {
  name,
  nameDesc,
  priceAsc,
  priceDesc,
  stockAsc,
  stockDesc,
}

enum ProductFilterType {
  all,
  inStock,
  lowStock,
  outOfStock,
}
