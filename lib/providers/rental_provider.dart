import 'package:flutter/material.dart';

import '../models/rental.dart';
import '../services/bike_service.dart';
import '../services/customer_service.dart';
import '../services/invoice_service.dart';

class RentalProvider extends ChangeNotifier {
  final InvoiceService _invoiceService = InvoiceService();
  final CustomerService _customerService = CustomerService();
  final BikeService _bikeService = BikeService();

  List<Rental> _rentals = [];
  bool _isLoading = false;
  String? _error;

  List<Rental> get rentals => _rentals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRentals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final invoices = await _invoiceService.getAllInvoices();
      final rentals = <Rental>[];

      for (final invoice in invoices) {
        final customer =
            await _customerService.getCustomerById(invoice.customerId);
        final bike = await _bikeService.getBikeById(invoice.bikeId);

        if (customer != null && bike != null) {
          rentals.add(Rental(
            id: invoice.id.toString(),
            customer: customer,
            bike: bike,
            startTime: invoice.startTime,
            endTime: invoice.endTime,
            totalCost: invoice.totalAmount ?? 0.0,
            receiptNumber: null, // Add if you have receipt numbers in invoices
          ));
        }
      }

      _rentals = rentals;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
