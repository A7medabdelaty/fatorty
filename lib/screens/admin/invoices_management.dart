import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/widgets.dart';
import '../../db/database_helper.dart';
import '../../models/bike.dart';
import '../../models/rental.dart';
import '../../services/bike_service.dart';
import '../../services/customer_service.dart';
import '../../services/invoice_service.dart';

class InvoicesManagementScreen extends StatefulWidget {
  const InvoicesManagementScreen({super.key});

  @override
  State<InvoicesManagementScreen> createState() =>
      _InvoicesManagementScreenState();
}

class _InvoicesManagementScreenState extends State<InvoicesManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'الكل';
  DateTime? _startDate;
  DateTime? _endDate;
  List<Bike> _bikes = [];
  List<Rental> _rentals = [];
  bool _isLoading = true;

  final InvoiceService _invoiceService = InvoiceService();
  final CustomerService _customerService = CustomerService();
  final BikeService _bikeService = BikeService();

  @override
  void initState() {
    super.initState();
    fetchBikes();
    fetchRentals();
  }

  Future<void> fetchBikes() async {
    final bikesData = await DatabaseHelper().getBikes();
    setState(() {
      _bikes = bikesData.map((e) => Bike.fromMap(e)).toList();
    });
  }

  Future<void> fetchRentals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all invoices
      final invoices = await _invoiceService.getAllInvoices();

      // Convert invoices to rentals
      final List<Rental> rentals = [];

      for (final invoice in invoices) {
        // Get customer and bike for each invoice
        final customer =
            await _customerService.getCustomerById(invoice.customerId);
        final bike = await _bikeService.getBikeById(invoice.bikeId);

        if (customer != null && bike != null) {
          // Create rental from invoice data
          final rental = Rental(
            id: invoice.id.toString(),
            customer: customer,
            bike: bike,
            startTime: invoice.startTime,
            endTime: invoice.endTime,
            totalCost: invoice.totalAmount ?? 0.0,
            receiptNumber: 'RCPT-${invoice.id}',
          );

          rentals.add(rental);
        }
      }

      setState(() {
        _rentals = rentals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      print('Error fetching rentals: $e');
    }
  }

  List<Rental> get _filteredRentals {
    return _rentals.where((rental) {
      final matchesStatus = _selectedStatus == 'الكل' ||
          (_selectedStatus == 'نشط' && rental.isActive) ||
          (_selectedStatus == 'مكتمل' && !rental.isActive);

      final matchesSearch =
          rental.customer.name.contains(_searchController.text) ||
              rental.customer.phone.contains(_searchController.text) ||
              (rental.receiptNumber != null &&
                  rental.receiptNumber!.contains(_searchController.text));

      final matchesDate =
          (_startDate == null || rental.startTime.isAfter(_startDate!)) &&
              (_endDate == null || rental.startTime.isBefore(_endDate!));

      return matchesStatus && matchesSearch && matchesDate;
    }).toList();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'إدارة الفواتير',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'بحث',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'الحالة',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'الكل', child: Text('الكل')),
                          DropdownMenuItem(value: 'نشط', child: Text('نشط')),
                          DropdownMenuItem(
                              value: 'مكتمل', child: Text('مكتمل')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedStatus = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_startDate == null
                            ? 'من تاريخ'
                            : DateFormat('yyyy/MM/dd').format(_startDate!)),
                        onPressed: () => _selectDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_endDate == null
                            ? 'إلى تاريخ'
                            : DateFormat('yyyy/MM/dd').format(_endDate!)),
                        onPressed: () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredRentals.length,
              itemBuilder: (context, index) {
                final rental = _filteredRentals[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(rental.customer.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rental.customer.phone),
                        Text('رقم الفاتورة: ${rental.receiptNumber}'),
                        Text('المبلغ: ${rental.totalCost} ريال'),
                        Text(
                            'التاريخ: ${DateFormat('yyyy/MM/dd HH:mm').format(rental.startTime)}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () {
                        // TODO: عرض تفاصيل الفاتورة
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
