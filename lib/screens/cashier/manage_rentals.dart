import 'package:bike_rental_pos/constants/colour.dart';
import 'package:bike_rental_pos/services/bike_service.dart';
import 'package:bike_rental_pos/services/customer_service.dart';
import 'package:bike_rental_pos/services/invoice_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../../models/rental.dart';

class Customer {
  final String name;
  final String phone;
  final String status;
  final double rating;

  Customer({
    required this.name,
    required this.phone,
    required this.status,
    required this.rating,
  });
}

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'الكل';

  final List<Customer> _allCustomers = [
    Customer(name: 'سالم محمد', phone: '055117737', status: 'مكتمل', rating: 5),
    Customer(
        name: 'سالم محمد',
        phone: '055117737',
        status: 'قيد التنفيذ',
        rating: 3),
    Customer(name: 'سالم محمد', phone: '055117737', status: 'ملغي', rating: 1),
    Customer(name: 'سالم محمد', phone: '055117737', status: 'مكتمل', rating: 4),
  ];

  List<Customer> get _filteredCustomers {
    return _allCustomers.where((c) {
      final matchesStatus =
          _selectedStatus == 'الكل' || c.status == _selectedStatus;
      final matchesSearch = c.phone.contains(_searchController.text) ||
          c.name.contains(_searchController.text);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'مكتمل':
        return Colors.green;
      case 'قيد التنفيذ':
        return Colors.orange;
      case 'ملغي':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'مكتمل':
        return Icons.check_circle;
      case 'قيد التنفيذ':
        return Icons.timelapse;
      case 'ملغي':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _showCustomerDetails(Customer customer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal[50],
                  radius: 28,
                  child: const Icon(Icons.person, size: 32, color: Colors.teal),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(customer.phone,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                Icon(_statusIcon(customer.status),
                    color: _statusColor(customer.status)),
                const SizedBox(width: 4),
                Text(
                  customer.status,
                  style: TextStyle(
                      color: _statusColor(customer.status),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('التقييم: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                RatingBarIndicator(
                  rating: customer.rating,
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 22,
                  unratedColor: Colors.grey[300],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call),
                  label: const Text('اتصال'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.message),
                  label: const Text('مراسلة'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: SizedBox(
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'بحث برقم العميل أو الاسم',
                    hintStyle:
                        const TextStyle(color: Colors.white70, fontSize: 15),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('حالة الاشتراك',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 160),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'الكل', child: Text('الكل')),
                    DropdownMenuItem(value: 'مكتمل', child: Text('مكتمل')),
                    DropdownMenuItem(
                        value: 'قيد التنفيذ', child: Text('قيد التنفيذ')),
                    DropdownMenuItem(value: 'ملغي', child: Text('ملغي')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: _filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = _filteredCustomers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                  shadowColor: Colors.teal.withOpacity(0.15),
                  child: ListTile(
                    leading: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.teal[50],
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.call,
                            color: Colors.teal, size: 32),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  customer.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              const SizedBox(width: 8),
                              RatingBarIndicator(
                                rating: customer.rating,
                                itemBuilder: (context, _) =>
                                    const Icon(Icons.star, color: Colors.amber),
                                itemCount: 5,
                                itemSize: 16,
                                unratedColor: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(_statusIcon(customer.status),
                                color: _statusColor(customer.status), size: 18),
                            const SizedBox(width: 4),
                            Text(
                              customer.status,
                              style: TextStyle(
                                color: _statusColor(customer.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(customer.phone,
                          style: const TextStyle(fontSize: 13)),
                    ),
                    onTap: () => _showCustomerDetails(customer),
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

class ManageRentalsScreen extends StatefulWidget {
  const ManageRentalsScreen({super.key});

  @override
  State<ManageRentalsScreen> createState() => _ManageRentalsScreenState();
}

class _ManageRentalsScreenState extends State<ManageRentalsScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  final CustomerService _customerService = CustomerService();
  final BikeService _bikeService = BikeService();
  List<Rental> _activeRentals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchActiveRentals();
  }

  Future<void> _fetchActiveRentals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all active invoices
      final activeInvoices = await _invoiceService.getAllInvoices();
      final activeRentals = <Rental>[];

      for (final invoice in activeInvoices) {
        if (invoice.endTime == null) {
          // Only get active rentals
          // Get customer and bike data
          final customer =
              await _customerService.getCustomerById(invoice.customerId);
          final bike = await _bikeService.getBikeById(invoice.bikeId);

          if (customer != null && bike != null) {
            activeRentals.add(Rental(
              id: invoice.id.toString(),
              customer: customer,
              bike: bike,
              startTime: invoice.startTime,
              endTime: invoice.endTime,
              totalCost: invoice.totalAmount ?? 0.0,
              receiptNumber: null, // Add receipt number if available in invoice
            ));
          }
        }
      }

      setState(() {
        _activeRentals = activeRentals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error appropriately
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading rentals: ${e.toString()}')));
    }
  }

  void _endRental(Rental rental) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Rental'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${rental.customer.name}'),
            Text('Bike: ${rental.bike.name}'),
            Text(
              'Duration: ${rental.duration.inHours}h ${rental.duration.inMinutes % 60}m',
            ),
            Text(
              'Cost: \$${(rental.bike.hourlyRate! * (rental.duration.inHours + (rental.duration.inMinutes % 60 > 0 ? 1 : 0))).toStringAsFixed(2)}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Update rental record and print receipt
              setState(() {
                // Remove from active rentals
                _activeRentals.remove(rental);
              });
            },
            child: const Text('Confirm & Print'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Rentals')),
      body: _activeRentals.isEmpty
          ? const Center(child: Text('No active rentals'))
          : ListView.builder(
              itemCount: _activeRentals.length,
              itemBuilder: (context, index) {
                final rental = _activeRentals[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(rental.customer.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bike: ${rental.bike.name}'),
                        Text(
                          'Started: ${DateFormat('HH:mm').format(rental.startTime)}',
                        ),
                        Text(
                          'Duration: ${rental.duration.inHours}h ${rental.duration.inMinutes % 60}m',
                        ),
                        Text(
                          'Cost: \$${(rental.bike.hourlyRate! * (rental.duration.inHours + (rental.duration.inMinutes % 60 > 0 ? 1 : 0))).toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _endRental(rental),
                      child: const Text('End Rental'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
