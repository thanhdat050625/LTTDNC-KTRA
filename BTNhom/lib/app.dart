import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'providers/invoice_provider.dart';
import 'providers/product_provider.dart';
import 'providers/revenue_provider.dart';
import 'repositories/invoice_repository.dart';
import 'repositories/product_repository.dart';
import 'repositories/revenue_repository.dart';
import 'screens/home/main_scaffold.dart';
import 'services/mock_invoice_repository.dart';
import 'services/mock_product_repository.dart';
import 'services/mock_revenue_repository.dart';
import 'theme/app_theme.dart';

/// App root widget - Cấu hình Provider và theme
class GroceryStoreApp extends StatelessWidget {
  const GroceryStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo repositories theo cấu hình
    // Khi Firebase được bật: thay bằng FirebaseProductRepository, v.v.
    final productRepo = _buildProductRepository();
    final invoiceRepo = _buildInvoiceRepository();
    final revenueRepo = _buildRevenueRepository(invoiceRepo);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => InvoiceProvider(invoiceRepo, productRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => RevenueProvider(revenueRepo),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false, // Tắt DEBUG banner
        theme: AppTheme.lightTheme,
        home: const MainScaffold(),
      ),
    );
  }

  /// Tạo ProductRepository dựa trên cấu hình Firebase
  ProductRepository _buildProductRepository() {
    if (AppConfig.isFirebaseEnabled) {
      // TODO: return FirebaseProductRepository();
      // Hiện tại Firebase chưa được cấu hình, dùng mock
      return MockProductRepository();
    }
    return MockProductRepository();
  }

  /// Tạo InvoiceRepository dựa trên cấu hình Firebase
  InvoiceRepository _buildInvoiceRepository() {
    if (AppConfig.isFirebaseEnabled) {
      // TODO: return FirebaseInvoiceRepository();
      return MockInvoiceRepository();
    }
    return MockInvoiceRepository();
  }

  /// Tạo RevenueRepository (luôn tính từ InvoiceRepository)
  RevenueRepository _buildRevenueRepository(InvoiceRepository invoiceRepo) {
    return MockRevenueRepository(invoiceRepo);
  }
}
