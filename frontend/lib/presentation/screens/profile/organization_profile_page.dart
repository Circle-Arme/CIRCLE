// organization_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:frontend/data/models/user_profile_model.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/presentation/widgets/custom_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

/*--------------------- ألوان وثوابت ---------------------*/
const _primaryColor = Color(0xFF326B80);            // الأزرق الأساسي
const _appBarBg     = Color(0xFFE9F1F2);            // خلفية الـ AppBar
const _dividerThick = .8;                           // سُمك الخط الفاصل

class OrganizationProfilePage extends StatelessWidget {
  final UserProfileModel profile;
  final bool isOwnProfile;

  const OrganizationProfilePage({
    Key? key,
    required this.profile,
    this.isOwnProfile = true,
  }) : super(key: key);

  /*------------------------ تغيير كلمة المرور ------------------------*/
  void _showChangePasswordDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final oldCtl  = TextEditingController();
    final newCtl  = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.changePassword),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldCtl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: loc.oldPassword,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? loc.passwordHint : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: newCtl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: loc.newPassword,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return loc.passwordHint;
                  if (v.length < 6) return loc.shortPassword;
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel, style: const TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await AuthService.changePassword(
                      oldCtl.text.trim(), newCtl.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(loc.passwordChangedSuccess)));
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('${loc.error}: $e')));
                }
              }
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }

  /*----------------------------- build -----------------------------*/
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: isOwnProfile ? const CustomDrawer() : null,
      appBar: AppBar(
        backgroundColor: _appBarBg,
        elevation: 0,
        leading: isOwnProfile
            ? Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: _primaryColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        )
            : null,
        centerTitle: true,
        title: Text(
          loc.organizationProfile.toUpperCase(),
          style: TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: _primaryColor),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('15',
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
            ],
          ),
        ],
      ),

      /*--------------------------- Body ---------------------------*/
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*----------------- Avatar + Name + Tagline ----------------*/
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: const Color(0xFFE1ECF4),
                    child: const Icon(Icons.apartment,
                        size: 40, color: _primaryColor),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    profile.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 17.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    profile.workEducation,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),
            _divider(),

            /*------------------------- Description -------------------------*/
            SizedBox(height: 16.h),
            _sectionTitle(loc.description),
            SizedBox(height: 6.h),
            Text(
              profile.description.isEmpty
                  ? loc.defaultDescription
                  : profile.description,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),

            SizedBox(height: 24.h),
            _divider(),

            /*------------------------- Communities -------------------------*/
            SizedBox(height: 16.h),
            _sectionTitle(loc.communities),
            SizedBox(height: 8.h),
            if (profile.communities.isEmpty)
              Text(loc.noCommunitiesJoined,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]))
            else
              Column(
                children: profile.communities.map((c) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Row(
                      children: [
                        const Icon(Icons.groups,
                            size: 18, color: _primaryColor),
                        SizedBox(width: 8.w),
                        Text(c, style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                  );
                }).toList(),
              ),

            SizedBox(height: 24.h),
            _divider(),

            /*----------------------- Contact & Website ----------------------*/
            SizedBox(height: 16.h),
            _linkLine(
              prefix: loc.contactMeAt,
              linkText: profile.email.isEmpty ? loc.defaultEmail : profile.email,
              onTap: profile.email.isEmpty
                  ? null
                  : () => launchUrl(Uri(scheme: 'mailto', path: profile.email)),
            ),
            SizedBox(height: 8.h),
            if (profile.website != null && profile.website!.isNotEmpty)
              _linkLine(
                prefix: loc.websiteLabel,
                linkText: profile.website!,
                onTap: () => launchUrl(Uri.parse(profile.website!)),
              ),

            /*-------------------- Change Password Button --------------------*/
            if (isOwnProfile) ...[
              SizedBox(height: 32.h),
              Center(
                child: ElevatedButton(
                  onPressed: () => _showChangePasswordDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    padding:
                    EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r)),
                  ),
                  child: Text(loc.changePassword,
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /*---------------------- Widgets صغيرة مساعدة ----------------------*/

  Widget _divider() =>
      const Divider(thickness: _dividerThick, color: _primaryColor);

  Widget _sectionTitle(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.bold,
      color: _primaryColor,
    ),
  );

  /// سطر رابط مثل: "Contact me at example@mail.com"
  Widget _linkLine({
    required String prefix,
    required String linkText,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 14.sp, color: Colors.black),
          children: [
            TextSpan(
              text: "$prefix ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: linkText,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
