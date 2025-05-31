import 'package:flutter/material.dart';

import '../../constants/widgets.dart';
import '../../db/database_helper.dart';
import '../../models/bike.dart';

class ManageBikesScreen extends StatefulWidget {
  const ManageBikesScreen({super.key});

  @override
  State<ManageBikesScreen> createState() => _ManageBikesScreenState();
}

class _ManageBikesScreenState extends State<ManageBikesScreen> {
  List<Bike> _bikes = [];

  @override
  void initState() {
    super.initState();
    fetchBikes();
  }

  Future<void> fetchBikes() async {
    final bikesData = await DatabaseHelper().getBikes();
    setState(() {
      _bikes = bikesData.map((e) => Bike.fromMap(e)).toList();
    });
  }

  void _showAddBikeDialog() {
    final nameController = TextEditingController();
    final pricePerHalfHourController = TextEditingController();
    final supscriptionPriceController = TextEditingController();
    final descriptionController = TextEditingController();
    final typeController = TextEditingController();
    final statusController = TextEditingController();
    final iconController = TextEditingController();
    final pricePerHourController = TextEditingController();
    final pricePerQuarterHourController = TextEditingController();
    final pricePerTwoHoursController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة دراجة جديدة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الدراجة'),
                textDirection: TextDirection.rtl,
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(
                    labelText: 'النوع (مثال: جبلية، كهربائية)'),
                textDirection: TextDirection.rtl,
              ),
              // Apply to all other TextFields as well
              TextField(
                controller: statusController,
                decoration:
                    const InputDecoration(labelText: 'الحالة (مثال: متاحة)'),
              ),
              TextField(
                controller: pricePerHourController,
                decoration: const InputDecoration(labelText: 'سعر الساعة'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: pricePerQuarterHourController,
                decoration: const InputDecoration(labelText: 'سعر ربع ساعة'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: pricePerHalfHourController,
                decoration: const InputDecoration(labelText: 'سعر نصف ساعة '),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: pricePerTwoHoursController,
                decoration: const InputDecoration(labelText: 'سعر الساعتين '),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: supscriptionPriceController,
                decoration:
                    const InputDecoration(labelText: 'سعر الإشتراك الشهري'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
                maxLines: 3,
              ),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                    labelText: 'اسم الأيقونة (مثال: pedal_bike)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final bike = Bike(
                name: nameController.text,
                type: typeController.text,
                status: statusController.text,
                icon: Icons.electric_scooter,
                pricePerHour:
                    double.tryParse(pricePerHourController.text) ?? 0.0,
                pricePerHalfHour:
                    double.tryParse(pricePerHalfHourController.text),
                pricePerQuarterHour:
                    double.tryParse(pricePerQuarterHourController.text),
                pricePerTwoHours:
                    double.tryParse(pricePerTwoHoursController.text),
                supscriptionPrice:
                    double.tryParse(supscriptionPriceController.text),
                description: descriptionController.text,
                //icon: iconController.text.isNotEmpty ? iconController.text : null,
              );
              await DatabaseHelper().insertBike(bike.toMap());
              await fetchBikes();
              Navigator.pop(context);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBike(int id) async {
    await DatabaseHelper().deleteBike(id);
    await fetchBikes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'إدارة الدراجات',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddBikeDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _bikes.length,
        itemBuilder: (context, index) {
          final bike = _bikes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(bike.icon, size: 32),
              title: Text(bike.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bike.pricePerHalfHour != null)
                    Text('سعر نصف ساعة: ${bike.pricePerHalfHour} ريال'),
                  Text('سعر الساعة: ${bike.pricePerHour} ريال'),
                  if (bike.pricePerTwoHours != null)
                    Text('سعر ساعتين: ${bike.pricePerTwoHours} ريال'),
                  if (bike.supscriptionPrice != null)
                    Text('سعر الإشتراك الشهري: ${bike.supscriptionPrice} ريال'),
                  if (bike.description != null) Text(bike.description!),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      if (bike.id != null) {
                        await _deleteBike(bike.id!);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
