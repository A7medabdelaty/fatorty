import 'dart:async';

import 'package:bike_rental_pos/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/widgets.dart';
import '../../models/bike.dart';
import '../../models/customer.dart';
import '../../models/invoice.dart';
import '../../services/bike_service.dart';
import '../../services/customer_service.dart';
import '../../services/invoice_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  final CustomerService _customerService = CustomerService();
  final BikeService _bikeService = BikeService();

  List<Map<String, dynamic>> _invoiceData = [];
  bool _isLoading = true;
  String _selectedFilter = 'الكل';
  Timer? _lateCheckTimer;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchInvoices();
    _startLateCheck();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  Future<void> _checkForLateRentals() async {
    // Fetch latest data first
    await _fetchInvoices();

    for (final data in _invoiceData) {
      final invoice = data['invoice'] as Invoice;
      final customer = data['customer'] as Customer;
      final bike = data['bike'] as Bike;

      // Only check active rentals
      if (invoice.status == 'نشط' && invoice.isLateDelivery()) {
        // Create updated invoice with late status
        final updatedInvoice = Invoice(
          id: invoice.id,
          cashierId: invoice.cashierId,
          customerId: invoice.customerId,
          bikeId: invoice.bikeId,
          startTime: invoice.startTime,
          endTime: invoice.endTime,
          totalHours: invoice.totalHours,
          totalAmount: invoice.totalAmount,
          status: 'متأخر',
          createdAt: invoice.createdAt,
        );

        // Update in database
        await _invoiceService.updateInvoice(updatedInvoice);

        // Update in local state
        setState(() {
          data['invoice'] = updatedInvoice;
        });

        // Show immediate notification for late delivery
        await _notificationService.showLateDeliveryNotification(
          customer.name,
          bike.name,
        );
      }
    }
  }

  @override
  void dispose() {
    _lateCheckTimer?.cancel();
    super.dispose();
  }

  void _startLateCheck() {
    // Check every minute for late rentals
    _lateCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkForLateRentals();
    });
  }

  Future<void> _fetchInvoices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all invoices
      final invoices = await _invoiceService.getAllInvoices();
      final invoiceDataList = <Map<String, dynamic>>[];

      for (final invoice in invoices) {
        // Get customer and bike data
        final customer =
            await _customerService.getCustomerById(invoice.customerId);
        final bike = await _bikeService.getBikeById(invoice.bikeId);

        if (customer != null && bike != null) {
          invoiceDataList.add({
            'invoice': invoice,
            'customer': customer,
            'bike': bike,
          });
        }
      }

      setState(() {
        _invoiceData = invoiceDataList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error appropriately
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الإيجارات: ${e.toString()}')));
    }
  }

  // Filter invoices based on selected filter
  List<Map<String, dynamic>> get _filteredInvoices {
    if (_selectedFilter == 'الكل') {
      return _invoiceData;
    } else {
      return _invoiceData.where((data) {
        final invoice = data['invoice'] as Invoice;
        return invoice.status == _selectedFilter;
      }).toList();
    }
  }

  // Get color based on invoice status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'مكتمل':
        return Colors.green;
      case 'نشط':
        return Colors.blue;
      case 'متأخر':
        return Colors.red;
      case 'قيد الانتظار':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Update invoice status
  Future<void> _updateInvoiceStatus(Invoice invoice, String status) async {
    final updatedInvoice = Invoice(
      id: invoice.id,
      cashierId: invoice.cashierId,
      customerId: invoice.customerId,
      bikeId: invoice.bikeId,
      startTime: invoice.startTime,
      endTime: invoice.endTime,
      totalHours: invoice.totalHours,
      totalAmount: invoice.totalAmount,
      status: status,
      createdAt: invoice.createdAt,
    );

    await _invoiceService.updateInvoice(updatedInvoice);

    // Stop periodic notifications if status changes
    if (status != 'متأخر') {
      _notificationService.stopPeriodicNotification(invoice.id.toString());
    }

    _fetchInvoices();
  }

  // Show invoice details and actions
  void _showInvoiceDetails(Map<String, dynamic> data) {
    final invoice = data['invoice'] as Invoice;
    final customer = data['customer'] as Customer;
    final bike = data['bike'] as Bike;
    final isLate = invoice.status == 'متأخر';

    // In _showInvoiceDetails method
    if (isLate) {
      _notificationService.startPeriodicLateDeliveryNotification(
        invoice.id.toString(),
        customer.name,
        bike.name,
      );
    } else {
      _notificationService.stopPeriodicNotification(invoice.id.toString());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تفاصيل الإيجار',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('العميل: ${customer.name}'),
            Text('رقم الهاتف: ${customer.phone}'),
            Text('الدراجة: ${bike.name}'),
            Text(
              'وقت البدء: ${DateFormat('yyyy-MM-dd HH:mm').format(invoice.startTime)}',
            ),
            if (invoice.endTime != null)
              Text(
                'وقت الانتهاء: ${DateFormat('yyyy-MM-dd HH:mm').format(invoice.endTime!)}',
              ),
            Text(
              'المدة: ${_formatDuration(invoice.endTime != null ? invoice.endTime!.difference(invoice.startTime) : DateTime.now().difference(invoice.startTime))}',
            ),
            Text(
              'التكلفة: ${invoice.totalAmount?.toStringAsFixed(2) ?? "غير محدد"} ريال',
            ),
            Row(
              children: [
                const Text('الحالة: '),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(invoice.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    invoice.status,
                    style: TextStyle(color: _getStatusColor(invoice.status)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'تغيير الحالة:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _statusChangeButton(invoice, 'نشط'),
                _statusChangeButton(invoice, 'مكتمل'),
                _statusChangeButton(invoice, 'متأخر'),
                _statusChangeButton(invoice, 'قيد الانتظار'),
              ],
            ),
            if (isLate) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تنبيه: هذا الإيجار متأخر عن موعد التسليم!',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Calculate hours for display if totalHours is not set
  int _calculateHours(Invoice invoice) {
    if (invoice.endTime == null) {
      final now = DateTime.now();
      return now.difference(invoice.startTime).inHours + 1;
    } else {
      return invoice.endTime!.difference(invoice.startTime).inHours + 1;
    }
  }

  // Status change button
  Widget _statusChangeButton(Invoice invoice, String status) {
    final isCurrentStatus = invoice.status == status;
    return ElevatedButton(
      onPressed: isCurrentStatus
          ? null
          : () {
              Navigator.pop(context);
              _updateInvoiceStatus(invoice, status);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isCurrentStatus ? Colors.grey : _getStatusColor(status),
        disabledBackgroundColor: Colors.grey.shade300,
      ),
      child: Text(status),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: ('إدارة الإيجارات'),
      ),
      body: Column(
        children: [
          // Filter options
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('الكل'),
                  const SizedBox(width: 8),
                  _filterChip('نشط'),
                  const SizedBox(width: 8),
                  _filterChip('مكتمل'),
                  const SizedBox(width: 8),
                  _filterChip('متأخر'),
                  const SizedBox(width: 8),
                  _filterChip('قيد الانتظار'),
                ],
              ),
            ),
          ),

          // Invoices list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredInvoices.isEmpty
                    ? const Center(child: Text('لا توجد إيجارات'))
                    : ListView.builder(
                        itemCount: _filteredInvoices.length,
                        itemBuilder: (context, index) {
                          final data = _filteredInvoices[index];
                          final invoice = data['invoice'] as Invoice;
                          final customer = data['customer'] as Customer;
                          final bike = data['bike'] as Bike;
                          final statusColor = _getStatusColor(invoice.status);

                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(customer.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('الدراجة: ${bike.name}'),
                                  Text(
                                    'بدأ: ${DateFormat('yyyy-MM-dd HH:mm').format(invoice.startTime)}',
                                  ),
                                  if (invoice.endTime != null)
                                    Text(
                                      'انتهى: ${DateFormat('yyyy-MM-dd HH:mm').format(invoice.endTime!)}',
                                    ),
                                  Text(
                                    'المدة: ${_formatDuration(invoice.endTime != null ? invoice.endTime!.difference(invoice.startTime) : DateTime.now().difference(invoice.startTime))}',
                                  ),
                                  Text(
                                    'التكلفة: ${invoice.totalAmount?.toStringAsFixed(2) ?? "غير محدد"} ريال',
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'الحالة: ',
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          invoice.status,
                                          style: TextStyle(color: statusColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () => _showInvoiceDetails(data),
                              ),
                              onTap: () => _showInvoiceDetails(data),
                            ),
                          );
                        },
                      ),
          ),

          // Refresh button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _fetchInvoices,
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == label,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: Colors.blue.shade100,
    );
  }
}

String _formatDuration(Duration duration) {
  final days = duration.inDays;
  final hours = duration.inHours.remainder(24);
  final minutes = duration.inMinutes.remainder(60);

  final parts = <String>[];
  if (days > 0) parts.add('$days يوم');
  if (hours > 0) parts.add('$hours ساعة');
  if (minutes > 0) parts.add('$minutes دقيقة');

  return parts.isEmpty ? '0 دقيقة' : parts.join(' و ');
}
