import 'package:flutter/material.dart';

import '../../constants/widgets.dart';
import '../../db/database_helper.dart';
import '../../models/cashier.dart';

class ManageCashiersScreen extends StatefulWidget {
  const ManageCashiersScreen({super.key});

  @override
  State<ManageCashiersScreen> createState() => _ManageCashiersScreenState();
}

class _ManageCashiersScreenState extends State<ManageCashiersScreen> {
  List<Cashier> _cashiers = [];
  List<bool> _showPasswords = [];

  @override
  void initState() {
    super.initState();
    fetchCashiers();
  }

  Future<void> fetchCashiers() async {
    final cashiersData = await DatabaseHelper().getCashiers();
    setState(() {
      _cashiers = cashiersData.map((e) => Cashier.fromMap(e)).toList();
      _showPasswords = List.generate(_cashiers.length, (_) => false);
    });
  }

  void _showAddCashierDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    ValueNotifier<bool> showPassword = ValueNotifier(false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إضافة كاشير جديد',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: showPassword,
                builder: (context, value, child) => TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon:
                          Icon(value ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => showPassword.value = !value,
                    ),
                  ),
                  obscureText: !value,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
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
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
            onPressed: () async {
              final cashier = Cashier(
                name: nameController.text,
                phone: phoneController.text,
                email: emailController.text,
                password: passwordController.text,
              );
              await DatabaseHelper().insertCashier(cashier.toMap());
              await fetchCashiers();
              Navigator.pop(context);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditCashierDialog(Cashier cashier) {
    final nameController = TextEditingController(text: cashier.name);
    final emailController = TextEditingController(text: cashier.email ?? '');
    final phoneController = TextEditingController(text: cashier.phone ?? '');
    final passwordController = TextEditingController(text: cashier.password);
    ValueNotifier<bool> showPassword = ValueNotifier(false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تعديل بيانات الكاشير',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: showPassword,
                builder: (context, value, child) => TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon:
                          Icon(value ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => showPassword.value = !value,
                    ),
                  ),
                  obscureText: !value,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
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
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
            onPressed: () async {
              final updatedCashier = cashier.copyWith(
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
                password: passwordController.text,
              );
              await DatabaseHelper().updateCashier(updatedCashier.toMap());
              await fetchCashiers();
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCashier(int id) async {
    await DatabaseHelper().deleteCashier(id);
    await fetchCashiers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'إدارة الكاشير',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCashierDialog,
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: ListView.builder(
          itemCount: _cashiers.length,
          itemBuilder: (context, index) {
            final cashier = _cashiers[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[200],
                    child: Text(
                      cashier.name.isNotEmpty ? cashier.name[0] : '?',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  title: Text(
                    cashier.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cashier.email != null && cashier.email!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.email,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                cashier.email!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      if (cashier.phone != null && cashier.phone!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.phone,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              cashier.phone!,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      Row(
                        children: [
                          const Icon(Icons.lock, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showPasswords[index] =
                                      !_showPasswords[index];
                                });
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _showPasswords.length > index &&
                                              _showPasswords[index]
                                          ? cashier.password
                                          : '*' * cashier.password.length,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 13, letterSpacing: 2),
                                    ),
                                  ),
                                  Icon(
                                    _showPasswords.length > index &&
                                            _showPasswords[index]
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'تعديل',
                        onPressed: () => _showEditCashierDialog(cashier),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'حذف',
                        onPressed: () async {
                          if (cashier.id != null) {
                            await _deleteCashier(cashier.id!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
