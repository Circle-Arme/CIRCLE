import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF326E80);
  static const Color primaryColorLight0 = Color(0xFF4E8A98);
  static const Color secondaryColor = Color(0xFFBDC5C6);
  static const Color primaryColorLight = Color(0xFFE9F1F2);
  static const borderColor = primaryColor;

  static const Color primaryColorLight1 = Color(0xFFE0F3F6); // أفتح درجة
  static const Color primaryColorLight2 = Color(0xFFB3DDE6); // أفتح بدرجة أقل
  static const Color primaryColorLight3 = Color(0xFF80C4D3); // متوسطة الفاتح
  static const Color primaryColorLight4 = Color(0xFF4DAAC0); // قريبة من الأساسي لكن أفتح

  // ألوان الخطوط
  static const Color textPrimary = Color(0xFF1A3C47); // لون داكن قريب من primaryColor للنصوص الأساسية
  static const Color textSecondary = Color(0xFF6B7A80); // لون رمادي داكن للنصوص الثانوية

  // ألوان الخلفية للتدرج
  static const Color backgroundLight = Color(0xFFE9F1F2); // نفس primaryColorLight1
  static const Color backgroundDark = Color(0xFFE0F3F6);  // نفس primaryColorLight2
}