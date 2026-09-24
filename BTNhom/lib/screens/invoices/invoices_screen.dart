import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invoice.dart';
import '../../providers/invoice_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/currency_utils.dart';
import '../../utils/date_utils.dart';
import '../../widgets/common/common_widgets.dart';
import '../invoice_detail/invoice_detail_screen.dart';

/// Màn hình danh sách hóa đơn
class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hóa đơn'),
      ),
      body: Consumer<InvoiceProvider>(
        builder: (_, provider, __) {
          if (provider.isListLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.listState.name == 'error') {
            return ErrorStateWidget(
              message: provider.listError,
              onRetry: provider.loadInvoices,
            );
          }

          if (provider.invoices.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'Chưa có hóa đơn',
              subtitle: 'Tạo hóa đơn đầu tiên từ tab Tạo hóa đơn',
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadInvoices,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              itemCount: provider.invoices.length,
              itemBuilder: (context, index) {
                final invoice = provider.invoices[index];
                return _InvoiceCard(
                  invoice: invoice,
                  index: index,
                  onTap: () => _openDetail(context, invoice),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _openDetail(BuildContext context, Invoice invoice) async {
    final provider = context.read<InvoiceProvider>();
    final navigator = Navigator.of(context);
    final full = await provider.getInvoiceById(invoice.id);
    if (!mounted) return;
    if (full != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => InvoiceDetailScreen(invoice: full),
        ),
      );
    }
  }
}

// ==================== INVOICE CARD ====================

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;
  final int index;

  const _InvoiceCard({
    required this.invoice,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 50),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - v)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.receipt_long,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HĐ #${invoice.id.substring(0, 8).toUpperCase()}',
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppDateUtils.formatDateTime(invoice.ngayBan),
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyUtils.format(invoice.tongTien),
                            style: AppTextStyles.currency.copyWith(fontSize: 15),
                          ),
                          if (invoice.hasDiscount)
                            StatusChip(
                              label: 'Đã giảm giá',
                              color: AppColors.success,
                              backgroundColor: AppColors.successLight,
                              icon: Icons.local_offer,
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(invoice.nhanVien,
                          style: AppTextStyles.labelMedium),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Text('Xem chi tiết',
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.primary)),
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
}
