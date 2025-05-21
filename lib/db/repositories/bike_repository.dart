import '../base_repository.dart';
import '../database_helper.dart';

class BikeRepository extends BaseRepository {
  BikeRepository(DatabaseHelper dbHelper)
      : super(
          dbHelper: dbHelper,
          tableName: 'bikes',
        );

  Future<List<Map<String, dynamic>>> getAvailableBikes() async {
    return await query(
      where: 'status = ?',
      whereArgs: ['متاحة'],
      orderBy: 'name ASC',
    );
  }

  Future<List<Map<String, dynamic>>> searchBikes(String query) async {
    return await searchMultipleFields(
      ['name', 'type'],
      query,
      orderBy: 'name ASC',
    );
  }

  Future<Map<String, dynamic>?> getBikeById(int id) async {
    final results = await query(
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }
}
