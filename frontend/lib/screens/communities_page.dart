import 'package:flutter/material.dart';
import '../models/area_model.dart';
import '../theme/app_colors.dart';

class CommunitiesPage extends StatelessWidget {
  final AreaModel area;
  const CommunitiesPage({Key? key, required this.area}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${area.title} Communities"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        titleTextStyle: const TextStyle(
          color: AppColors.primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: Text("عرض المجتمعات الخاصة بـ ${area.title}"),
      ),
    );
  }
}