import 'package:flutter/foundation.dart';
import '../models/invoice.dart';
import '../models/invoice_detail.dart';
import '../models/product.dart';
import '../repositories/invoice_repository.dart';
import '../repositories/product_repository.dart';
import 'product_provider.dart';

/// Trạng thái của cart item (sản phẩm trong hóa đơn đang tạo)
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get subtotal => product.donGia * quantity;

  InvoiceDetail toInvoiceDetail(String invoiceId) {
    return InvoiceDetail(
      id: '',
      invoiceId: invoiceId,
      productId: product.id,
      tenSanPham: product.tenSanPham,
      soLuong: quantity,
      donGia: product.donGia,
    );
  }
}

/// Provider quản lý state cho hóa đơn
class InvoiceProvider extends ChangeNotifier {
  final InvoiceRepository _invoiceRepository;
  final ProductRepository _productRepository;

  InvoiceProvider(this._invoiceRepository, this._productRepository);

  // ==================== INVOICE LIST STATE ====================
  List<Invoice> _invoices = [];
  LoadingState _listState = LoadingState.idle;
  String _listError = '';

  List<Invoice> get invoices => _invoices;
  LoadingState get listState => _listState;
  String get listError => _listError;
  bool get isListLoading => _listState == LoadingState.loading;

  // ==================== CART STATE (Tạo hóa đơn) ====================
  final List<CartItem> _cartItems = [];
  String _employee = 'Nhân viên A';
  LoadingState _saveState = LoadingState.idle;
  String _saveError = '';
  Invoice? _lastSavedInvoice;

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  String get employee => _employee;
  LoadingState get saveState => _saveState;
  String get saveError => _saveError;
  Invoice? get lastSavedInvoice => _lastSavedInvoice;
  bool get isSaving => _saveState == LoadingState.loading;
  bool get cartIsEmpty => _cartItems.isEmpty;

  // ==================== CART CALCULATIONS ====================

  /// Tạm tính
  double get subtotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

  /// VAT = tạm tính × 10%
  double get vat => Invoice.calculateVat(subtotal);

  /// Giảm giá
  double get discount => Invoice.calculateDiscount(subtotal);

  /// Tổng thanh toán
  double get total => Invoice.calculateTotal(subtotal, vat, discount);

  /// Tổng số sản phẩm trong cart
  int get totalItems =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  bool get hasDiscount => discount > 0;

  // ==================== CART ACTIONS ====================

  void setEmployee(String name) {
    _employee = name;
    notifyListeners();
  }

  /// Thêm sản phẩm vào giỏ hàng hoặc tăng số lượng nếu đã có
  String? addToCart(Product product, int quantity) {
    if (quantity <= 0) return 'Số lượng phải lớn hơn 0';
    if (!product.isInStock) return 'Sản phẩm đã hết hàng';

    final existingIndex =
        _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      final existing = _cartItems[existingIndex];
      final newQty = existing.quantity + quantity;
      if (newQty > product.soLuongTon) {
        return 'Vượt quá tồn kho. Hiện còn: ${product.soLuongTon}, đã thêm: ${existing.quantity}';
      }
      _cartItems[existingIndex].quantity = newQty;
    } else {
      if (quantity > product.soLuongTon) {
        return 'Số lượng vượt quá tồn kho (còn ${product.soLuongTon})';
      }
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }

    notifyListeners();
    return null; // null = thành công
  }

  /// Thay đổi số lượng trực tiếp trong cart
  String? updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(productId);
      return null;
    }

    final index =
        _cartItems.indexWhere((item) => item.product.id == productId);
    if (index == -1) return 'Sản phẩm không có trong giỏ hàng';

    final item = _cartItems[index];
    if (newQuantity > item.product.soLuongTon) {
      return 'Vượt quá tồn kho (còn ${item.product.soLuongTon})';
    }

    _cartItems[index].quantity = newQuantity;
    notifyListeners();
    return null;
  }

  /// Xóa sản phẩm khỏi cart
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  /// Xóa toàn bộ cart
  void clearCart() {
    _cartItems.clear();
    _employee = 'Nhân viên A';
    _saveState = LoadingState.idle;
    _saveError = '';
    _lastSavedInvoice = null;
    notifyListeners();
  }

  // ==================== SAVE INVOICE ====================

  /// Lưu hóa đơn và trừ tồn kho
  Future<bool> saveInvoice() async {
    if (_cartItems.isEmpty) {
      _saveError = 'Hóa đơn không có sản phẩm';
      notifyListeners();
      return false;
    }

    _saveState = LoadingState.loading;
    _saveError = '';
    notifyListeners();

    try {
      // Tạo danh sách InvoiceDetail từ cart
      final details = _cartItems
          .map((item) => item.toInvoiceDetail(''))
          .toList();

      // Tạo hóa đơn
      final invoice = Invoice.calculate(
        id: '',
        ngayBan: DateTime.now(),
        nhanVien: _employee,
        details: details,
      );

      // Lưu hóa đơn
      final savedInvoice =
          await _invoiceRepository.create(invoice, details);

      // Trừ tồn kho cho từng sản phẩm
      for (final item in _cartItems) {
        await _productRepository.updateStock(item.product.id, -item.quantity);
      }

      _lastSavedInvoice = savedInvoice;
      _saveState = LoadingState.success;

      // Cập nhật danh sách hóa đơn
      await loadInvoices();

      notifyListeners();
      return true;
    } catch (e) {
      _saveError = 'Lưu hóa đơn thất bại: ${e.toString()}';
      _saveState = LoadingState.error;
      notifyListeners();
      return false;
    }
  }

  // ==================== INVOICE LIST ====================

  Future<void> loadInvoices() async {
    _listState = LoadingState.loading;
    notifyListeners();
    try {
      _invoices = await _invoiceRepository.getAll();
      _listState = LoadingState.success;
    } catch (e) {
      _listError = e.toString();
      _listState = LoadingState.error;
    }
    notifyListeners();
  }

  Future<Invoice?> getInvoiceById(String id) async {
    return _invoiceRepository.getById(id);
  }
}
