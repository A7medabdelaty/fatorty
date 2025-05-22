import 'package:flutter/material.dart';

import '../../constants/widgets.dart';
import '../../models/bike.dart';
import 'invoice_page.dart';

class CartPage extends StatefulWidget {
  final Map<Bike, int> selectedBikes;
  final String customerName;
  final String customerPhone;

  const CartPage({
    Key? key,
    required this.selectedBikes,
    required this.customerName,
    required this.customerPhone,
  }) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Map<Bike, String> _selectedDurations = {};
  final Map<String, int> _durationPrices = {
    '15 دقيقة': 15,
    '30 دقيقة': 30,
    'ساعة واحدة': 60,
    'ساعتين': 120,
  };

  @override
  void initState() {
    super.initState();
    for (var bike in widget.selectedBikes.keys) {
      _selectedDurations[bike] = '30 دقيقة';
    }
  }

  double calculateTotal() {
    double total = 0;
    widget.selectedBikes.forEach((bike, quantity) {
      final durationPrice = (_durationPrices[_selectedDurations[bike]]! *
              (bike.pricePerHour / 60))
          .round();
      total += durationPrice * quantity;
    });
    return total;
  }

  Duration parseDuration(String durationText) {
    switch (durationText) {
      case '15 دقيقة':
        return const Duration(minutes: 15);
      case '30 دقيقة':
        return const Duration(minutes: 30);
      case 'ساعة واحدة':
        return const Duration(hours: 1);
      case 'ساعتين':
        return const Duration(hours: 2);
      default:
        return const Duration(minutes: 30);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = calculateTotal();

    return Scaffold(
      appBar: const CustomAppBar(title: 'السلة'),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.selectedBikes.length,
              itemBuilder: (context, index) {
                final bike = widget.selectedBikes.keys.elementAt(index);
                final quantity = widget.selectedBikes[bike]!;
                final currentDuration = _selectedDurations[bike] ?? '30 دقيقة';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(bike.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('الكمية: $quantity',
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'اختر مدة الاستخدام:',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: currentDuration,
                          isExpanded: true,
                          items: _durationPrices.keys.map((String duration) {
                            return DropdownMenuItem<String>(
                              value: duration,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(duration),
                                  Text(
                                      '${_durationPrices[duration]! * bike.pricePerHour / 60} ريال'),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDurations[bike] = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('المجموع:',
                                style: TextStyle(fontSize: 16)),
                            Text(
                              '${((_durationPrices[currentDuration]! * bike.pricePerHour / 60) * quantity)} ريال',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المجموع الكلي:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$total ريال',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final now = DateTime.now();
                    final pickupTime = now;

                    // نحسب مدة ووقت التسليم لكل دراجة على حدة
                    Map<Bike, Duration> bikeDurations = {};
                    Map<Bike, DateTime> deliveryTimes = {};

                    widget.selectedBikes.forEach((bike, _) {
                      final durationString = _selectedDurations[bike]!;
                      final duration = parseDuration(durationString);
                      bikeDurations[bike] = duration;
                      deliveryTimes[bike] = pickupTime.add(duration);
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InvoicePage(
                          customerName: widget.customerName,
                          customerPhone: widget.customerPhone,
                          selectedBikes: widget.selectedBikes,
                          selectedDurations: _selectedDurations,
                          durationPrices: _durationPrices,
                          totalAmount: total,
                          pickupTime: pickupTime,
                          deliveryTimes: deliveryTimes, // أرسل الخريطة الجديدة
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('إنشاء الفاتورة والدفع'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
