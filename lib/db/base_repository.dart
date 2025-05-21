import 'package:sqflite/sqflite.dart';

import 'database_exception.dart';
import 'database_helper.dart';

class BaseRepository<T> {
  final DatabaseHelper _dbHelper;
  final String tableName;
  final String primaryKey;
  final Map<String, String> uniqueFields;
  final Map<String, String> uniqueErrorMessages;

  BaseRepository({
    required DatabaseHelper dbHelper,
    required this.tableName,
    this.primaryKey = 'id',
    this.uniqueFields = const {},
    this.uniqueErrorMessages = const {},
  }) : _dbHelper = dbHelper;

  Future<Database> get database => _dbHelper.database;

  Future<int> insert(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      return await db.insert(tableName, row);
    } on DatabaseException catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        // Check which unique constraint failed
        for (var field in uniqueFields.keys) {
          if (e.toString().contains(uniqueFields[field]!)) {
            throw CustomDatabaseException(
              uniqueErrorMessages[field] ?? 'قيمة موجودة بالفعل',
              code: DatabaseErrorCodes.duplicateEntry,
            );
          }
        }
        throw CustomDatabaseException(
          'قيمة موجودة بالفعل',
          code: DatabaseErrorCodes.duplicateEntry,
        );
      }
      rethrow;
    } catch (e) {
      throw CustomDatabaseException(
        'فشل في إضافة البيانات: ${e.toString()}',
        code: DatabaseErrorCodes.insertError,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAll({String? orderBy}) async {
    try {
      Database db = await database;
      return await db.query(tableName, orderBy: orderBy);
    } catch (e) {
      throw CustomDatabaseException(
        'فشل في جلب البيانات: ${e.toString()}',
        code: DatabaseErrorCodes.databaseClosed,
      );
    }
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> results = await db.query(
        tableName,
        where: '$primaryKey = ?',
        whereArgs: [id],
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      throw CustomDatabaseException(
        'فشل في جلب البيانات: ${e.toString()}',
        code: DatabaseErrorCodes.databaseClosed,
      );
    }
  }

  Future<List<Map<String, dynamic>>> search(String field, String query) async {
    try {
      Database db = await database;
      return await db.query(
        tableName,
        where: '$field LIKE ?',
        whereArgs: ['%$query%'],
      );
    } catch (e) {
      throw CustomDatabaseException(
        'فشل في البحث: ${e.toString()}',
        code: DatabaseErrorCodes.databaseClosed,
      );
    }
  }

  Future<List<Map<String, dynamic>>> searchMultipleFields(
      List<String> fields, String query,
      {String? orderBy}) async {
    try {
      Database db = await database;
      String whereClause = fields.map((field) => '$field LIKE ?').join(' OR ');
      List<String> whereArgs = List.filled(fields.length, '%$query%');

      return await db.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: orderBy,
      );
    } catch (e) {
      throw CustomDatabaseException(
        'فشل في البحث: ${e.toString()}',
        code: DatabaseErrorCodes.databaseClosed,
      );
    }
  }

  Future<Map<String, dynamic>?> getByField(String field, dynamic value) async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> results = await db.query(
        tableName,
        where: '$field = ?',
        whereArgs: [value],
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      throw CustomDatabaseException(
        'فشل في جلب البيانات: ${e.toString()}',
        code: DatabaseErrorCodes.databaseClosed,
      );
    }
  }

  Future<int> update(Map<String, dynamic> row) async {
    try {
      Database db = await database;
      int id = row[primaryKey];
      return await db
          .update(tableName, row, where: '$primaryKey = ?', whereArgs: [id]);
    } on DatabaseException catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        // Check which unique constraint failed
        for (var field in uniqueFields.keys) {
          if (e.toString().contains(uniqueFields[field]!)) {
            throw CustomDatabaseException(
              uniqueErrorMessages[field] ?? 'قيمة موجودة بالفعل',
              code: DatabaseErrorCodes.duplicateEntry,
            );
          }
        }
        throw CustomDatabaseException(
          'قيمة موجودة بالفعل',
          code: DatabaseErrorCodes.duplicateEntry,
        );
      }
      rethrow;
    } catch (e) {
      throw CustomDatabaseException(
        'فشل في تحديث البيانات: ${e.toString()}',
        code: DatabaseErrorCodes.updateError,
      );
    }
  }

  Future<int> delete(int id) async {
    try {
      Database db = await database;
      return await db
          .delete(tableName, where: '$primaryKey = ?', whereArgs: [id]);
    } catch (e) {
      throw CustomDatabaseException(
        'فشل في حذف البيانات: ${e.toString()}',
        code: DatabaseErrorCodes.deleteError,
      );
    }
  }

  Future<List<Map<String, dynamic>>> query({
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      Database db = await database;
      return await db.query(
        tableName,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw CustomDatabaseException(
        'فشل في استعلام البيانات: ${e.toString()}',
        code: DatabaseErrorCodes.queryError,
      );
    }
  }
}
