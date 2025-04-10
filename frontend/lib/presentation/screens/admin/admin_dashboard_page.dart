import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الأدمن'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'مرحبًا بك في لوحة تحكم الأدمن!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            // يمكنك إضافة المزيد من الأدوات والوظائف الخاصة بالأدمن هنا.
            Text('أضف/حذف/تعديل البيانات من هنا.'),
          ],
        ),
      ),
    );
  }
}
