import '../db/database_helper.dart';
import '../models/invoice.dart';

class InvoiceService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> addInvoice(Invoice invoice) async {
    return await _dbHelper.insertInvoice(invoice.toMap());
  }

  Future<List<Invoice>> getAllInvoices() async {
    final invoiceMaps = await _dbHelper.getInvoices();
    return invoiceMaps.map((map) => Invoice.fromMap(map)).toList();
  }

  Future<List<Invoice>> getInvoicesByDateRange(
      DateTime start, DateTime end) async {
    final invoiceMaps = await _dbHelper.getInvoicesByDateRange(start, end);
    return invoiceMaps.map((map) => Invoice.fromMap(map)).toList();
  }

  Future<List<Invoice>> getInvoicesByCashier(int cashierId) async {
    final invoiceMaps = await _dbHelper.getInvoicesByCashier(cashierId);
    return invoiceMaps.map((map) => Invoice.fromMap(map)).toList();
  }

  Future<int> updateInvoice(Invoice invoice) async {
    return await _dbHelper.updateInvoice(invoice.toMap());
  }

  Future<int> deleteInvoice(int id) async {
    return await _dbHelper.deleteInvoice(id);
  }
}
