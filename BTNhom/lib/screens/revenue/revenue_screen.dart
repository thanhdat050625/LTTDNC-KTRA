import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/revenue.dart';
import '../../providers/revenue_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/currency_utils.dart';
import '../../utils/date_utils.dart';

/// Màn hình thống kê doanh thu
class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RevenueProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Doanh thu'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today), text: 'Theo ngày'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Theo tháng'),
          ],
          onTap: (i) {
            context
                .read<RevenueProvider>()
                .setViewType(i == 0 ? RevenueViewType.daily : RevenueViewType.monthly);
          },
        ),
      ),
      body: Consumer<RevenueProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _DailyTab(provider: provider),
              _MonthlyTab(provider: provider),
            ],
          );
        },
      ),
    );
  }
}

// ==================== DAILY TAB ====================

class _DailyTab extends StatelessWidget {
  final RevenueProvider provider;

  const _DailyTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Date picker
          _DatePickerCard(
            selectedDate: provider.selectedDate,
            onDateSelected: (date) => provider.selectDate(date),
          ),
          const SizedBox(height: 16),
          // Stats
          if (provider.dayStats != null) ...[
            _StatsRow(stats: provider.dayStats!),
            const SizedBox(height: 16),
          ],
          // Chart - daily in month
          _DailyChartCard(
            points: provider.dailyPoints,
            selectedDate: provider.selectedDate,
          ),
        ],
      ),
    );
  }
}

// ==================== MONTHLY TAB ====================

class _MonthlyTab extends StatelessWidget {
  final RevenueProvider provider;

  const _MonthlyTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month picker
          _MonthPickerCard(
            selectedYear: provider.selectedYear,
            selectedMonth: provider.selectedMonth,
            onMonthSelected: (y, m) => provider.selectMonth(y, m),
          ),
          const SizedBox(height: 16),
          // Stats
          if (provider.monthStats != null) ...[
            _StatsRow(stats: provider.monthStats!),
            const SizedBox(height: 16),
          ],
          // Monthly chart
          _MonthlyChartCard(
            points: provider.monthlyPoints,
            selectedYear: provider.selectedYear,
          ),
        ],
      ),
    );
  }
}

// ==================== DATE PICKER ====================

class _DatePickerCard extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _DatePickerCard(
      {required this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ngày được chọn', style: AppTextStyles.labelMedium),
                Text(AppDateUtils.formatDate(selectedDate),
                    style: AppTextStyles.titleMedium),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (date != null) onDateSelected(date);
            },
            child: const Text('Chọn ngày'),
          ),
        ],
      ),
    );
  }
}

// ==================== MONTH PICKER ====================

class _MonthPickerCard extends StatelessWidget {
  final int selectedYear;
  final int selectedMonth;
  final Function(int year, int month) onMonthSelected;

