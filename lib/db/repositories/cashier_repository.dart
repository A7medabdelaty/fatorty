import '../base_repository.dart';
import '../database_helper.dart';

class CashierRepository extends BaseRepository {
  CashierRepository(DatabaseHelper dbHelper)
      : super(
          dbHelper: dbHelper,
          tableName: 'cashiers',
          uniqueFields: {'email': 'email'},
          uniqueErrorMessages: {'email': 'البريد الإلكتروني مستخدم بالفعل'},
        );

  Future<Map<String, dynamic>?> getByEmail(String email) async {
    return await getByField('email', email);
  }

  Future<List<Map<String, dynamic>>> searchCashiers(String query) async {
    return await searchMultipleFields(
      ['name', 'phone', 'email'],
      query,
      orderBy: 'name ASC',
    );
  }
}
