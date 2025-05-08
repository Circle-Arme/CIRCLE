// lib/presentation/widgets/custom_drawer.dart
//
// Drawer مخصّص مع اختيار لغة داخل الدرج نفسه (ExpansionTile)

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/data/models/user_profile_model.dart';

import 'package:frontend/presentation/screens/profile/user_profile_page.dart';
import 'package:frontend/presentation/screens/profile/organization_profile_page.dart';
import 'package:frontend/presentation/screens/communities/my_communities_page.dart';
import 'package:frontend/presentation/screens/admin/admin_dashboard_page.dart';
import 'package:frontend/presentation/screens/admin/admin_summary_page.dart';
import 'package:frontend/presentation/screens/home/fields_page.dart';
import 'package:frontend/presentation/blocs/language/language_bloc.dart';
import 'package:frontend/presentation/blocs/language/language_event.dart';
import '../theme/app_colors.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
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
              _buildMenu(context),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /* ───────────────────────── Header ───────────────────────── */
  Widget _buildHeader(BuildContext context) {
    return FutureBuilder<UserProfileModel?>(
      future: SharedPrefs.getUserProfile(),
      builder: (ctx, snap) {
        final profile = snap.data;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          color: Colors.grey[200],
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.primaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SizedBox(height: 10.h),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.transparent,
                backgroundImage: (profile?.avatarUrl ?? '').trim().isNotEmpty
                    ? NetworkImage(profile!.avatarUrl!)
                    : const AssetImage('assets/welcome.png') as ImageProvider,
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

  /* ───────────────────────── Menu ───────────────────────── */
  Widget _buildMenu(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return FutureBuilder<UserProfileModel?>(
      future: SharedPrefs.getUserProfile(),
      builder: (_, snap) {
        final profile = snap.data;
        final userType = profile?.userType ?? 'normal';

        return Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 30.h),
            child: Column(
              children: [
                /*** ─── مستخدم عادي أو مؤسسة ─── */
                if (userType != 'admin') ...[
                  _item(
                    ctx: context,
                    icon: Icons.person,
                    title: loc.profile,
                    tap: () {
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
                  _item(
                    ctx: context,
                    icon: Icons.group,
                    title: loc.myCommunities,
                    tap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyCommunitiesPage(),
                        ),
                      );
                    },
                  ),
                  _item(
                    ctx: context,
                    icon: Icons.home,
                    title: loc.home,
                    tap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FieldsPage()),
                      );
                    },
                  ),
                ],

                /*** ─── خيارات المدير (Admin) ─── */
                if (userType == 'admin') ...[
                  _item(
                    ctx: context,
                    icon: Icons.dashboard,
                    title: loc.adminDashboard,
                    tap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminDashboardPage(),
                        ),
                      );
                    },
                  ),
                  _item(
                    ctx: context,
                    icon: Icons.assessment,
                    title: loc.summary,
                    tap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminSummaryPage(),
                        ),
                      );
                    },
                  ),
                ],

                /*** ─── اختيار اللغة داخل الدرج ─── */
                ExpansionTile(
                  leading:
                  const Icon(Icons.language, color: AppColors.primaryColor),
                  title: Text(
                    loc.language,
                    style: const TextStyle(color: AppColors.primaryColor),
                  ),
                  childrenPadding:
                  EdgeInsets.only(left: 24.w, bottom: 8.h, right: 24.w),
                  children: [
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 8.h,
                      children: [
                        _langButton(context, 'English', const Locale('en')),
                        _langButton(context, 'Arabic', const Locale('ar')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /* ───────────────────────── Helpers ───────────────────────── */
  Widget _item({
    required BuildContext ctx,
    required IconData icon,
    required String title,
    required VoidCallback tap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title, style: const TextStyle(color: AppColors.primaryColor)),
      onTap: tap,
    );
  }

  Widget _langButton(BuildContext context, String label, Locale locale) {
    return ElevatedButton(
      onPressed: () {
        context.read<LanguageBloc>().add(ChangeLanguageEvent(locale));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  /* ───────────────────────── Logout ───────────────────────── */
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
              content:
              Text(AppLocalizations.of(context)!.logoutConfirmationMessage),
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
}
