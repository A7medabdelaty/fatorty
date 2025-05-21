import '../db/database_helper.dart';
import '../models/bike.dart';

class BikeService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> addBike(Bike bike) async {
    return await _dbHelper.insertBike(bike.toMap());
  }

  Future<List<Bike>> getAllBikes() async {
    final bikeMaps = await _dbHelper.getBikes();
    return bikeMaps.map((map) => Bike.fromMap(map)).toList();
  }

  Future<List<Bike>> getAvailableBikes() async {
    final bikeMaps = await _dbHelper.getAvailableBikes();
    return bikeMaps.map((map) => Bike.fromMap(map)).toList();
  }

  Future<List<Bike>> searchBikes(String query) async {
    final bikeMaps = await _dbHelper.searchBikes(query);
    return bikeMaps.map((map) => Bike.fromMap(map)).toList();
  }

  Future<int> updateBike(Bike bike) async {
    return await _dbHelper.updateBike(bike.toMap());
  }

  Future<int> deleteBike(int id) async {
    return await _dbHelper.deleteBike(id);
  }

  Future<Bike?> getBikeById(int id) async {
    final bikeMap = await _dbHelper.getBikeById(id);
    if (bikeMap == null) return null;
    return Bike.fromMap(bikeMap);
  }
}
