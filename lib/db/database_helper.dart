import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_exception.dart';
import 'repositories/bike_repository.dart';
import 'repositories/cashier_repository.dart';
import 'repositories/customer_repository.dart';
import 'repositories/invoice_repository.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  bool _isInitialized = false;
  int _connectionCount = 0;

  // Repositories
  late CashierRepository cashierRepository;
  late BikeRepository bikeRepository;
  late CustomerRepository customerRepository;
  late InvoiceRepository invoiceRepository;
  //late PricingRepository pricingRepository;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal() {
    // Initialize repositories
    cashierRepository = CashierRepository(this);
    bikeRepository = BikeRepository(this);
    customerRepository = CustomerRepository(this);
    invoiceRepository = InvoiceRepository(this);
    //pricingRepository = PricingRepository(this);
  }

  Future<Database> get database async {
    if (_database != null) {
      _connectionCount++;
      return _database!;
    }
    if (!_isInitialized) {
      _database = await _initDatabase();
      _isInitialized = true;
      _connectionCount = 1;
    }
    return _database!;
  }

  Future<void> closeConnection() async {
    _connectionCount--;
    if (_connectionCount <= 0 && _database != null) {
      await _database!.close();
      _database = null;
      _isInitialized = false;
      _connectionCount = 0;
    }
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'bike_rental.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
        onOpen: (db) async {
          await db.rawQuery('PRAGMA journal_mode = WAL');
          await db.rawQuery('PRAGMA synchronous = NORMAL');
          await db.rawQuery('PRAGMA cache_size = 10000');
        },
      );
    } catch (e) {
      throw CustomDatabaseException(
        'فشل في تهيئة قاعدة البيانات: ${e.toString()}',
        code: DatabaseErrorCodes.databaseClosed,
      );
    }
  }

  Future<void> resetDatabase(Database db) async {
    await db.execute('DROP TABLE IF EXISTS bikes');
    await db.execute('DROP TABLE IF EXISTS customers');
    await db.execute('DROP TABLE IF EXISTS invoices');
    await db.execute('DROP TABLE IF EXISTS cashiers');
    // Add other tables as needed
    // Then recreate tables
    await _onCreate(db, 1); // or your current version
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    print('creating db');
    try {
      await db.transaction((txn) async {
        // جدول الكاشير
        await txn.execute('''CREATE TABLE cashiers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT,
            email TEXT UNIQUE,
            password TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )''');

        // جدول الدراجات
        await txn.execute('''CREATE TABLE bikes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            status TEXT NOT NULL,
            price_per_hour REAL NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            icon INTEGER NOT NULL,
            hourlyRate REAL,
            price REAL,
            description TEXT
          )''');

        // جدول العملاء
        await txn.execute('''CREATE TABLE customers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT,
            id_number TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )''');

        // جدول الفواتير
        await txn.execute('''CREATE TABLE invoices(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cashier_id INTEGER,
            bike_id INTEGER,
            customer_id INTEGER,
            start_time TIMESTAMP NOT NULL,
            end_time TIMESTAMP,
            total_hours INTEGER,
            total_amount REAL,
            status TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (cashier_id) REFERENCES cashiers (id) ON DELETE CASCADE,
            FOREIGN KEY (bike_id) REFERENCES bikes (id) ON DELETE CASCADE,
            FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
          )''');

        // جدول الأسعار
        await txn.execute('''CREATE TABLE pricing(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bike_type TEXT NOT NULL UNIQUE,
            price_per_hour REAL NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )''');

        // إضافة فهارس للبحث السريع
        await txn
            .execute('CREATE INDEX idx_customers_phone ON customers(phone)');
        await txn.execute('CREATE INDEX idx_customers_name ON customers(name)');
        await txn.execute('CREATE INDEX idx_cashiers_email ON cashiers(email)');
        await txn.execute('CREATE INDEX idx_cashiers_phone ON cashiers(phone)');
        await txn.execute('CREATE INDEX idx_bikes_status ON bikes(status)');
        await txn.execute('CREATE INDEX idx_bikes_type ON bikes(type)');
        await txn
            .execute('CREATE INDEX idx_invoices_date ON invoices(created_at)');
        await txn
            .execute('CREATE INDEX idx_invoices_status ON invoices(status)');
        await txn
            .execute('CREATE INDEX idx_pricing_type ON pricing(bike_type)');
      });
    } catch (e) {
      throw CustomDatabaseException(
        'فشل في إنشاء جداول قاعدة البيانات: ${e.toString()}',
        code: DatabaseErrorCodes.invalidData,
      );
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  // وظائف إضافية
  Future<void> deleteAllData() async {
    try {
      Database db = await database;
      await db.transaction((txn) async {
        await txn.delete('invoices');
        await txn.delete('bikes');
        await txn.delete('cashiers');
        await txn.delete('pricing');
        await txn.delete('customers');
      });
    } catch (e) {
      throw CustomDatabaseException(
        'فشل في حذف جميع البيانات: ${e.toString()}',
        code: DatabaseErrorCodes.databaseClosed,
      );
    }
  }

  // Delegate methods to repositories for backward compatibility
  // These methods can be gradually removed as you update service classes

  // Cashier methods
  Future<int> insertCashier(Map<String, dynamic> row) =>
      cashierRepository.insert(row);
  Future<List<Map<String, dynamic>>> getCashiers() =>
      cashierRepository.getAll(orderBy: 'name ASC');
  Future<List<Map<String, dynamic>>> searchCashiers(String query) =>
      cashierRepository.searchCashiers(query);
  Future<Map<String, dynamic>?> getCashierById(int id) =>
      cashierRepository.getById(id);
  Future<Map<String, dynamic>?> getCashierByEmail(String email) =>
      cashierRepository.getByEmail(email);
  Future<int> updateCashier(Map<String, dynamic> row) =>
      cashierRepository.update(row);
  Future<int> deleteCashier(int id) => cashierRepository.delete(id);

  // Bike methods
  Future<int> insertBike(Map<String, dynamic> row) =>
      bikeRepository.insert(row);
  Future<List<Map<String, dynamic>>> getBikes() =>
      bikeRepository.getAll(orderBy: 'name ASC');
  Future<List<Map<String, dynamic>>> getAvailableBikes() =>
      bikeRepository.getAvailableBikes();
  Future<List<Map<String, dynamic>>> searchBikes(String query) =>
      bikeRepository.searchBikes(query);
  Future<int> updateBike(Map<String, dynamic> row) =>
      bikeRepository.update(row);
  Future<int> deleteBike(int id) => bikeRepository.delete(id);
  Future<Map<String, dynamic>?> getBikeById(int id) =>
      bikeRepository.getBikeById(id);

  // Customer methods
  Future<int> insertCustomer(Map<String, dynamic> row) =>
      customerRepository.insert(row);
  Future<List<Map<String, dynamic>>> getCustomers() =>
      customerRepository.getAll(orderBy: 'name ASC');
  Future<List<Map<String, dynamic>>> searchCustomers(String query) =>
      customerRepository.searchCustomers(query);
  Future<Map<String, dynamic>?> getCustomerById(int id) =>
      customerRepository.getById(id);
  Future<Map<String, dynamic>?> getCustomerByPhone(String phone) =>
      customerRepository.getByPhone(phone);
  Future<int> updateCustomer(Map<String, dynamic> row) =>
      customerRepository.update(row);
  Future<int> deleteCustomer(int id) => customerRepository.delete(id);

  // Invoice methods
  Future<int> insertInvoice(Map<String, dynamic> row) =>
      invoiceRepository.insert(row);
  Future<List<Map<String, dynamic>>> getInvoices() =>
      invoiceRepository.getAll(orderBy: 'created_at DESC');
  Future<List<Map<String, dynamic>>> getInvoicesByDateRange(
          DateTime start, DateTime end) =>
      invoiceRepository.getByDateRange(start, end);
  Future<List<Map<String, dynamic>>> getInvoicesByCashier(int cashierId) =>
      invoiceRepository.getByCashier(cashierId);
  Future<int> updateInvoice(Map<String, dynamic> row) =>
      invoiceRepository.update(row);
  Future<int> deleteInvoice(int id) => invoiceRepository.delete(id);

  // // Pricing methods
  // Future<int> insertPricing(Map<String, dynamic> row) =>
  //     pricingRepository.insert(row);
  // Future<List<Map<String, dynamic>>> getPricing() =>
  //     pricingRepository.getAll(orderBy: 'bike_type ASC');
  // Future<Map<String, dynamic>?> getPricingByType(String bikeType) =>
  //     pricingRepository.getByType(bikeType);
  // Future<int> updatePricing(Map<String, dynamic> row) =>
  //     pricingRepository.update(row);
  // Future<int> deletePricing(int id) => pricingRepository.delete(id);
}
