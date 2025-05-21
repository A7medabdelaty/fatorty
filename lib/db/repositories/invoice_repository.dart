import '../base_repository.dart';
import '../database_helper.dart';

class InvoiceRepository extends BaseRepository {
  InvoiceRepository(DatabaseHelper dbHelper)
      : super(
          dbHelper: dbHelper,
          tableName: 'invoices',
        );

  Future<List<Map<String, dynamic>>> getByDateRange(
      DateTime start, DateTime end) async {
    return await query(
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getByCashier(int cashierId) async {
    return await query(
      where: 'cashier_id = ?',
      whereArgs: [cashierId],
      orderBy: 'created_at DESC',
    );
  }
}
