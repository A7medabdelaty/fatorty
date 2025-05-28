import 'package:flutter/material.dart';

import '../../constants/widgets.dart';
import '../../models/bike.dart';
import '../../services/bike_service.dart';
import 'cart_page.dart';

class SubscriptionPage extends StatefulWidget {
  final String customerName;
  final String customerPhone;

  const SubscriptionPage({
    Key? key,
    required this.customerName,
    required this.customerPhone,
  }) : super(key: key);

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final BikeService _bikeService = BikeService();
  List<Bike> bikes = [];
  bool _isLoading = true;
  String? _errorMessage;

  final Map<Bike, int> selectedBikes = {};
  final Map<Bike, String> subscriptionTypes = {};

  // Define subscription types and their durations in days
  final Map<String, int> _subscriptionDurations = {
    'نصف شهر': 15,
    'شهر كامل': 30,
  };

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

  void _addToCart(Bike bike, String subscriptionType) {
    setState(() {
      selectedBikes[bike] = (selectedBikes[bike] ?? 0) + 1;
      subscriptionTypes[bike] = subscriptionType;
    });
  }

  void _goToCart() {
    // Create a map of durations based on subscription types
    final Map<Bike, String> selectedDurations = {};

    // Convert subscription types to duration strings for the cart page
    for (var bike in selectedBikes.keys) {
      final subscriptionType = subscriptionTypes[bike] ?? 'نصف شهر';
      selectedDurations[bike] = subscriptionType;
    }

    // Create a map of prices based on subscription types
    final Map<String, int> durationPrices = {};
    for (var type in _subscriptionDurations.keys) {
      // For monthly subscriptions, we use the bike.price instead of hourly rate
      durationPrices[type] = _subscriptionDurations[type]!;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          selectedBikes: selectedBikes,
          customerName: widget.customerName,
          customerPhone: widget.customerPhone,
          isSubscription: true, // Flag to indicate this is a subscription
          initialDurations: selectedDurations,
          subscriptionPrices: durationPrices,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'اختيار الاشتراك',
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
                              childAspectRatio: 0.6,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
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
                                    const SizedBox(height: 8),
                                    Text(
                                      bike.name,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'السعر: ${bike.supscriptionPrice} ريال',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButton<String>(
                                      value:
                                          subscriptionTypes[bike] ?? 'نصف شهر',
                                      items: _subscriptionDurations.keys
                                          .map((String type) {
                                        return DropdownMenuItem<String>(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            subscriptionTypes[bike] = newValue;
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () => _addToCart(bike,
                                          subscriptionTypes[bike] ?? 'نصف شهر'),
                                      child: const Text('إضافة'),
                                    ),
                                    if (selectedBikes.containsKey(bike))
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'الكمية: ${selectedBikes[bike]}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
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
