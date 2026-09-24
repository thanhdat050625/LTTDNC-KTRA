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
import 'services/calculated_revenue_repository.dart';
import 'services/firebase_invoice_repository.dart';
import 'services/firebase_product_repository.dart';
import 'theme/app_theme.dart';

/// App root widget - Cấu hình Provider và theme
class GroceryStoreApp extends StatelessWidget {
  const GroceryStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
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

  /// Tạo ProductRepository kết nối Firestore
  ProductRepository _buildProductRepository() {
    return FirebaseProductRepository();
  }

  /// Tạo InvoiceRepository kết nối Firestore
  InvoiceRepository _buildInvoiceRepository() {
    return FirebaseInvoiceRepository();
  }

  /// Tạo RevenueRepository (tính trực tiếp từ hóa đơn thật)
  RevenueRepository _buildRevenueRepository(InvoiceRepository invoiceRepo) {
    return CalculatedRevenueRepository(invoiceRepo);
  }
}
