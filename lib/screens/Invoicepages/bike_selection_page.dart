import 'package:flutter/material.dart';

import '../../constants/widgets.dart';
import '../../models/bike.dart';
import '../../services/bike_service.dart';
import 'cart_page.dart';

class BikeSelectionPage extends StatefulWidget {
  final String customerName;
  final String customerPhone;

  const BikeSelectionPage({
    Key? key,
    required this.customerName,
    required this.customerPhone,
  }) : super(key: key);

  @override
  _BikeSelectionPageState createState() => _BikeSelectionPageState();
}

class _BikeSelectionPageState extends State<BikeSelectionPage> {
  final BikeService _bikeService = BikeService();
  List<Bike> bikes = [];
  bool _isLoading = true;
  String? _errorMessage;

  final Map<Bike, int> selectedBikes = {};

  @override
  void initState() {
    super.initState();
    _fetchBikes();
  }

  Future<void> _fetchBikes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get available bikes from the database
      final availableBikes = await _bikeService.getAvailableBikes();
      print(availableBikes);
      setState(() {
        bikes = availableBikes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل الدراجات: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _addToCart(Bike bike) {
    setState(() {
      selectedBikes[bike] = (selectedBikes[bike] ?? 0) + 1;
    });
  }

  void _goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          selectedBikes: selectedBikes,
          customerName: widget.customerName,
          customerPhone: widget.customerPhone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'اختيار نوع الدراجة',
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(_errorMessage!,
                            style: const TextStyle(color: Colors.red)))
                    : bikes.isEmpty
                        ? const Center(child: Text('لا توجد دراجات متاحة'))
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: bikes.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemBuilder: (context, index) {
                              final bike = bikes[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(bike.icon,
                                        size: 80, color: Colors.blue),
                                    const SizedBox(height: 10),
                                    Text(
                                      bike.name,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () => _addToCart(bike),
                                      child: const Text('إضافة إلى السلة'),
                                    ),
                                    if (selectedBikes.containsKey(bike))
                                      Text('الكمية: ${selectedBikes[bike]}'),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: selectedBikes.isNotEmpty ? _goToCart : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('الذهاب إلى السلة'),
            ),
          ),
        ],
      ),
    );
  }
}
