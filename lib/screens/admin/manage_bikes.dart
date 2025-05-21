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
    final hourlyRateController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    final typeController = TextEditingController();
    final statusController = TextEditingController();
    final iconController = TextEditingController();
    final pricePerHourController = TextEditingController();

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
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(
                    labelText: 'النوع (مثال: جبلية، كهربائية)'),
              ),
              TextField(
                controller: statusController,
                decoration:
                    const InputDecoration(labelText: 'الحالة (مثال: متاحة)'),
              ),
              TextField(
                controller: pricePerHourController,
                decoration:
                    const InputDecoration(labelText: 'سعر الساعة (الحقيقي)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: hourlyRateController,
                decoration:
                    const InputDecoration(labelText: 'سعر الساعة (اختياري)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'السعر (اختياري)'),
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
                hourlyRate: double.tryParse(hourlyRateController.text),
                price: double.tryParse(priceController.text),
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
                  Text('سعر الساعة: ${bike.pricePerHour} ريال'),
                  if (bike.price != null) Text('السعر: ${bike.price} ريال'),
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
