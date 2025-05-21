import '../db/database_helper.dart';
import '../models/customer.dart';

class CustomerService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> addCustomer(Customer customer) async {
    return await _dbHelper.insertCustomer(customer.toMap());
  }

  Future<List<Customer>> getAllCustomers() async {
    final customerMaps = await _dbHelper.getCustomers();
    return customerMaps.map((map) => Customer.fromMap(map)).toList();
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final customerMaps = await _dbHelper.searchCustomers(query);
    return customerMaps.map((map) => Customer.fromMap(map)).toList();
  }

  Future<Customer?> getCustomerById(int id) async {
    final customerMap = await _dbHelper.getCustomerById(id);
    if (customerMap == null) return null;
    return Customer.fromMap(customerMap);
  }

  Future<Customer?> getCustomerByPhone(String phone) async {
    final customerMap = await _dbHelper.getCustomerByPhone(phone);
    if (customerMap == null) return null;
    return Customer.fromMap(customerMap);
  }

  Future<int> updateCustomer(Customer customer) async {
    return await _dbHelper.updateCustomer(customer.toMap());
  }

  Future<int> deleteCustomer(int id) async {
    return await _dbHelper.deleteCustomer(id);
  }
}