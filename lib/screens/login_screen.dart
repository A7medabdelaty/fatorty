import 'package:bike_rental_pos/constants/colour.dart';
import 'package:flutter/material.dart';

import '../constants/widgets.dart';
import 'admin/admin_dashboard.dart';
import 'cashier/cashier_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.cashier;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      // مثال بسيط على التحقق اليدوي - عدّله حسب النظام الحقيقي
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      if (username == 'Mr.Emad123@gmail.com' && password == 'E123456789@') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else if (username == 'cashier' &&
          password == 'cashier123' &&
          _selectedRole == UserRole.cashier) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CashierDashboard()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('بيانات الدخول غير صحيحة')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: size.width > 600 ? 500 : double.infinity,
                  ),
                  child: Card(
                    elevation: 12,
                    color: Colors.white,
                    shadowColor: const Color(0xFF0D47A1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Hero(
                              tag: 'logo',
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.blueAccent,
                                    width: 3,
                                  ),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'مرحباً بك في نظام تأجير الدراجات',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.SecondaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'تسجيل الدخول للوصول إلى النظام',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 30),
                            DropdownButtonFormField<UserRole>(
                              value: _selectedRole,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              items: UserRole.values.map((role) {
                                final roleName =
                                    role.toString().split('.').last;
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(
                                    roleName == 'admin'
                                        ? 'مدير النظام'
                                        : 'كاشير',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedRole = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            buildTextField(
                              controller: _usernameController,
                              label: 'اسم المستخدم',
                              icon: Icons.person,
                              validatorMsg: 'الرجاء إدخال اسم المستخدم',
                            ),
                            const SizedBox(height: 20),
                            buildTextField(
                              controller: _passwordController,
                              label: 'كلمة المرور',
                              icon: Icons.lock,
                              isPassword: true,
                              validatorMsg: 'الرجاء إدخال كلمة المرور',
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: AppColors.primaryColor,
                                ),
                                child: const Text(
                                  'تسجيل الدخول',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: () {},
                              label: const Text(
                                'نسيت كلمة المرور؟',
                                style: TextStyle(
                                  color: AppColors.SecondaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum UserRole { admin, cashier }
