import '../db/database_exception.dart';
import '../db/database_helper.dart';
import '../db/repositories/cashier_repository.dart';
import '../models/cashier.dart';

class CashierService {
  final CashierRepository _repository;

  CashierService(DatabaseHelper dbHelper)
      : _repository = dbHelper.cashierRepository;

  Future<Cashier> createCashier(Cashier cashier) async {
    if (!cashier.validate()) {
      throw CustomDatabaseException(
        'بيانات الكاشير غير صالحة',
        code: DatabaseErrorCodes.validationError,
      );
    }

    try {
      final id = await _repository.insert(cashier.toMap());
      return cashier.copyWith(id: id);
    } catch (e) {
      if (e is CustomDatabaseException) rethrow;
      throw CustomDatabaseException(
        'فشل في إنشاء الكاشير',
        code: DatabaseErrorCodes.insertError,
        details: e.toString(),
      );
    }
  }

  Future<List<Cashier>> getAllCashiers() async {
    try {
      final maps = await _repository.getAll(orderBy: 'name ASC');
      return maps.map((map) => Cashier.fromMap(map)).toList();
    } catch (e) {
      if (e is CustomDatabaseException) rethrow;
      throw CustomDatabaseException(
        'فشل في جلب قائمة الكاشير',
        code: DatabaseErrorCodes.queryError,
        details: e.toString(),
      );
    }
  }

  Future<List<Cashier>> searchCashiers(String query) async {
    try {
      final maps = await _repository.searchCashiers(query);
      return maps.map((map) => Cashier.fromMap(map)).toList();
    } catch (e) {
      if (e is CustomDatabaseException) rethrow;
      throw CustomDatabaseException(
        'فشل في البحث عن الكاشير',
        code: DatabaseErrorCodes.queryError,
        details: e.toString(),
      );
    }
  }

  Future<Cashier?> getCashierById(int id) async {
    try {
      final map = await _repository.getById(id);
      return map != null ? Cashier.fromMap(map) : null;
    } catch (e) {
      if (e is CustomDatabaseException) rethrow;
      throw CustomDatabaseException(
        'فشل في جلب بيانات الكاشير',
        code: DatabaseErrorCodes.queryError,
        details: e.toString(),
      );
    }
  }

  Future<Cashier?> getCashierByEmail(String email) async {
    try {
      final map = await _repository.getByEmail(email);
      return map != null ? Cashier.fromMap(map) : null;
    } catch (e) {
      if (e is CustomDatabaseException) rethrow;
      throw CustomDatabaseException(
        'فشل في جلب بيانات الكاشير',
        code: DatabaseErrorCodes.queryError,
        details: e.toString(),
      );
    }
  }

  Future<Cashier> updateCashier(Cashier cashier) async {
    if (!cashier.validate()) {
      throw CustomDatabaseException(
        'بيانات الكاشير غير صالحة',
        code: DatabaseErrorCodes.validationError,
      );
    }

    try {
      await _repository.update(cashier.toMap());
      return cashier;
    } catch (e) {
      if (e is CustomDatabaseException) rethrow;
      throw CustomDatabaseException(
        'فشل في تحديث بيانات الكاشير',
        code: DatabaseErrorCodes.updateError,
        details: e.toString(),
      );
    }
  }

  Future<void> deleteCashier(int id) async {
    try {
      await _repository.delete(id);
    } catch (e) {
      if (e is CustomDatabaseException) rethrow;
      throw CustomDatabaseException(
        'فشل في حذف الكاشير',
        code: DatabaseErrorCodes.deleteError,
        details: e.toString(),
      );
    }
  }
}
