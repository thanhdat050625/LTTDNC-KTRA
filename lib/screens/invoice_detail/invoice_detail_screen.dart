import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/invoice.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../utils/currency_utils.dart';
import '../../utils/date_utils.dart';

/// Màn hình chi tiết hóa đơn
class InvoiceDetailScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('HĐ #${invoice.id.substring(0, 8).toUpperCase()}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'In hóa đơn',
            onPressed: () => _printInvoice(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Chia sẻ PDF',
            onPressed: () => _shareInvoice(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Items
            _buildItemsList(),
            // Summary
            _buildSummary(),
            // Footer
            _buildFooter(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildPrintBar(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            AppConstants.appFullName,
            style: AppTextStyles.titleLargeWhite,
          ),
          const SizedBox(height: 4),
          Text(
            'HÓA ĐƠN BÁN HÀNG',
            style: AppTextStyles.headlineMediumWhite,
          ),
          const SizedBox(height: 16),
          _InfoRow(
              label: 'Mã HĐ',
              value: '#${invoice.id.substring(0, 8).toUpperCase()}',
              white: true),
          _InfoRow(
              label: 'Ngày bán',
              value: AppDateUtils.formatDateTime(invoice.ngayBan),
              white: true),
          _InfoRow(
              label: 'Nhân viên', value: invoice.nhanVien, white: true),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            child: Text('Danh sách sản phẩm',
                style: AppTextStyles.titleLarge),
          ),
          const Divider(height: 1),
          // Header row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Sản phẩm',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.textSecondary))),
                Expanded(
                    child: Text('SL',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.textSecondary))),
                Expanded(
                    flex: 2,
                    child: Text('Thành tiền',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.textSecondary))),
              ],
            ),
          ),
          const Divider(height: 1),
          if (invoice.details.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Không có chi tiết hóa đơn')),
            )
          else
            ...invoice.details.map((detail) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(detail.tenSanPham,
                                    style: AppTextStyles.titleSmall),
                                Text(
                                  CurrencyUtils.format(detail.donGia),
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '×${detail.soLuong}',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              CurrencyUtils.format(detail.thanhTien),
                              textAlign: TextAlign.right,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                )),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final subtotal = invoice.tamTinh;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng kết hóa đơn', style: AppTextStyles.titleLarge),
          const SizedBox(height: 16),
          _SummaryLine(
              label: 'Tạm tính',
              value: CurrencyUtils.format(subtotal)),
          const SizedBox(height: 8),
          _SummaryLine(
            label: 'VAT (${(AppConstants.vatRate * 100).toInt()}%)',
            value: CurrencyUtils.format(invoice.vat),
            valueColor: AppColors.info,
          ),
          if (invoice.hasDiscount) ...[
            const SizedBox(height: 8),
            _SummaryLine(
              label:
                  'Giảm giá (${(AppConstants.discountRate * 100).toInt()}%)',
              value: '- ${CurrencyUtils.format(invoice.giamGia)}',
              valueColor: AppColors.success,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          _SummaryLine(
            label: 'TỔNG THANH TOÁN',
            value: CurrencyUtils.format(invoice.tongTien),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            'Cảm ơn quý khách đã mua hàng!',
            style:
                AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Hẹn gặp lại lần sau',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, -4)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _printInvoice(context),
                icon: const Icon(Icons.print),
                label: const Text('In hóa đơn'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _shareInvoice(context),
                icon: const Icon(Icons.share),
                label: const Text('Chia sẻ PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<pw.Document> _buildPdf() async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(AppConstants.appFullName,
                        style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 16,
                            color: PdfColors.green700)),
                    pw.SizedBox(height: 4),
                    pw.Text('HÓA ĐƠN BÁN HÀNG',
                        style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 14)),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 8),
              // Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      'Mã HĐ: #${invoice.id.substring(0, 8).toUpperCase()}',
                      style: pw.TextStyle(font: font, fontSize: 10)),
                  pw.Text(
                      'Ngày: ${AppDateUtils.formatDate(invoice.ngayBan)}',
                      style: pw.TextStyle(font: font, fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text('Nhân viên: ${invoice.nhanVien}',
                  style: pw.TextStyle(font: font, fontSize: 10)),
              pw.SizedBox(height: 12),
              pw.Divider(),
              // Table header
              pw.Row(
                children: [
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text('Sản phẩm',
                          style: pw.TextStyle(font: fontBold, fontSize: 10))),
                  pw.Expanded(
                      child: pw.Text('SL',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(font: fontBold, fontSize: 10))),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text('Thành tiền',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(font: fontBold, fontSize: 10))),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(),
              // Items
              ...invoice.details.map((d) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                            flex: 3,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(d.tenSanPham,
                                    style: pw.TextStyle(
                                        font: font, fontSize: 9)),
                                pw.Text(
                                    CurrencyUtils.format(d.donGia),
                                    style: pw.TextStyle(
                                        font: font,
                                        fontSize: 8,
                                        color: PdfColors.grey)),
                              ],
                            )),
                        pw.Expanded(
                            child: pw.Text('×${d.soLuong}',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(font: font, fontSize: 9))),
                        pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                                CurrencyUtils.format(d.thanhTien),
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(font: fontBold, fontSize: 9))),
                      ],
                    ),
                  )),
              pw.Divider(),
              pw.SizedBox(height: 8),
              // Summary
              _pdfSummaryRow('Tạm tính', CurrencyUtils.format(invoice.tamTinh),
                  font, fontBold),
              _pdfSummaryRow(
                  'VAT (${(AppConstants.vatRate * 100).toInt()}%)',
                  CurrencyUtils.format(invoice.vat),
                  font,
                  fontBold),
              if (invoice.hasDiscount)
                _pdfSummaryRow(
                    'Giảm giá (${(AppConstants.discountRate * 100).toInt()}%)',
                    '- ${CurrencyUtils.format(invoice.giamGia)}',
                    font,
                    fontBold),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TỔNG THANH TOÁN',
                      style: pw.TextStyle(font: fontBold, fontSize: 12)),
                  pw.Text(CurrencyUtils.format(invoice.tongTien),
                      style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 14,
                          color: PdfColors.green700)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text('Cảm ơn quý khách!',
                    style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 12,
                        color: PdfColors.green700)),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _pdfSummaryRow(
      String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 10)),
        ],
      ),
    );
  }

  Future<void> _printInvoice(BuildContext context) async {
    try {
      final pdf = await _buildPdf();
      await Printing.layoutPdf(
        onLayout: (_) async => pdf.save(),
        name: 'HoaDon_${invoice.id.substring(0, 8).toUpperCase()}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi in hóa đơn: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _shareInvoice(BuildContext context) async {
    try {
      final pdf = await _buildPdf();
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'HoaDon_${invoice.id.substring(0, 8).toUpperCase()}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chia sẻ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ==================== HELPER WIDGETS ====================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool white;

  const _InfoRow({required this.label, required this.value, this.white = false});

  @override
  Widget build(BuildContext context) {
    final textColor = white ? Colors.white : AppColors.textPrimary;
    final secondaryColor = white ? Colors.white70 : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: TextStyle(fontSize: 13, color: secondaryColor)),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const _SummaryLine({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: isTotal
                ? AppTextStyles.titleMedium
                : AppTextStyles.bodyMedium),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.currency.copyWith(fontSize: 20)
              : AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary),
        ),
      ],
    );
  }
}
