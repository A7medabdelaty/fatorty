import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image/image.dart' as img;
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

import '../../constants/widgets.dart';
import '../../models/bike.dart';
import '../../models/customer.dart';
import '../../models/invoice.dart';
import '../../services/customer_service.dart';
import '../../services/invoice_service.dart';

class InvoicePage extends StatefulWidget {
  final String customerName;
  final String customerPhone;
  final Map<Bike, int> selectedBikes;
  final Map<Bike, String> selectedDurations;
  final Map<String, int> durationPrices;
  final double totalAmount;
  final DateTime pickupTime; // استقبال pickupTime
  //final DateTime deliveryTime;  // استقبال deliveryTime
  final Map<Bike, DateTime> deliveryTimes;

  const InvoicePage({
    Key? key,
    required this.customerName,
    required this.customerPhone,
    required this.selectedBikes,
    required this.selectedDurations,
    required this.durationPrices,
    required this.totalAmount,
    required this.pickupTime,
    //required this.deliveryTime,
    required this.deliveryTimes,
  }) : super(key: key);

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  double customerRating = 0.0;
  final CustomerService _customerService = CustomerService();
  final InvoiceService _invoiceService = InvoiceService();
  bool _isSaving = false;
  String? _errorMessage;
  int? _savedCustomerId;

