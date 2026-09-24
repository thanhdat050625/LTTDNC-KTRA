import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../utils/currency_utils.dart';
import '../../utils/validators.dart';
import '../../widgets/common/common_widgets.dart';

/// Màn hình quản lý tồn kho
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tồn kho'),
      ),
      body: Consumer<ProductProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.hasError) {
            return ErrorStateWidget(
              message: provider.errorMessage,
              onRetry: provider.loadProducts,
            );
          }

          final all = provider.allProducts;
          final lowStock =
              all.where((p) => p.isLowStock).toList();
          final outOfStock =
              all.where((p) => !p.isInStock).toList();
          final inStock = all
              .where((p) => p.isInStock && !p.isLowStock)
              .toList();

          return RefreshIndicator(
            onRefresh: provider.loadProducts,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Summary cards
                  _buildSummary(
                      inStock.length, lowStock.length, outOfStock.length),
                  const SizedBox(height: 20),

                  if (outOfStock.isNotEmpty) ...[
                    _buildSection(
                      title: 'Hết hàng',
                      products: outOfStock,
                      color: AppColors.error,
                      icon: Icons.remove_shopping_cart,
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (lowStock.isNotEmpty) ...[
                    _buildSection(
                      title:
                          'Sắp hết hàng (dưới ${AppConstants.lowStockThreshold})',
                      products: lowStock,
                      color: AppColors.warning,
                      icon: Icons.warning_amber_rounded,
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (inStock.isNotEmpty) ...[
                    _buildSection(
                      title: 'Còn hàng',
                      products: inStock,
                      color: AppColors.success,
                      icon: Icons.check_circle_outline,
                    ),
                  ],

                  if (all.isEmpty)
                    const EmptyStateWidget(
                      icon: Icons.inventory_2_outlined,
                      title: 'Chưa có sản phẩm',
                      subtitle: 'Thêm sản phẩm để quản lý tồn kho',
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummary(int inStock, int lowStock, int outOfStock) {
    final total = inStock + lowStock + outOfStock;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Tổng quan tồn kho', style: AppTextStyles.titleLargeWhite),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SummaryItem(
                count: total,
                label: 'Tổng',
                color: Colors.white,
              ),
              _SummaryItem(
                count: inStock,
                label: 'Còn hàng',
                color: Colors.greenAccent,
              ),
              _SummaryItem(
                count: lowStock,
                label: 'Sắp hết',
                color: Colors.orangeAccent,
              ),
              _SummaryItem(
                count: outOfStock,
                label: 'Hết hàng',
                color: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Product> products,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(title,
                style:
                    AppTextStyles.titleMedium.copyWith(color: color)),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${products.length}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...products.map((p) => _InventoryProductCard(
              product: p,
              statusColor: color,
              onUpdateStock: () =>
                  _showUpdateStockDialog(context, p),
            )),
      ],
    );
  }

  void _showUpdateStockDialog(BuildContext context, Product product) {
    final controller =
        TextEditingController(text: product.soLuongTon.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cập nhật tồn kho\n${product.tenSanPham}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Số lượng tồn mới',
              prefixIcon: Icon(Icons.inventory),
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
            validator: Validators.validateStock,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newStock = int.parse(controller.text.trim());
              final success = await context
                  .read<ProductProvider>()
                  .updateProduct(product.copyWith(soLuongTon: newStock));
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Cập nhật tồn kho thành công'
                        : 'Không thể cập nhật'),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withAlpha(200)),
        ),
      ],
    );
  }
}

class _InventoryProductCard extends StatelessWidget {
  final Product product;
  final Color statusColor;
  final VoidCallback onUpdateStock;

  const _InventoryProductCard({
    required this.product,
    required this.statusColor,
    required this.onUpdateStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withAlpha(60), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 6)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.tenSanPham, style: AppTextStyles.titleSmall),
                Text(
                  CurrencyUtils.format(product.donGia),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                product.soLuongTon.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
              Text('đơn vị', style: AppTextStyles.labelSmall),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.edit_note,
                color: AppColors.primary, size: 22),
            onPressed: onUpdateStock,
            tooltip: 'Cập nhật tồn kho',
          ),
        ],
      ),
    );
  }
}
