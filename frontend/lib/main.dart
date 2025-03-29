import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screens/try2.dart'; // عدّل حسب مسار تطبيقك
import 'screens/discussion_room_page.dart';
import 'models/thread_model.dart.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411, 819), // مثل جهاز Pixel 8 Pro
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          // الوضع العادي (فاتح)
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            primaryColor: const Color(0xFF2A6776),
            fontFamily: 'Roboto',
          ),

          // الوضع الداكن
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: Colors.tealAccent[200],
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent[200],
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[800],
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
          ),

          // التبديل التلقائي حسب النظام
          themeMode: ThemeMode.system,

          home: const DiscussionRoomPage(),
        );
      },
    );
  }
}
