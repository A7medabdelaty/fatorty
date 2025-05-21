import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants/widgets.dart';
import '../../models/rental.dart';
import '../../providers/rental_provider.dart';

class SearchRentalsScreen extends StatefulWidget {
  const SearchRentalsScreen({super.key});

  @override
  State<SearchRentalsScreen> createState() => _SearchRentalsScreenState();
}

class _SearchRentalsScreenState extends State<SearchRentalsScreen> {
  final _searchController = TextEditingController();
  List<Rental> _filteredRentals = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterRentals);
    // Fetch rentals when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalProvider>().fetchRentals();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRentals() {
    final provider = context.read<RentalProvider>();
    final searchText = _searchController.text.toLowerCase();
    setState(() {
      _filteredRentals = provider.rentals.where((rental) {
        return rental.customer.name.toLowerCase().contains(searchText) ||
            rental.customer.phone.toLowerCase().contains(searchText) ||
            rental.bike.name.toLowerCase().contains(searchText);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RentalProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        _filteredRentals = provider.rentals;

        return Scaffold(
          appBar: const CustomAppBar(
            title: 'البحث عن الفواتير',
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search by name, phone, or receipt number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: _filteredRentals.isEmpty
                    ? const Center(child: Text('No rentals found'))
                    : ListView.builder(
                        itemCount: _filteredRentals.length,
                        itemBuilder: (context, index) {
                          final rental = _filteredRentals[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(rental.customer.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Phone: ${rental.customer.phone}'),
                                  Text(
                                    'Date: ${DateFormat('yyyy-MM-dd').format(rental.startTime)}',
                                  ),
                                  Text('Receipt #: ${rental.receiptNumber}'),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _viewRentalDetails(rental, context),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void _viewRentalDetails(Rental rental, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Rental Details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receipt #: ${rental.receiptNumber}'),
            Text('Customer: ${rental.customer.name}'),
            Text('Phone: ${rental.customer.phone}'),
            Text('Bike: ${rental.bike.name}'),
            Text(
              'Start Time: ${DateFormat('yyyy-MM-dd HH:mm').format(rental.startTime)}',
            ),
            if (rental.endTime != null)
              Text(
                'End Time: ${DateFormat('yyyy-MM-dd HH:mm').format(rental.endTime!)}',
              ),
            Text(
              'Duration: ${rental.duration.inHours}h ${rental.duration.inMinutes % 60}m',
            ),
            Text('Total Cost: \$${rental.totalCost.toStringAsFixed(2)}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // TODO: Implement reprint receipt functionality
          },
          child: const Text('Reprint Receipt'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
