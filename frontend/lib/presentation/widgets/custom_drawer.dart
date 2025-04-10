import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/data/models/user_model.dart';
import 'package:frontend/data/models/user_profile_model.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import '../theme/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/profile/user_profile_page.dart';
import 'package:frontend/presentation/screens/communities/communities_page.dart';
import 'package:frontend/presentation/screens/communities/my_communities_page.dart'; // ✅ مضافة

class CustomDrawer extends StatelessWidget {
  final UserModel? user;

  const CustomDrawer({Key? key, this.user}) : super(key: key);

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
            backgroundImage: user?.profileImageUrl != null
                ? NetworkImage(user!.profileImageUrl)
                : const AssetImage('assets/images/user.jpg') as ImageProvider,
            backgroundColor: Colors.transparent,
          ),
          SizedBox(height: 10.h),
          Text(
            user?.name ?? AppLocalizations.of(context)!.guest,
            style: const TextStyle(
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
    final loc = AppLocalizations.of(context)!;

    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 30.h),
        child: Column(
          children: [
            drawerItem(
              icon: Icons.person,
              title: loc.profile,
              context: context,
              onTap: () async {
                final profile = await SharedPrefs.getUserProfile();
                if (profile != null) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(profile: profile),
                    ),
                  );
                }
              },
            ),
            drawerItem(
              icon: Icons.group,
              title: loc.myCommunities, // تأكد أنها في .arb
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
              icon: Icons.people,
              title: loc.communities,
              context: context,
              onTap: () async {
                final savedAreaId = await SharedPrefs.getLastSelectedAreaId();
                if (savedAreaId != null) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommunitiesPage(areaId: savedAreaId),
                    ),
                  );
                } else {
                  // المستخدم لم يختَر مجال بعد – يمكنك توجيهه لصفحة اختيار المجالات
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/fields');
                }
              },

            ),
            drawerItem(
              icon: Icons.notifications,
              title: loc.notifications,
              context: context,
              onTap: () {
                Navigator.pop(context);
                // TODO: Add notifications screen
              },
            ),
            drawerItem(
              icon: Icons.settings,
              title: loc.settings,
              context: context,
              onTap: () {
                Navigator.pop(context);
                // TODO: Add settings screen
              },
            ),
          ],
        ),
      ),
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
}
