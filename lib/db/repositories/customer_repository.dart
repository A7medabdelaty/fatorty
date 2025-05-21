import '../base_repository.dart';
import '../database_helper.dart';

class CustomerRepository extends BaseRepository {
  CustomerRepository(DatabaseHelper dbHelper)
      : super(
          dbHelper: dbHelper,
          tableName: 'customers',
        );

  Future<Map<String, dynamic>?> getByPhone(String phone) async {
    return await getByField('phone', phone);
  }

  Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    return await searchMultipleFields(
      ['name', 'phone', 'email'],
      query,
      orderBy: 'name ASC',
    );
  }
}
