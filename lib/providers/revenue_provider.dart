import 'package:flutter/foundation.dart';
import '../models/revenue.dart';
import '../repositories/revenue_repository.dart';
import 'product_provider.dart';

/// Provider quản lý state cho thống kê doanh thu
class RevenueProvider extends ChangeNotifier {
  final RevenueRepository _repository;

  RevenueProvider(this._repository) {
    _initCurrentPeriod();
  }

  void _initCurrentPeriod() {
    final now = DateTime.now();
    _selectedDate = now;
    _selectedYear = now.year;
    _selectedMonth = now.month;
  }

  // ==================== STATE ====================
  RevenueStats? _dayStats;
  RevenueStats? _monthStats;
  List<RevenueDataPoint> _dailyPoints = [];
  List<RevenueDataPoint> _monthlyPoints = [];
  LoadingState _state = LoadingState.idle;
  String _error = '';
  late DateTime _selectedDate;
  late int _selectedYear;
  late int _selectedMonth;
  RevenueViewType _viewType = RevenueViewType.daily;

  // ==================== GETTERS ====================
  RevenueStats? get dayStats => _dayStats;
  RevenueStats? get monthStats => _monthStats;
  List<RevenueDataPoint> get dailyPoints => _dailyPoints;
  List<RevenueDataPoint> get monthlyPoints => _monthlyPoints;
  LoadingState get state => _state;
  String get error => _error;
  DateTime get selectedDate => _selectedDate;
  int get selectedYear => _selectedYear;
  int get selectedMonth => _selectedMonth;
  RevenueViewType get viewType => _viewType;
  bool get isLoading => _state == LoadingState.loading;

  // ==================== ACTIONS ====================

  Future<void> loadAll() async {
    _state = LoadingState.loading;
    notifyListeners();

    try {
      await Future.wait([
        _loadDayStats(),
        _loadMonthStats(),
        _loadDailyPoints(),
        _loadMonthlyPoints(),
      ]);
      _state = LoadingState.success;
    } catch (e) {
      _error = e.toString();
      _state = LoadingState.error;
    }

    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    _selectedMonth = date.month;
    _selectedYear = date.year;
    notifyListeners();
    await loadAll();
  }

  Future<void> selectMonth(int year, int month) async {
    _selectedYear = year;
    _selectedMonth = month;
    _selectedDate = DateTime(year, month, 1);
    notifyListeners();
    await loadAll();
  }

  void setViewType(RevenueViewType type) {
    _viewType = type;
    notifyListeners();
  }

  // ==================== PRIVATE ====================

  Future<void> _loadDayStats() async {
    _dayStats = await _repository.getByDay(_selectedDate);
  }

  Future<void> _loadMonthStats() async {
    _monthStats =
        await _repository.getByMonth(_selectedYear, _selectedMonth);
  }

  Future<void> _loadDailyPoints() async {
    _dailyPoints = await _repository.getDailyRevenueInMonth(
        _selectedYear, _selectedMonth);
  }

  Future<void> _loadMonthlyPoints() async {
    _monthlyPoints =
        await _repository.getMonthlyRevenueInYear(_selectedYear);
  }
}

enum RevenueViewType { daily, monthly }
