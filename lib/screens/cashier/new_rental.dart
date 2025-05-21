import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/widgets.dart';
import '../../models/bike.dart';

class NewRentalScreen extends StatefulWidget {
  const NewRentalScreen({super.key});

  @override
  State<NewRentalScreen> createState() => _NewRentalScreenState();
}

class _NewRentalScreenState extends State<NewRentalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  Bike? _selectedBike;
  DateTime? _startTime;
  bool _isRentalActive = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  void _startRental() {
    if (_formKey.currentState!.validate() && _selectedBike != null) {
      setState(() {
        _startTime = DateTime.now();
        _isRentalActive = true;
      });
    }
  }

  void _endRental() {
    if (_startTime != null) {
      final endTime = DateTime.now();
      final duration = endTime.difference(_startTime!);
      final hours = duration.inHours + (duration.inMinutes % 60 > 0 ? 1 : 0);
      final cost = hours * (_selectedBike?.hourlyRate ?? 0);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rental Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${_customerNameController.text}'),
              Text('Bike: ${_selectedBike?.name}'),
              Text(
                'Duration: ${duration.inHours}h ${duration.inMinutes % 60}m',
              ),
              Text('Cost: \$${cost.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Save rental record and print receipt
                setState(() {
                  _isRentalActive = false;
                  _startTime = null;
                  _selectedBike = null;
                  _customerNameController.clear();
                  _customerPhoneController.clear();
                });
              },
              child: const Text('Confirm & Print'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'إنشاء فاتورة جديدة',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _customerPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Customer Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer phone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Bike>(
                value: _selectedBike,
                decoration: const InputDecoration(
                  labelText: 'Select Bike',
                  border: OutlineInputBorder(),
                ),
                items: [
                  // TODO: Replace with actual bike list from database
                  Bike(
                    id: 1,
                    name: 'Bike 1',
                    hourlyRate: 10,
                    icon: Icons.electric_scooter,
                    type: '',
                    status: '',
                    pricePerHour: 12,
                  ),
                  Bike(
                    id: 2,
                    name: 'Bike 2',
                    hourlyRate: 15,
                    icon: Icons.electric_scooter,
                    type: '',
                    status: '',
                    pricePerHour: 12,
                  ),
                ].map((bike) {
                  return DropdownMenuItem(
                    value: bike,
                    child: Text('${bike.name} (\$${bike.hourlyRate}/hour)'),
                  );
                }).toList(),
                onChanged: _isRentalActive
                    ? null
                    : (value) {
                        setState(() {
                          _selectedBike = value;
                        });
                      },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a bike';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_isRentalActive) ...[
                Text(
                  'Rental Started: ${DateFormat('HH:mm').format(_startTime!)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Duration: ${DateTime.now().difference(_startTime!).inHours}h ${DateTime.now().difference(_startTime!).inMinutes % 60}m',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Estimated Cost: \$${(_selectedBike?.hourlyRate ?? 0) * (DateTime.now().difference(_startTime!).inHours + (DateTime.now().difference(_startTime!).inMinutes % 60 > 0 ? 1 : 0))}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: _isRentalActive ? _endRental : _startRental,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_isRentalActive ? 'End Rental' : 'Start Rental'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
