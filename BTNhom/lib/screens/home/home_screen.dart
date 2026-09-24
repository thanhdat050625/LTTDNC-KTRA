import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/revenue_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../utils/currency_utils.dart';
import '../../utils/date_utils.dart';
import '../../widgets/common/common_widgets.dart';

/// Màn hình Dashboard tổng quan
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RevenueProvider>().loadAll();
      context.read<InvoiceProvider>().loadInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTopStats(),
                  const SizedBox(height: 20),
                  _buildRevenueChart(),
                  const SizedBox(height: 20),
                  _buildLowStockWarning(),
                  const SizedBox(height: 20),
                  _buildRecentInvoices(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.revenueGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppDateUtils.formatDayName(DateTime.now()),
                            style: AppTextStyles.bodySmallWhite,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppConstants.appName,
                            style: AppTextStyles.displayLargeWhite
                                .copyWith(fontSize: 26),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.store,
                            color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Revenue today
                  Consumer<RevenueProvider>(
                    builder: (_, provider, __) {
                      final todayRevenue =
                          provider.dayStats?.totalRevenue ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Hôm nay: ${CurrencyUtils.format(todayRevenue)}',
                              style: AppTextStyles.titleSmall
                                  .copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text(
          AppConstants.appName,
          style: AppTextStyles.appBarTitle,
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
    );
  }

  Widget _buildTopStats() {
    return Consumer3<ProductProvider, InvoiceProvider, RevenueProvider>(
      builder: (_, productProvider, invoiceProvider, revenueProvider, __) {
        final todayInvoices = invoiceProvider.invoices
            .where((inv) =>
                AppDateUtils.isSameDay(inv.ngayBan, DateTime.now()))
            .length;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            StatCard(
              title: 'Tổng sản phẩm',
              value: productProvider.totalProducts.toString(),
              icon: Icons.inventory_2,
              color: AppColors.primary,
              backgroundColor: AppColors.primaryContainer,
              subtitle: 'loại sản phẩm',
            ),
            StatCard(
              title: 'Tổng tồn kho',
              value: productProvider.totalStock.toString(),
              icon: Icons.warehouse,
              color: AppColors.accent,
              backgroundColor: Color(0xFFE0F7FA),
              subtitle: 'đơn vị',
            ),
            StatCard(
              title: 'HĐ hôm nay',
              value: todayInvoices.toString(),
              icon: Icons.receipt_long,
              color: AppColors.secondary,
              backgroundColor: AppColors.secondaryContainer,
              subtitle: 'hóa đơn',
            ),
            StatCard(
              title: 'DT tháng này',
              value: CurrencyUtils.formatNoSymbol(
                  revenueProvider.monthStats?.totalRevenue ?? 0),
              icon: Icons.bar_chart,
              color: AppColors.success,
              backgroundColor: AppColors.successLight,
              subtitle: '₫',
            ),
          ],
        );
      },
    );
  }

  Widget _buildRevenueChart() {
    return Consumer<RevenueProvider>(
      builder: (_, provider, __) {
        final points = provider.dailyPoints;
        if (points.isEmpty) return const SizedBox.shrink();

        final maxY = points
                .map((p) => p.revenue)
                .where((r) => r > 0)
                .isEmpty
            ? 100000.0
            : points
                .map((p) => p.revenue)
                .reduce((a, b) => a > b ? a : b);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: AppColors.shadow, blurRadius: 8)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Doanh thu tháng này',
                      style: AppTextStyles.titleMedium),
                  Text(
                    CurrencyUtils.format(
                        provider.monthStats?.totalRevenue ?? 0),
                    style: AppTextStyles.currency.copyWith(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY * 1.3,
                    barGroups: points
                        .asMap()
                        .entries
                        .map((e) => BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.revenue,
                                  color: AppDateUtils.isSameDay(
                                          e.value.date, DateTime.now())
                                      ? AppColors.secondary
                                      : AppColors.primary
                                          .withAlpha(180),
                                  width: 5,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(3)),
                                ),
                              ],
                            ))
                        .toList(),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final day = v.toInt() + 1;
                            if (day % 10 != 0 && day != 1) {
                              return const SizedBox.shrink();
                            }
                            return Text(day.toString(),
                                style: AppTextStyles.labelSmall);
                          },
                          reservedSize: 18,
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLowStockWarning() {
    return Consumer<ProductProvider>(
      builder: (_, provider, __) {
        final lowStockProducts = provider.lowStockProducts;
        final outOfStock = provider.outOfStockProducts;
        final allWarning = [...outOfStock, ...lowStockProducts];

        if (allWarning.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warningLight, width: 2),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text('Cảnh báo tồn kho',
                      style: AppTextStyles.titleMedium),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${allWarning.length}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...allWarning.take(4).map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          p.isInStock
                              ? Icons.warning_amber
                              : Icons.remove_shopping_cart,
                          size: 16,
                          color: p.isInStock
                              ? AppColors.warning
                              : AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(p.tenSanPham,
                                style: AppTextStyles.bodyMedium)),
                        Text(
                          p.isInStock
                              ? 'Còn ${p.soLuongTon}'
                              : 'Hết hàng',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: p.isInStock
                                ? AppColors.warning
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentInvoices() {
    return Consumer<InvoiceProvider>(
      builder: (_, provider, __) {
        final recent = provider.invoices.take(3).toList();
        if (recent.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hóa đơn gần đây', style: AppTextStyles.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            ...recent.map((inv) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadow, blurRadius: 6)
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_long,
                            color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HĐ #${inv.id.substring(0, 6).toUpperCase()}',
                              style: AppTextStyles.titleSmall,
                            ),
                            Text(
                              '${inv.nhanVien} • ${AppDateUtils.formatDate(inv.ngayBan)}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyUtils.format(inv.tongTien),
                        style: AppTextStyles.currency.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                )),
          ],
        );
      },
    );
  }
}
