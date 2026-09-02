import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color? iconColor;
  final Color? circleColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor,
    this.circleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultCircleColor = isDark
        ? Colors.indigo.shade900.withValues(alpha: 0.3)
        : Colors.indigo.shade50;
    final defaultIconColor =
        isDark ? const Color(0xFF818CF8) : Colors.indigo.shade400;
    final titleColor = isDark ? Colors.white : Colors.grey.shade800;
    final msgColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: circleColor ?? defaultCircleColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: iconColor ?? defaultIconColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: msgColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
