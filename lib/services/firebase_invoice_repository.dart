import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase/firebase_config.dart';
import '../models/invoice.dart';
import '../models/invoice_detail.dart';
import '../repositories/invoice_repository.dart';
import '../utils/date_utils.dart';

class FirebaseInvoiceRepository implements InvoiceRepository {
  final FirebaseFirestore _firestore;

  FirebaseInvoiceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _invoicesCollection =>
      _firestore.collection(FirebaseConfig.invoicesCollection);

  CollectionReference<Map<String, dynamic>> get _detailsCollection =>
      _firestore.collection(FirebaseConfig.invoiceDetailsCollection);

  @override
  Future<List<Invoice>> getAll() async {
    final snapshot = await _invoicesCollection
        .orderBy('ngayBan', descending: true)
        .get();
    return snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList();
  }

  @override
  Future<Invoice?> getById(String id) async {
    final doc = await _invoicesCollection.doc(id).get();
    if (!doc.exists) return null;
    final invoice = Invoice.fromFirestore(doc);
    final details = await getDetailsByInvoiceId(id);
    return invoice.copyWith(details: details);
  }

  @override
  Future<List<Invoice>> getByDateRange(DateTime from, DateTime to) async {
    final start = AppDateUtils.startOfDay(from);
    final end = AppDateUtils.endOfDay(to);

    final snapshot = await _invoicesCollection
        .where('ngayBan', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('ngayBan', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('ngayBan', descending: true)
        .get();

    return snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList();
  }

  @override
  Future<List<Invoice>> getByDate(DateTime date) async {
    return getByDateRange(date, date);
  }

  @override
  Future<List<Invoice>> getByMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    final snapshot = await _invoicesCollection
        .where('ngayBan', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('ngayBan', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('ngayBan', descending: true)
        .get();

    return snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList();
  }

  @override
  Future<Invoice> create(Invoice invoice, List<InvoiceDetail> details) async {
    final batch = _firestore.batch();
    final invoiceDoc = _invoicesCollection.doc();
    final invoiceId = invoiceDoc.id;

    batch.set(invoiceDoc, invoice.toFirestore());

    final savedDetails = <InvoiceDetail>[];
    for (final detail in details) {
      final detailDoc = _detailsCollection.doc();
      final updatedDetail = detail.copyWith(
        id: detailDoc.id,
        invoiceId: invoiceId,
      );
      batch.set(detailDoc, updatedDetail.toFirestore());
      savedDetails.add(updatedDetail);
    }

    await batch.commit();

    return invoice.copyWith(id: invoiceId, details: savedDetails);
  }

  @override
  Future<List<InvoiceDetail>> getDetailsByInvoiceId(String invoiceId) async {
    final snapshot = await _detailsCollection
        .where('invoiceId', isEqualTo: invoiceId)
        .get();

    return snapshot.docs
        .map((doc) => InvoiceDetail.fromFirestore(doc))
        .toList();
  }

  @override
  Stream<List<Invoice>> watchAll() {
    return _invoicesCollection
        .orderBy('ngayBan', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Invoice.fromFirestore(doc)).toList());
  }
}
