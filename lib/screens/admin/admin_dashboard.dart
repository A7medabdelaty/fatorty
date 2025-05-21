import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../constants/colour.dart';
import '../../constants/widgets.dart';
import '../Invoicepages/NewInvoiceScreen.dart';
import '../cashier/community.dart';
import '../cashier/setting_page.dart';
import '../../screens/admin/manage_cashiers.dart';
import '../../screens/admin/manage_bikes.dart';
import '../../screens/admin/pricing_management.dart';
import '../../screens/admin/invoices_management.dart';
import '../../screens/admin/reports_analytics.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  final List<Widget> _pages = [
    CommunityScreen(), //  ممكن تحط صفحة الشات هنا لاحقًا
    const AdminHomePage(), // الصفحة الرئيسية
    const SettingsPanel(), // الإعدادات
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

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
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
              title: 'إدارة الكاشير',
              icon: Icons.people,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageCashiersScreen(),
                ),
              ),
            ),
            DashboardCard(
              title: 'إدارة الدراجات',
              icon: Icons.directions_bike,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageBikesScreen(),
                ),
              ),
            ),
            DashboardCard(
              title: 'إدارة الأسعار',
              icon: Icons.attach_money,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PricingManagementScreen(),
                ),
              ),
            ),
            DashboardCard(
              title: 'إدارة الفواتير',
              icon: Icons.receipt,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InvoicesManagementScreen(),
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
          ],
        ),
      ),
    );
  }
}