  const _MonthPickerCard({
    required this.selectedYear,
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tháng được chọn', style: AppTextStyles.labelMedium),
                    Text(
                      'Tháng $selectedMonth / $selectedYear',
                      style: AppTextStyles.titleMedium,
                    ),
                  ],
                ),
              ),
              // Year picker
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () =>
                        onMonthSelected(selectedYear - 1, selectedMonth),
                  ),
                  Text(selectedYear.toString(),
                      style: AppTextStyles.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: selectedYear < DateTime.now().year
                        ? () =>
                            onMonthSelected(selectedYear + 1, selectedMonth)
                        : null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Month grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1.4,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: 12,
            itemBuilder: (_, i) {
              final m = i + 1;
              final isSelected = m == selectedMonth;
              final isFuture = selectedYear == DateTime.now().year &&
                  m > DateTime.now().month;
              return GestureDetector(
                onTap: isFuture ? null : () => onMonthSelected(selectedYear, m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? null
                        : Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      'T$m',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : isFuture
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==================== STATS ROW ====================

class _StatsRow extends StatelessWidget {
  final RevenueStats stats;

  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main stats
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.revenueGradient,
            borderRadius: BorderRadius.circular(16),
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
              Text('Tổng doanh thu', style: AppTextStyles.bodyMediumWhite),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: stats.totalRevenue),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOut,
                builder: (_, v, __) => Text(
                  CurrencyUtils.format(v),
                  style: AppTextStyles.displayMedium.copyWith(
                      color: Colors.white, fontSize: 32),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${stats.invoiceCount} hóa đơn',
                style: AppTextStyles.bodyMediumWhite,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Detail stats
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                title: 'Tiền VAT',
                value: CurrencyUtils.format(stats.totalVat),
                icon: Icons.receipt,
                color: AppColors.info,
                backgroundColor: AppColors.infoLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStatCard(
                title: 'Đã giảm',
                value: CurrencyUtils.format(stats.totalDiscount),
                icon: Icons.local_offer,
                color: AppColors.success,
                backgroundColor: AppColors.successLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelSmall),
                Text(value,
                    style: AppTextStyles.titleSmall
                        .copyWith(color: color, fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== DAILY CHART ====================

class _DailyChartCard extends StatelessWidget {
  final List<RevenueDataPoint> points;
  final DateTime selectedDate;

  const _DailyChartCard(
      {required this.points, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final nonZero = points.where((p) => p.revenue > 0).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Doanh thu theo ngày - Tháng ${selectedDate.month}/${selectedDate.year}',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 20),
          if (nonZero.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: AppColors.border),
                    SizedBox(height: 8),
                    Text('Chưa có dữ liệu doanh thu trong tháng này'),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: points
                          .map((p) => p.revenue)
                          .reduce((a, b) => a > b ? a : b) *
                      1.2,
                  barGroups: _buildBarGroups(),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final day = value.toInt() + 1;
                          if (day % 5 != 0 && day != 1) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            day.toString(),
                            style: AppTextStyles.labelSmall,
                          );
                        },
                        reservedSize: 20,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Text(
                            '${(value / 1000).toInt()}k',
                            style: AppTextStyles.labelSmall,
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.primary,
                      getTooltipItem: (group, _, rod, __) {
                        final day = group.x + 1;
                        return BarTooltipItem(
                          'Ngày $day\n${CurrencyUtils.format(rod.toY)}',
                          const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return points.asMap().entries.map((e) {
      final isSelected =
          AppDateUtils.isSameDay(e.value.date, selectedDate);
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.revenue,
            color: isSelected ? AppColors.secondary : AppColors.primary,
            width: 6,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }
}

// ==================== MONTHLY CHART ====================

class _MonthlyChartCard extends StatelessWidget {
  final List<RevenueDataPoint> points;
  final int selectedYear;

  const _MonthlyChartCard(
      {required this.points, required this.selectedYear});

  @override
  Widget build(BuildContext context) {
    final maxRevenue = points.isEmpty
        ? 1.0
        : points
            .map((p) => p.revenue)
            .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Doanh thu theo tháng - Năm $selectedYear',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxRevenue > 0 ? maxRevenue * 1.3 : 100000,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) => Text(
                        'T${value.toInt() + 1}',
                        style: AppTextStyles.labelSmall,
                      ),
                      reservedSize: 20,
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          '${(value / 1000).toInt()}k',
                          style: AppTextStyles.labelSmall,
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: points
                        .asMap()
                        .entries
                        .map((e) => FlSpot(
                              e.key.toDouble(),
                              e.value.revenue,
                            ))
                        .toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withAlpha(30),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) =>
                          FlDotCirclePainter(
                        radius: spot.y > 0 ? 5 : 3,
                        color: spot.y > 0
                            ? AppColors.primary
                            : AppColors.border,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primary,
                    getTooltipItems: (spots) => spots
                        .map((spot) => LineTooltipItem(
                              'T${spot.x.toInt() + 1}\n${CurrencyUtils.format(spot.y)}',
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Monthly summary table
          ...points
              .where((p) => p.invoiceCount > 0)
              .map((p) => _MonthlyRow(point: p)),
        ],
      ),
    );
  }
}

class _MonthlyRow extends StatelessWidget {
  final RevenueDataPoint point;

  const _MonthlyRow({required this.point});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              'Tháng ${point.date.month}',
              style: AppTextStyles.labelMedium,
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: point.revenue > 0 ? (point.revenue / 2000000).clamp(0, 1) : 0,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            CurrencyUtils.format(point.revenue),
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
