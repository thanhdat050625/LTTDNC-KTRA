/// Validators cho form validation
class Validators {
  Validators._();

  /// Validate tên sản phẩm
  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tên sản phẩm không được để trống';
    }
    if (value.trim().length < 2) {
      return 'Tên sản phẩm phải có ít nhất 2 ký tự';
    }
    return null;
  }

  /// Validate đơn giá
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Đơn giá không được để trống';
    }
    final price = double.tryParse(value.replaceAll(',', '').replaceAll('.', ''));
    if (price == null) {
      return 'Đơn giá không hợp lệ';
    }
    if (price <= 0) {
      return 'Đơn giá phải lớn hơn 0';
    }
    return null;
  }

  /// Validate số lượng tồn kho
  static String? validateStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số lượng tồn không được để trống';
    }
    final qty = int.tryParse(value.trim());
    if (qty == null) {
      return 'Số lượng tồn không hợp lệ';
    }
    if (qty < 0) {
      return 'Số lượng tồn phải >= 0';
    }
    return null;
  }

  /// Validate số lượng mua
  static String? validateQuantity(String? value, {int maxStock = 999999}) {
    if (value == null || value.trim().isEmpty) {
      return 'Số lượng không được để trống';
    }
    final qty = int.tryParse(value.trim());
    if (qty == null) {
      return 'Số lượng không hợp lệ';
    }
    if (qty <= 0) {
      return 'Số lượng phải lớn hơn 0';
    }
    if (qty > maxStock) {
      return 'Số lượng vượt quá tồn kho (còn $maxStock)';
    }
    return null;
  }

  /// Validate tên nhân viên
  static String? validateEmployee(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tên nhân viên không được để trống';
    }
    return null;
  }
}
