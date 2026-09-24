import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../utils/currency_utils.dart';
import '../../widgets/common/common_widgets.dart';
import '../invoice_detail/invoice_detail_screen.dart';

/// Màn hình tạo hóa đơn mới
class InvoiceCreateScreen extends StatefulWidget {
  const InvoiceCreateScreen({super.key});

  @override
  State<InvoiceCreateScreen> createState() => _InvoiceCreateScreenState();
}

class _InvoiceCreateScreenState extends State<InvoiceCreateScreen> {
  final _employeeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final invoiceProvider =
        context.read<InvoiceProvider>();
    _employeeController.text = invoiceProvider.employee;
  }

  @override
  void dispose() {
    _employeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tạo hóa đơn'),
        actions: [
          Consumer<InvoiceProvider>(
            builder: (_, provider, __) => provider.cartIsEmpty
                ? const SizedBox.shrink()
                : TextButton.icon(
                    onPressed: () => _confirmClearCart(context),
                    icon: const Icon(Icons.clear_all, color: Colors.white),
                    label: const Text('Xóa tất cả',
                        style: TextStyle(color: Colors.white)),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Employee info
                  _buildEmployeeSection(),
                  // Product selector
                  _buildProductSection(),
                  // Cart items
                  _buildCartSection(),
                  // Summary
                  _buildSummarySection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCheckoutBar(),
    );
  }

  Widget _buildEmployeeSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _employeeController,
              decoration: const InputDecoration(
                labelText: 'Nhân viên bán hàng',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (v) =>
                  context.read<InvoiceProvider>().setEmployee(v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Chọn sản phẩm', style: AppTextStyles.titleLarge),
              TextButton.icon(
                onPressed: () => _showProductPicker(context),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Thêm'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Consumer<ProductProvider>(
            builder: (_, provider, __) {
              final available =
                  provider.allProducts.where((p) => p.isInStock).toList();
              if (available.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Không có sản phẩm nào còn hàng'),
                  ),
                );
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: available
                    .map((p) => _QuickAddChip(
                          product: p,
                          onTap: () => _quickAdd(context, p),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartSection() {
    return Consumer<InvoiceProvider>(
      builder: (_, provider, __) {
        if (provider.cartIsEmpty) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
            ),
            child: Column(
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 56, color: AppColors.border),
                const SizedBox(height: 12),
                Text('Chưa có sản phẩm nào trong hóa đơn',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sản phẩm trong hóa đơn',
                        style: AppTextStyles.titleLarge),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${provider.cartItems.length} loại',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...provider.cartItems
                  .map((item) => _CartItemTile(
                        item: item,
                        onQuantityChanged: (qty) {
                          final error = context
                              .read<InvoiceProvider>()
                              .updateQuantity(item.product.id, qty);
                          if (error != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(error),
                                  backgroundColor: AppColors.error),
                            );
                          }
                        },
                        onRemove: () => context
                            .read<InvoiceProvider>()
                            .removeFromCart(item.product.id),
                      ))
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummarySection() {
    return Consumer<InvoiceProvider>(
      builder: (_, provider, __) {
        if (provider.cartIsEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tổng kết', style: AppTextStyles.titleLarge),
              const SizedBox(height: 16),
              _SummaryRow(
                  label: 'Tạm tính',
                  value: CurrencyUtils.format(provider.subtotal)),
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'VAT (${(AppConstants.vatRate * 100).toInt()}%)',
                value: CurrencyUtils.format(provider.vat),
                valueColor: AppColors.info,
              ),
              if (provider.hasDiscount) ...[
                const SizedBox(height: 8),
                _SummaryRow(
                  label:
                      'Giảm giá (${(AppConstants.discountRate * 100).toInt()}%)',
                  value: '- ${CurrencyUtils.format(provider.discount)}',
                  valueColor: AppColors.success,
                  note:
                      'HĐ > ${CurrencyUtils.format(AppConstants.discountThreshold)}',
                ),
              ] else if (provider.subtotal > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Thêm ${CurrencyUtils.format(AppConstants.discountThreshold - provider.subtotal)} để được giảm 5%',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'Tổng thanh toán',
                value: CurrencyUtils.format(provider.total),
                isTotal: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckoutBar() {
    return Consumer<InvoiceProvider>(
      builder: (_, provider, __) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tổng thanh toán', style: AppTextStyles.labelMedium),
                    Text(
                      CurrencyUtils.format(provider.total),
                      style: AppTextStyles.currency.copyWith(fontSize: 20),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.cartIsEmpty || provider.isSaving
                        ? null
                        : () => _checkout(context, provider),
                    icon: provider.isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                        provider.isSaving ? 'Đang lưu...' : 'Thanh toán'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkout(
      BuildContext context, InvoiceProvider provider) async {
    if (provider.employee.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên nhân viên'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final success = await provider.saveInvoice();

    if (!mounted) return;

    if (success && provider.lastSavedInvoice != null) {
      final savedInvoice = provider.lastSavedInvoice!;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Hóa đơn đã được lưu thành công! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to invoice detail
      navigator.push(
        MaterialPageRoute(
          builder: (_) => InvoiceDetailScreen(
            invoice: savedInvoice,
          ),
        ),
      );

      // Clear cart sau khi checkout thành công
      provider.clearCart();

      // Refresh product stock
      if (mounted) {
        context.read<ProductProvider>().loadProducts();
      }
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(provider.saveError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _quickAdd(BuildContext context, Product product) {
    final error = context.read<InvoiceProvider>().addToCart(product, 1);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  void _showProductPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ProductPickerSheet(),
    );
  }

  void _confirmClearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xóa toàn bộ giỏ hàng?'),
        content: const Text('Tất cả sản phẩm trong hóa đơn sẽ bị xóa.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              context.read<InvoiceProvider>().clearCart();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

// ==================== CART ITEM TILE ====================

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_basket,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.tenSanPham,
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(CurrencyUtils.format(item.product.donGia),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          // Quantity controls
          Row(
            children: [
              _QuantityButton(
                icon: Icons.remove,
                onTap: () => onQuantityChanged(item.quantity - 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  item.quantity.toString(),
                  style: AppTextStyles.titleMedium,
                ),
              ),
              _QuantityButton(
                icon: Icons.add,
                onTap: () => onQuantityChanged(item.quantity + 1),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close,
                    size: 18, color: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}

// ==================== PRODUCT PICKER SHEET ====================

class _ProductPickerSheet extends StatefulWidget {
  const _ProductPickerSheet();

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  Product? _selected;
  final _qtyController = TextEditingController(text: '1');
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _qtyController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Chọn sản phẩm', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),
          AppSearchBar(
            controller: _searchController,
            hintText: 'Tìm sản phẩm...',
            onChanged: (v) => setState(() => _search = v),
            onClear: () => setState(() => _search = ''),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (_, provider, __) {
                final products = provider.allProducts
                    .where((p) =>
                        p.isInStock &&
                        p.tenSanPham.toLowerCase().contains(_search.toLowerCase()))
                    .toList();

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final p = products[i];
                    final isSelected = _selected?.id == p.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryContainer
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.shopping_basket,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        title: Text(p.tenSanPham,
                            style: AppTextStyles.titleSmall),
                        subtitle: Text(
                          '${CurrencyUtils.format(p.donGia)} • Còn ${p.soLuongTon}',
                          style: AppTextStyles.bodySmall,
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: AppColors.primary)
                            : null,
                        onTap: () => setState(() => _selected = p),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_selected != null) ...[
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyController,
                    decoration: const InputDecoration(
                      labelText: 'Số lượng',
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Thêm'),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _addToCart() {
    if (_selected == null) return;
    final qty = int.tryParse(_qtyController.text) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Số lượng không hợp lệ'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    final error =
        context.read<InvoiceProvider>().addToCart(_selected!, qty);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } else {
      Navigator.pop(context);
    }
  }
}

// ==================== QUICK ADD CHIP ====================

class _QuickAddChip extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _QuickAddChip({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              product.tenSanPham,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SUMMARY ROW ====================

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;
  final String? note;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: isTotal
                  ? AppTextStyles.titleMedium
                  : AppTextStyles.bodyMedium,
            ),
            if (note != null)
              Text(note!,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.success)),
          ],
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.currency.copyWith(fontSize: 20)
              : AppTextStyles.bodyMedium.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }
}
