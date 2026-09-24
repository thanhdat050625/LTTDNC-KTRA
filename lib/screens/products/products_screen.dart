import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart' as shimmer;
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/currency_utils.dart';
import '../../utils/validators.dart';
import '../../widgets/common/common_widgets.dart';

/// Màn hình quản lý sản phẩm
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late AnimationController _fabAnimController;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sản phẩm'),
        actions: [
          PopupMenuButton<ProductSortType>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sắp xếp',
            onSelected: (type) =>
                context.read<ProductProvider>().sort(type),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: ProductSortType.name,
                child: Row(children: [Icon(Icons.sort_by_alpha), SizedBox(width: 8), Text('Tên A-Z')]),
              ),
              const PopupMenuItem(
                value: ProductSortType.nameDesc,
                child: Row(children: [Icon(Icons.sort_by_alpha), SizedBox(width: 8), Text('Tên Z-A')]),
              ),
              const PopupMenuItem(
                value: ProductSortType.priceAsc,
                child: Row(children: [Icon(Icons.arrow_upward), SizedBox(width: 8), Text('Giá tăng dần')]),
              ),
              const PopupMenuItem(
                value: ProductSortType.priceDesc,
                child: Row(children: [Icon(Icons.arrow_downward), SizedBox(width: 8), Text('Giá giảm dần')]),
              ),
              const PopupMenuItem(
                value: ProductSortType.stockDesc,
                child: Row(children: [Icon(Icons.inventory_2), SizedBox(width: 8), Text('Tồn kho nhiều nhất')]),
              ),
              const PopupMenuItem(
                value: ProductSortType.stockAsc,
                child: Row(children: [Icon(Icons.inventory_2_outlined), SizedBox(width: 8), Text('Tồn kho ít nhất')]),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter bar
          _buildSearchAndFilter(),
          // Product list
          Expanded(child: _buildProductList()),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimController,
        child: FloatingActionButton.extended(
          onPressed: () => _showProductForm(context),
          icon: const Icon(Icons.add),
          label: const Text('Thêm sản phẩm'),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppSearchBar(
            controller: _searchController,
            hintText: 'Tìm kiếm sản phẩm...',
            onChanged: (query) =>
                context.read<ProductProvider>().search(query),
            onClear: () => context.read<ProductProvider>().search(''),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Consumer<ProductProvider>(
              builder: (_, provider, __) => Row(
                children: [
                  _FilterChip(
                    label: 'Tất cả',
                    isSelected:
                        provider.filterType == ProductFilterType.all,
                    onSelected: () =>
                        provider.filter(ProductFilterType.all),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Còn hàng',
                    isSelected:
                        provider.filterType == ProductFilterType.inStock,
                    onSelected: () =>
                        provider.filter(ProductFilterType.inStock),
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Sắp hết',
                    isSelected:
                        provider.filterType == ProductFilterType.lowStock,
                    onSelected: () =>
                        provider.filter(ProductFilterType.lowStock),
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Hết hàng',
                    isSelected:
                        provider.filterType == ProductFilterType.outOfStock,
                    onSelected: () =>
                        provider.filter(ProductFilterType.outOfStock),
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return _buildSkeletonList();
        }

        if (provider.hasError) {
          return ErrorStateWidget(
            message: provider.errorMessage,
            onRetry: provider.loadProducts,
          );
        }

        if (provider.products.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.inventory_2_outlined,
            title: provider.searchQuery.isNotEmpty
                ? 'Không tìm thấy sản phẩm'
                : 'Chưa có sản phẩm',
            subtitle: provider.searchQuery.isNotEmpty
                ? 'Thử tìm kiếm với từ khóa khác'
                : 'Nhấn nút bên dưới để thêm sản phẩm mới',
            actionLabel:
                provider.searchQuery.isEmpty ? 'Thêm sản phẩm' : null,
            onAction: provider.searchQuery.isEmpty
                ? () => _showProductForm(context)
                : null,
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadProducts,
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              return _ProductCard(
                product: product,
                onEdit: () => _showProductForm(context, product: product),
                onDelete: () => _confirmDelete(context, product),
                index: index,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: shimmer.Shimmer.fromColors(
            baseColor: AppColors.border,
            highlightColor: AppColors.surfaceVariant,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showProductForm(BuildContext context, {Product? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFormSheet(
        product: product,
        onSave: (p) async {
          final provider = context.read<ProductProvider>();
          bool success;
          if (product == null) {
            success = await provider.addProduct(p);
          } else {
            success = await provider.updateProduct(p);
          }
          if (context.mounted) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(product == null
                      ? 'Đã thêm sản phẩm thành công!'
                      : 'Đã cập nhật sản phẩm!'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.errorMessage),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận xóa'),
        content: Text(
            'Bạn có chắc muốn xóa sản phẩm "${product.tenSanPham}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<ProductProvider>()
                  .deleteProduct(product.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Đã xóa sản phẩm'
                        : 'Không thể xóa sản phẩm'),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

// ==================== PRODUCT CARD ====================

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int index;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 50),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon sản phẩm
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.shopping_basket,
                        color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  // Thông tin sản phẩm
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.tenSanPham,
                            style: AppTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyUtils.format(product.donGia),
                          style: AppTextStyles.currency
                              .copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        _buildStockStatus(),
                      ],
                    ),
                  ),
                  // Actions
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: AppColors.primary, size: 20),
                        onPressed: onEdit,
                        tooltip: 'Chỉnh sửa',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error, size: 20),
                        onPressed: onDelete,
                        tooltip: 'Xóa',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockStatus() {
    if (!product.isInStock) {
      return StatusChip(
        label: 'Hết hàng',
        color: AppColors.error,
        backgroundColor: AppColors.errorLight,
        icon: Icons.remove_shopping_cart,
      );
    } else if (product.isLowStock) {
      return StatusChip(
        label: 'Sắp hết: ${product.soLuongTon}',
        color: AppColors.warning,
        backgroundColor: AppColors.warningLight,
        icon: Icons.warning_amber_rounded,
      );
    } else {
      return StatusChip(
        label: 'Tồn kho: ${product.soLuongTon}',
        color: AppColors.success,
        backgroundColor: AppColors.successLight,
        icon: Icons.check_circle_outline,
      );
    }
  }
}

// ==================== PRODUCT FORM SHEET ====================

class ProductFormSheet extends StatefulWidget {
  final Product? product;
  final Future<void> Function(Product) onSave;

  const ProductFormSheet({
    super.key,
    this.product,
    required this.onSave,
  });

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.product?.tenSanPham ?? '');
    _priceController = TextEditingController(
        text: widget.product?.donGia.toInt().toString() ?? '');
    _stockController = TextEditingController(
        text: widget.product?.soLuongTon.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isEdit ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm *',
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                  validator: Validators.validateProductName,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Đơn giá (VNĐ) *',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: Validators.validatePrice,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                          labelText: 'Tồn kho *',
                          prefixIcon: Icon(Icons.inventory),
                        ),
                        keyboardType: TextInputType.number,
                        validator: Validators.validateStock,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(isEdit ? 'Cập nhật' : 'Thêm sản phẩm'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final product = Product(
      id: widget.product?.id ?? '',
      tenSanPham: _nameController.text.trim(),
      donGia: double.parse(
          _priceController.text.replaceAll(',', '').replaceAll('.', '')),
      soLuongTon: int.parse(_stockController.text.trim()),
    );

    await widget.onSave(product);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}

// ==================== FILTER CHIP ====================
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