  @override
  void initState() {
    SunmiPrinter.initPrinter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final receiptNumber =
        'RCPT${now.millisecondsSinceEpoch.toString().substring(8)}';

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'فاتورة',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.teal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.customerName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.phone, color: Colors.teal),
                    const SizedBox(width: 4),
                    Text(
                      widget.customerPhone,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'قيّم العميل:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    RatingBar.builder(
                      initialRating: customerRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 30,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          customerRating = rating;
                        });
                        print('تم تقييم العميل بـ: $rating');
                      },
                    ),
                    _buildInfoRow('وقت الاستلام:',
                        '${widget.pickupTime.hour}:${widget.pickupTime.minute.toString().padLeft(2, '0')}'),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionCard(
                          child: Column(
                            children: [
                              _buildInfoRow('المنتج:', 'دراجات هوائية'),
                              ...widget.selectedBikes.entries.map((entry) {
                                final bike = entry.key;
                                final quantity = entry.value;
                                final duration =
                                    widget.selectedDurations[bike] ??
                                        '30 دقيقة';
                                final price =
                                    widget.durationPrices[duration] ?? 0;
                                final deliveryTime = widget.deliveryTimes[bike];

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(
                                        bike.name, '$quantity في $duration'),
                                    _buildInfoRow(
                                        'السعر:', '${price * quantity} ريال'),
                                    if (deliveryTime != null)
                                      _buildInfoRow('وقت التسليم:',
                                          '${deliveryTime.hour}:${deliveryTime.minute.toString().padLeft(2, '0')}'),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSectionCard(
                          child: _buildInfoRow(
                            'المجموع:',
                            '${widget.totalAmount} ريال',
                            valueStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'شروط الاستئجار:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildConditionItem(
                                  'يجب المحافظة على الدراجة وإعادتها بحالة جيدة'),
                              _buildConditionItem(
                                  'يجب الالتزام بالوقت المحدد للإيجار'),
                              _buildConditionItem(
                                  'يتحمل المستأجر أضرار تلحق بالدراجة'),
                              _buildConditionItem(
                                  'يجب إبراز الهوية عند الاستئجار'),
                              _buildConditionItem(
                                  'لا يحق للمستأجر إعطاء الدراجة لشخص آخر'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isSaving ? null : printInvoice,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008080),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'تأكيد',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> printInvoice() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final customerId = await _getOrCreateCustomer();
      _savedCustomerId = customerId;

      // 2. حفظ الفاتورة لكل دراجة
      for (var entry in widget.selectedBikes.entries) {
        final bike = entry.key;
        final quantity = entry.value;
        final duration = widget.selectedDurations[bike] ?? '30 دقيقة';
        final price = widget.durationPrices[duration] ?? 0;
        final totalAmount = price * quantity * (bike.pricePerHour / 60);

        // استخدام قيمة افتراضية للكاشير (1) حتى يتم تنفيذ نظام المصادقة الكامل
        // في التطبيق الحقيقي، يجب الحصول على معرف الكاشير من نظام المصادقة
        const cashierId =
            1; // TODO: استبدال بمعرف الكاشير الفعلي من نظام المصادقة

        final invoice = Invoice(
          cashierId: cashierId,
          bikeId: bike.id!,
          customerId: customerId,
          startTime: widget.pickupTime,
          endTime: widget.deliveryTimes[bike],
          totalHours: _calculateTotalHours(
              widget.pickupTime, widget.deliveryTimes[bike]),
          totalAmount: totalAmount,
          status: 'نشط', // الحالة الأولية للفاتورة
        );

        await _invoiceService.addInvoice(invoice);
      }

      // 3. طباعة الفاتورة
      //await _printReceiptToSunmiPrinter();

      // 4. عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الفاتورة وطباعتها بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في حفظ الفاتورة: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<int> _getOrCreateCustomer() async {
    try {
      final existingCustomer =
          await _customerService.getCustomerByPhone(widget.customerPhone);

      if (existingCustomer != null) {
        return existingCustomer.id!;
      }

      final newCustomer = Customer(
        name: widget.customerName,
        phone: widget.customerPhone,
      );

      final customerId = await _customerService.addCustomer(newCustomer);
      return customerId;
    } catch (e) {
      throw Exception('فشل في حفظ بيانات العميل: ${e.toString()}');
    }
  }

  int? _calculateTotalHours(DateTime startTime, DateTime? endTime) {
    if (endTime == null) return null;

    final difference = endTime.difference(startTime);
    return (difference.inMinutes / 60).ceil(); // تقريب لأقرب ساعة
  }

  Future<void> _printReceiptToSunmiPrinter() async {
    await SunmiPrinter.bindingPrinter();

    final byteData = await rootBundle.load('assets/images/logo.jpg');
    final bytes = byteData.buffer.asUint8List();
    img.Image? original = img.decodeImage(bytes);

    final now = DateTime.now();

    // --- Header with Logo and Business Name ---
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    if (original != null) {
      img.Image grayscale = img.grayscale(original);
      final grayscaleBytes = img.encodeJpg(grayscale);
      await SunmiPrinter.printImage(grayscaleBytes);
    }
    await SunmiPrinter.printText('الدراجات BIKE',
        style: SunmiTextStyle(fontSize: 28, bold: true));
    await SunmiPrinter.line();
    await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
    await SunmiPrinter.printText('مؤسسة عائلة دراوي محمد دخان لتأجير الدراجات');
    await SunmiPrinter.printText('الدمام - لايف بارك');
    await SunmiPrinter.printText('رقم التسجيل: 1-27375-1');
    await SunmiPrinter.printText(
        'التاريخ: ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
    // await SunmiPrinter.printText('رقم الطلب: ${widget.orderNumber ?? "-"}');
    // await SunmiPrinter.printText('الكاشير: ${widget.cashierName ?? "-"}');
    await SunmiPrinter.line();

    // --- Bike Details ---
    await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
    for (var entry in widget.selectedBikes.entries) {
      final bike = entry.key;
      final quantity = entry.value;
      final duration = widget.selectedDurations[bike] ?? '';
      final price = widget.durationPrices[duration] ?? 0;
      await SunmiPrinter.printText('${bike.name} × $quantity  $duration');
      await SunmiPrinter.printText('السعر: ${price * quantity} SAR');
    }
    await SunmiPrinter.line();

    // --- Total and Payment ---
    await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT);
    await SunmiPrinter.printText('الإجمالي: ${widget.totalAmount} SAR');
    await SunmiPrinter.printText('طريقة الدفع: Card');
    await SunmiPrinter.line();

    // --- Terms and Conditions ---
    await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
    await SunmiPrinter.printText('الشروط والأحكام:');
    await SunmiPrinter.printText('1- يتحمل المستأجر أي أضرار أو تلف.');
    await SunmiPrinter.printText('2- يجب الإلتزام بالوقت المحدد للإيجار.');
    await SunmiPrinter.printText('3- يمنع إعطاء الدراجة لشخص آخر.');
    await SunmiPrinter.printText('4- يجب إبراز الهوية عند الإستئجار.');
    await SunmiPrinter.printText(
        '5- الشركة غير مسؤولة عن الحوادث خارج الحديقة.');
    await SunmiPrinter.line();

    // --- Footer ---
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('0541642611');
    await SunmiPrinter.printText('شكرًا لكم!');
    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.cutPaper();
  }

  int getTotalDurationInMinutes() {
    int total = 0;

    for (var duration in widget.selectedDurations.values) {
      if (duration.contains('ساعة')) {
        final hours = int.tryParse(duration.split(' ')[0]) ?? 0;
        total += hours * 60;
      } else if (duration.contains('دقيقة')) {
        final minutes = int.tryParse(duration.split(' ')[0]) ?? 0;
        total += minutes;
      }
    }

    return total == 0
        ? 30
        : total; // إذا لم يتم حساب شيء، فلتكن القيمة الافتراضية 30 دقيقة
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF008080),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: valueStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildConditionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '- ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
