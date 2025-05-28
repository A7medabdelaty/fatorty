import 'package:flutter/material.dart';

import '../../constants/widgets.dart';
import '../../models/bike.dart';
import '../../services/bike_service.dart';

class PricingManagementScreen extends StatefulWidget {
  const PricingManagementScreen({super.key});

  @override
  State<PricingManagementScreen> createState() =>
      _PricingManagementScreenState();
}

class _PricingManagementScreenState extends State<PricingManagementScreen> {
  final BikeService _bikeService = BikeService();
  List<Bike> _bikes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBikes();
  }

  Future<void> _loadBikes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final bikes = await _bikeService.getAllBikes();
      setState(() {
        _bikes = bikes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل بيانات الدراجات: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showEditPriceDialog(Bike bike) {
    final hourlyController =
        TextEditingController(text: bike.pricePerHour.toString());
    final halfHourController = TextEditingController(
        text: (bike.pricePerHalfHour ?? (bike.pricePerHour / 2)).toString());
    final twoHoursController = TextEditingController(
        text: (bike.pricePerTwoHours ?? (bike.pricePerHour * 2)).toString());
    final subscriptionController =
        TextEditingController(text: (bike.supscriptionPrice ?? 0).toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل أسعار ${bike.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: halfHourController,
                decoration:
                    const InputDecoration(labelText: 'سعر النصف ساعة (ريال)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: hourlyController,
                decoration:
                    const InputDecoration(labelText: 'سعر الساعة (ريال)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: twoHoursController,
                decoration:
                    const InputDecoration(labelText: 'سعر الساعتين (ريال)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: subscriptionController,
                decoration: const InputDecoration(
                    labelText: 'سعر الاشتراك الشهري (ريال)'),
                keyboardType: TextInputType.number,
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
              try {
                // تحديث نموذج الدراجة بالأسعار الجديدة
                final updatedBike = Bike(
                  id: bike.id,
                  name: bike.name,
                  type: bike.type,
                  status: bike.status,
                  pricePerHour: double.tryParse(hourlyController.text) ??
                      bike.pricePerHour,
                  pricePerHalfHour: double.tryParse(halfHourController.text),
                  pricePerTwoHours: double.tryParse(twoHoursController.text),
                  supscriptionPrice:
                      double.tryParse(subscriptionController.text),
                  icon: bike.icon,
                  description: bike.description,
                  createdAt: bike.createdAt,
                );

                // حفظ التغييرات في قاعدة البيانات
                await _bikeService.updateBike(updatedBike);

                // إغلاق الحوار وإعادة تحميل البيانات
                Navigator.pop(context);
                _loadBikes();

                // عرض رسالة نجاح
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تحديث الأسعار بنجاح')),
                );
              } catch (e) {
                // عرض رسالة خطأ
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('فشل في تحديث الأسعار: ${e.toString()}')),
                );
              }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _bikes.isEmpty
                  ? const Center(child: Text('لا توجد دراجات متاحة'))
                  : ListView.builder(
                      itemCount: _bikes.length,
                      itemBuilder: (context, index) {
                        final bike = _bikes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      bike.name,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () =>
                                          _showEditPriceDialog(bike),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('النوع: ${bike.type}'),
                                const SizedBox(height: 4),
                                Text(
                                    'سعر النصف ساعة: ${bike.pricePerHalfHour ?? (bike.pricePerHour / 2)} ريال'),
                                const SizedBox(height: 4),
                                Text('سعر الساعة: ${bike.pricePerHour} ريال'),
                                const SizedBox(height: 4),
                                Text(
                                    'سعر الساعتين: ${bike.pricePerTwoHours ?? (bike.pricePerHour * 2)} ريال'),
                                const SizedBox(height: 4),
                                Text(
                                    'سعر الاشتراك الشهري: ${bike.supscriptionPrice ?? "غير متوفر"} ريال'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadBikes,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
