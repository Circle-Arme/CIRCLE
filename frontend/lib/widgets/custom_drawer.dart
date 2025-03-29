import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../models/user_model.dart';

class CustomDrawer extends StatelessWidget {
  final UserModel user;
  const CustomDrawer({Key? key, required this.user}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final drawerWidth = isLandscape ? 250.0 : 300.0;

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildMenuItems(context),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                color: AppColors.primaryColor,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/user.jpg'), // or NetworkImage
            backgroundColor: Colors.transparent,
          ),
          SizedBox(height: 10.h),
          const Text(
            "User Name",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 30.h),
        child: Column(
          children: [
            drawerItem(Icons.people, "COMMUNITIES", context),
            drawerItem(Icons.notifications, "NOTIFICATIONS", context),
            drawerItem(Icons.settings, "SETTINGS", context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      color: AppColors.primaryColor,
      width: double.infinity,
      child: TextButton(
        onPressed: () {},
        child: const Text("Log out", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget drawerItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title, style: const TextStyle(color: AppColors.primaryColor)),
      onTap: () => Navigator.pop(context),
    );
  }
}
