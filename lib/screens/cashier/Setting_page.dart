import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/widgets.dart';
import '../login_screen.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({Key? key}) : super(key: key);

  @override
  _SettingsPanelState createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  // إعدادات المستخدم
  bool _isDarkMode = false;
  String _selectedLanguage = 'ar';
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _biometricEnabled = false;
  String _selectedTheme = 'system';
  String _selectedFontSize = 'medium';
  bool _isRTL = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'الاعدادات',
      ),
      body: CustomScrollView(
        slivers: [
          // قسم الملف الشخصي
          SliverToBoxAdapter(
            child: _buildProfileSection(),
          ),

          // قسم الإعدادات العامة
          SliverPadding(
            padding: const EdgeInsets.only(top: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('الإعدادات العامة'),
                _buildSettingItem(
                  icon: Icons.dark_mode,
                  title: 'الوضع المظلم',
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: (v) => setState(() => _isDarkMode = v),
                    activeColor: theme.primaryColor,
                  ),
                ),
                _buildSettingItem(
                  icon: Icons.language,
                  title: 'اللغة',
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    items: ['ar', 'en']
                        .map((lang) => DropdownMenuItem(
                              value: lang,
                              child: Text(lang == 'ar' ? 'العربية' : 'English'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedLanguage = v!),
                  ),
                ),
                _buildSettingItem(
                  icon: Icons.text_fields,
                  title: 'حجم الخط',
                  trailing: DropdownButton<String>(
                    value: _selectedFontSize,
                    items: ['small', 'medium', 'large']
                        .map((size) => DropdownMenuItem(
                              value: size,
                              child: Text(size == 'small'
                                  ? 'صغير'
                                  : size == 'medium'
                                      ? 'متوسط'
                                      : 'كبير'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedFontSize = v!),
                  ),
                ),
                _buildSettingItem(
                  icon: Icons.format_textdirection_r_to_l,
                  title: 'اتجاه النص',
                  trailing: Switch(
                    value: _isRTL,
                    onChanged: (v) => setState(() => _isRTL = v),
                    activeColor: theme.primaryColor,
                  ),
                ),
              ]),
            ),
          ),

          // قسم الإشعارات
          SliverPadding(
            padding: const EdgeInsets.only(top: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('الإشعارات'),
                _buildSettingItem(
                  icon: Icons.notifications,
                  title: 'تفعيل الإشعارات',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (v) => setState(() => _notificationsEnabled = v),
                    activeColor: theme.primaryColor,
                  ),
                ),
                if (_notificationsEnabled) ...[
                  _buildSettingItem(
                    icon: Icons.volume_up,
                    title: 'صوت الإشعارات',
                    trailing: Switch(
                      value: _soundEnabled,
                      onChanged: (v) => setState(() => _soundEnabled = v),
                      activeColor: theme.primaryColor,
                    ),
                  ),
                  _buildSettingItem(
                    icon: Icons.vibration,
                    title: 'اهتزاز الإشعارات',
                    trailing: Switch(
                      value: _vibrationEnabled,
                      onChanged: (v) => setState(() => _vibrationEnabled = v),
                      activeColor: theme.primaryColor,
                    ),
                  ),
                ],
              ]),
            ),
          ),

          // قسم الأمان
          SliverPadding(
            padding: const EdgeInsets.only(top: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('الأمان'),
                _buildSettingItem(
                  icon: Icons.fingerprint,
                  title: 'البصمة/الوجه',
                  subtitle: 'تسجيل الدخول بالبصمة',
                  trailing: Switch(
                    value: _biometricEnabled,
                    onChanged: (v) => setState(() => _biometricEnabled = v),
                    activeColor: theme.primaryColor,
                  ),
                ),
                _buildSettingItem(
                  icon: Icons.lock,
                  title: 'تغيير كلمة المرور',
                  onTap: _showChangePasswordDialog,
                ),
              ]),
            ),
          ),

          // قسم الدعم والمساعدة
          SliverPadding(
            padding: const EdgeInsets.only(top: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('الدعم والمساعدة'),
                _buildSettingItem(
                  icon: Icons.help_center,
                  title: 'الأسئلة الشائعة',
                  onTap: () => _showHelpDialog(),
                ),
                _buildSettingItem(
                  icon: Icons.support_agent,
                  title: 'الدعم الفني',
                  onTap: () => _contactSupport(),
                ),
                _buildSettingItem(
                  icon: Icons.privacy_tip,
                  title: 'سياسة الخصوصية',
                  onTap: () => _showPrivacyPolicy(),
                ),
                _buildSettingItem(
                  icon: Icons.description,
                  title: 'شروط الاستخدام',
                  onTap: () => _showTerms(),
                ),
              ]),
            ),
          ),

          // قسم حول التطبيق
          SliverPadding(
            padding: const EdgeInsets.only(top: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('حول التطبيق'),
                _buildSettingItem(
                  icon: Icons.info,
                  title: 'عن التطبيق',
                  onTap: () => _showAboutDialog(),
                ),
                _buildSettingItem(
                  icon: Icons.star_rate,
                  title: 'قيم التطبيق',
                  onTap: () => _rateApp(),
                ),
                _buildSettingItem(
                  icon: Icons.share,
                  title: 'مشاركة التطبيق',
                  onTap: () => _shareApp(),
                ),
              ]),
            ),
          ),

          // زر تسجيل الخروج
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('تسجيل الخروج'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _confirmLogout,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Hero(
            tag: 'profile-avatar',
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'محمد أحمد',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'كاشير - فرع الرياض',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('تعديل الملف'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => _navigateToProfile(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: const Border(
        bottom: BorderSide(
          color: Colors.grey,
          width: 0.2,
        ),
      ),
    );
  }

  // ================ دوال التنفيذ ================ //

  void _navigateToProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الملف الشخصي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('محمد أحمد'),
              subtitle: Text('كاشير - فرع الرياض'),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('mohamed@example.com'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('01012345678'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الحالية',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور الجديدة',
                prefixIcon: Icon(Icons.lock_reset),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: تغيير كلمة المرور
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الأسئلة الشائعة'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('س: كيف أضيف فاتورة جديدة؟'),
              Text('ج: من شاشة الفواتير اضغط على زر +.'),
              SizedBox(height: 12),
              Text('س: كيف أعدل بياناتي؟'),
              Text('ج: من صفحة الإعدادات اضغط على "تعديل الملف".'),
              SizedBox(height: 12),
              Text('س: كيف أتواصل مع الدعم؟'),
              Text('ج: من صفحة الإعدادات اضغط على "الدعم الفني".'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الدعم الفني'),
        content: const Text(
            'للتواصل مع الدعم الفني:\nواتساب: 01000000000\nبريد: support@example.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سياسة الخصوصية'),
        content: const SingleChildScrollView(
          child: Text(
              'سياسة الخصوصية: جميع بياناتك سرية ولن يتم مشاركتها مع أي طرف ثالث. هذا النص توضيحي فقط.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('شروط الاستخدام'),
        content: const SingleChildScrollView(
          child: Text(
              'شروط الاستخدام: يجب عليك احترام القوانين وعدم إساءة استخدام التطبيق. هذا النص توضيحي فقط.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Fatorty App',
      applicationVersion: 'الإصدار 1.0.0',
      applicationIcon: const Icon(Icons.shopping_cart),
      children: [
        const Text('تطبيق إدارة المبيعات ونقاط البيع'),
        const SizedBox(height: 16),
        const Text('© 2024 جميع الحقوق محفوظة'),
      ],
    );
  }

  void _rateApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قيم التطبيق'),
        content: const Text('ميزة التقييم غير مفعلة حالياً. شكراً لدعمك!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مشاركة التطبيق'),
        content: const Text('رابط التطبيق: https://example.com/app'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('نسخ الرابط'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}

// طريقة فتح صفحة الإعدادات
void openSettingsPanel(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const SettingsPanel(),
    ),
  );
}
