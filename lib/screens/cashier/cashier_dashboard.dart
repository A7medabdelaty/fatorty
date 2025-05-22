import 'package:bike_rental_pos/constants/colour.dart';
import 'package:bike_rental_pos/screens/cashier/new_rental.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../../constants/widgets.dart';
import '../Invoicepages/new_invoice_screen.dart';
import '../admin/reports_analytics.dart';
import 'Setting_page.dart';
import 'community.dart';
import 'manage_rentals.dart';

class CashierDashboard extends StatefulWidget {
  const CashierDashboard({super.key});

  @override
  State<CashierDashboard> createState() => _CashierDashboardState();
}

class _CashierDashboardState extends State<CashierDashboard> {
  int _selectedIndex = 1; // نبدأ من الصفحة الرئيسية (المنتصف)
  final PageController _pageController = PageController(initialPage: 1);

  final List<Widget> _pages = [
    CommunityScreen(), // يمكنك لاحقًا وضع صفحة الدردشة هنا
    const HomePage(), // الصفحة الرئيسية
    const SettingsPanel(), // صفحة الإعدادات
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: AppColors.primaryColor,
        buttonBackgroundColor: const Color(0xFF4FAAFF),
        height: 65,
        index: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          Icon(Icons.chat_bubble_rounded, size: 30, color: Colors.white),
          Icon(Icons.home_rounded, size: 30, color: Colors.white),
          Icon(Icons.settings_rounded, size: 30, color: Colors.white),
        ],
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
      ),
    );
  }
}

// الصفحة الرئيسية
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'الصفحة الرئيسية',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.9,
          children: [
            DashboardCard(
              title: 'إنشاء فاتورة',
              icon: Icons.receipt_long,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewInvoiceScreen(),
                ),
              ),
            ),
            DashboardCard(
              title: 'قائمة العملاء',
              icon: Icons.people_alt,
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerListScreen(),
                ),
              ),
            ),
            DashboardCard(
              title: 'التقارير والتحليلات',
              icon: Icons.analytics,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportsAnalyticsScreen(),
                ),
              ),
            ),
            DashboardCard(
              title: 'الاشتراكات',
              icon: Icons.subscriptions,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NewRentalScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
