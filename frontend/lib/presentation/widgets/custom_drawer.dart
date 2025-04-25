import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // استيراد flutter_bloc
import 'package:frontend/data/models/user_model.dart';
import 'package:frontend/data/models/user_profile_model.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import '../theme/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/profile/user_profile_page.dart';
import 'package:frontend/presentation/screens/profile/organization_profile_page.dart';
import 'package:frontend/presentation/screens/communities/my_communities_page.dart';
import 'package:frontend/presentation/screens/admin/admin_dashboard_page.dart';
import 'package:frontend/presentation/screens/home/fields_page.dart';
import 'package:frontend/presentation/blocs/language/language_bloc.dart'; // استيراد LanguageBloc
import 'package:frontend/presentation/blocs/language/language_event.dart'; // استيراد LanguageEvent

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key); // إزالة معامل user

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
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FutureBuilder<UserProfileModel?>(
      future: SharedPrefs.getUserProfile(), // جلب الملف التعريفي من SharedPrefs
      builder: (context, snapshot) {
        final profile = snapshot.data;
        return Container(
          color: Colors.grey[200],
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  color: AppColors.primaryColor,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              SizedBox(height: 10.h),
              CircleAvatar(
                radius: 40,
                backgroundImage: const AssetImage('assets/images/user.jpg'), // إزالة الاعتماد على user
                backgroundColor: Colors.transparent,
              ),
              SizedBox(height: 10.h),
              Text(
                profile?.name ?? AppLocalizations.of(context)!.guest,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return FutureBuilder<UserProfileModel?>(
      future: SharedPrefs.getUserProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final userType = profile?.userType ?? 'normal'; // استخدام userType من UserProfileModel

        return Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 30.h),
            child: Column(
              children: [
                drawerItem(
                  icon: Icons.person,
                  title: loc.profile,
                  context: context,
                  onTap: () {
                    if (profile != null) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => userType == 'organization'
                              ? OrganizationProfilePage(profile: profile)
                              : ProfilePage(profile: profile),
                        ),
                      );
                    }
                  },
                ),
                drawerItem(
                  icon: Icons.group,
                  title: loc.myCommunities,
                  context: context,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyCommunitiesPage(),
                      ),
                    );
                  },
                ),
                drawerItem(
                  icon: Icons.home,
                  title: loc.home,
                  context: context,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FieldsPage(),
                      ),
                    );
                  },
                ),
                if (userType == 'admin') // خيار إداري
                  drawerItem(
                    icon: Icons.admin_panel_settings,
                    title: loc.adminDashboard,
                    context: context,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminDashboardPage(),
                        ),
                      );
                    },
                  ),
                drawerItem(
                  icon: Icons.language,
                  title: loc.language,
                  context: context,
                  onTap: () {
                    _showLanguageDialog(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// باقي الكود (_showLanguageDialog, _buildLogoutButton, drawerItem) يبقى كما هو
}

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // تغيير اللغة إلى الإنجليزية باستخدام LanguageBloc
                  context.read<LanguageBloc>().add(ChangeLanguageEvent(const Locale('en')));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                ),
                child: const Text(
                  'English',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 20.w),
              ElevatedButton(
                onPressed: () {
                  // تغيير اللغة إلى العربية باستخدام LanguageBloc
                  context.read<LanguageBloc>().add(ChangeLanguageEvent(const Locale('ar')));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                ),
                child: const Text(
                  'Arabic',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      color: AppColors.primaryColor,
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.logoutConfirmationTitle),
              content: Text(AppLocalizations.of(context)!.logoutConfirmationMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    AppLocalizations.of(context)!.logout,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            Navigator.of(context).pop();
            await AuthService.logout();
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: Text(
          AppLocalizations.of(context)!.logout,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget drawerItem({
    required IconData icon,
    required String title,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title, style: const TextStyle(color: AppColors.primaryColor)),
      onTap: onTap,
    );
  }
