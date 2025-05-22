import 'package:bike_rental_pos/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/colour.dart';
import '../../constants/widgets.dart';
import 'bike_selection_page.dart';

class NewInvoiceScreen extends StatefulWidget {
  const NewInvoiceScreen({super.key});

  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController hoursController = TextEditingController();
  final TextEditingController _priceController =
      TextEditingController(text: '0');
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  // final _priceController = TextEditingController(text: '45');
  final _durationController = TextEditingController(text: '1');

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  final CustomerService _customerService = CustomerService();

  Future<void> _checkCustomer(String phone) async {
    if (phone.length == 11) {
      try {
        final customer = await _customerService.getCustomerByPhone(phone);
        if (customer != null) {
          setState(() {
            _nameController.text = customer.name;
          });
        }
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'إنشاء فاتورة جديدة',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerInfoCard(),
              const SizedBox(height: 20),
              _buildProductInfoCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------
  // عناصر الشاشة الفرعية:
  // --------------------------

  Widget _buildCustomerInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات العميل',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              onChanged: (value) {
                if (value.length == 11) {
                  _checkCustomer(value);
                }
              },
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                prefixIcon: const Icon(Icons.phone),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
                }
                if (value.length != 11) {
                  return 'رقم الهاتف يجب أن يكون 11 رقمًا';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم العميل',
                prefixIcon: const Icon(Icons.person),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم العميل';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات المنتج',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BikeSelectionPage(
                      customerName: _nameController.text,
                      customerPhone: _phoneController.text,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColors.primaryColor,
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Text(
                'إختيار نوع الدراجة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BikeSelectionPage(
                      customerName: _nameController.text,
                      customerPhone: _phoneController.text,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColors.primaryColor,
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Text(
                'إضافة اشتراك جديد',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
