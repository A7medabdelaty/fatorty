import 'package:flutter/material.dart';

import 'colour.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required String validatorMsg,
  bool isPassword = false,
}) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return validatorMsg;
      }
      return null;
    },
  );
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? textColor;
  final double elevation;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.backgroundColor,
    this.textColor,
    this.elevation = 0,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.primaryColor,
      elevation: elevation,
      centerTitle: false,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: textColor ?? Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      title: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
