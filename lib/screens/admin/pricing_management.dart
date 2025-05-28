import 'package:flutter/material.dart';
import '../../constants/widgets.dart';

class PricingManagementScreen extends StatefulWidget {
  const PricingManagementScreen({super.key});

  @override
  State<PricingManagementScreen> createState() =>
      _PricingManagementScreenState();
}

class _PricingManagementScreenState extends State<PricingManagementScreen> {
  final Map<String, double> _prices = {
    'دراجة جبلية': 25.0,
    'دراجة كهربائية': 35.0,
    'دراجة أطفال': 15.0,
    'سكوتر كهربائي': 30.0,
  };

  void _showEditPriceDialog(String bikeType, double currentPrice) {
    final priceController =
        TextEditingController(text: currentPrice.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل سعر $bikeType'),
        content: TextField(
          controller: priceController,
          decoration: const InputDecoration(labelText: 'السعر الجديد'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: تحديث السعر
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'إدارة الأسعار',
      ),
      body: ListView.builder(
        itemCount: _prices.length,
        itemBuilder: (context, index) {
          final bikeType = _prices.keys.elementAt(index);
          final price = _prices[bikeType]!;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(bikeType),
              subtitle: Text('السعر الحالي: $price ريال/ساعة'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditPriceDialog(bikeType, price),
              ),
            ),
          );
        },
      ),
    );
  }
}
