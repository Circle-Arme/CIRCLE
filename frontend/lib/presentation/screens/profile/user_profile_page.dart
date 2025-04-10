import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/data/models/user_profile_model.dart';
import 'package:frontend/core/services/UserProfileService.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import '../../widgets/custom_drawer.dart';
import '../communities/communities_page.dart';
import 'package:url_launcher/url_launcher.dart';


class ProfilePage extends StatefulWidget {
  final UserProfileModel profile;
  final bool isOwnProfile;

  const ProfilePage({
    Key? key,
    required this.profile,
    this.isOwnProfile = true,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserProfileModel _profile;
  bool _hasChanges = false; // يظهر الزر العائم فقط إذا أجريت تغييرات

  // Controllers لاستخدامها داخل الحوار
  late TextEditingController _nameController;
  late TextEditingController _workEducationController;
  late TextEditingController _positionController;
  late TextEditingController _descriptionController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _nameController = TextEditingController(text: _profile.name);
    _workEducationController = TextEditingController(text: _profile.workEducation);
    _positionController = TextEditingController(text: _profile.position);
    _descriptionController = TextEditingController(text: _profile.description);
    _emailController = TextEditingController(text: _profile.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _workEducationController.dispose();
    _positionController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// حفظ الملف الشخصي في الباكند وتحديث التخزين المحلي
  Future<void> _saveProfile() async {
    final loc = AppLocalizations.of(context)!;
    try {
      await UserProfileService.saveUserProfile(_profile);
      await UserProfileService.saveUserProfileLocally(_profile);
      setState(() {
        _hasChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.saveSuccess)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.saveError}: $e')),
      );
    }
  }

  /// حوار موحد لتعديل (Name, Work/Education, Position)
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.editProfile),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: _workEducationController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.workEducation),
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: _positionController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.position),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF326B80)),
              onPressed: () {
                // تحقق إذا تغيرت القيم
                if (_nameController.text != _profile.name ||
                    _workEducationController.text != _profile.workEducation ||
                    _positionController.text != _profile.position) {
                  setState(() {
                    _profile = _profile.copyWith(
                      name: _nameController.text,
                      workEducation: _workEducationController.text,
                      position: _positionController.text,
                    );
                    _hasChanges = true;
                  });
                }
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      // تأكد من استخدام Builder لزر القائمة (Drawer)
      drawer: widget.isOwnProfile ? const CustomDrawer() : null,
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDE6E6),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF326B80)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: Text(
          loc.profile,
          style: TextStyle(
            color: const Color(0xFF326B80),
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Color(0xFF326B80)),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Text('15', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: widget.isOwnProfile && _hasChanges
          ? FloatingActionButton(
        onPressed: _saveProfile,
        child: const Icon(Icons.save),
      )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            if (_profile.isNewUser && widget.isOwnProfile)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Text(
                  loc.completeYourProfile,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
            profileCard(),
            SizedBox(height: 25.h),
            descriptionCard(),
            SizedBox(height: 25.h),
            communitySection(),
            SizedBox(height: 25.h),
            contactSection(),
          ],
        ),
      ),
    );
  }

  /// البطاقة الأولى: عرض الاسم، التعليم/العمل والمنصب مع أيقونة تعديل واحدة
  Widget profileCard() {
    final cardColor = const Color(0xFFDDE6E6);
    final loc = AppLocalizations.of(context)!;

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1.r)),
      child: Padding(
        padding: EdgeInsets.all(25.w),
        child: Stack(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: const Color(0xFF819FAFFF),
                  child: Icon(Icons.person, size: 25.r, color: const Color(0xFF326B80)),
                ),
                SizedBox(width: 40.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_profile.name,
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red)),
                      SizedBox(height: 4.h),
                      Text(_profile.workEducation,
                          style: TextStyle(fontSize: 16.sp, color: const Color(0xFF326B80))),
                      SizedBox(height: 4.h),
                      Text(_profile.position,
                          style: TextStyle(fontSize: 16.sp, color: const Color(0xFF326B80))),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.isOwnProfile)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue, size: 20.r),
                  onPressed: _showEditProfileDialog,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// بطاقة الوصف تبقى كما هي مع أيقونة تعديل فردية
  Widget descriptionCard() {
    final cardColor = const Color(0xFFDDE6E6);
    final loc = AppLocalizations.of(context)!;
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.description,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16.sp)),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _profile.description.isEmpty ? loc.writeDescription : _profile.description,
                    style: TextStyle(fontSize: 16.sp, color: const Color(0xFF326B80)),
                  ),
                ),
                if (widget.isOwnProfile)
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue, size: 20.r),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(loc.description,
                              style: TextStyle(color: const Color(0xFF326B80))),
                          content: TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                                hintText: loc.writeDescription,
                                border: const OutlineInputBorder()),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(loc.cancel, style: const TextStyle(color: Colors.red)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF326B80)),
                              onPressed: () {
                                setState(() {
                                  _profile = _profile.copyWith(
                                    description: _descriptionController.text,
                                  );
                                  _hasChanges = true;
                                });
                                Navigator.pop(context);
                              },
                              child: Text(loc.save),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة المجتمعات تبقى كما هي مع تعديل بسيط
  Widget communitySection() {
    final cardColor = const Color(0xFFDDE6E6);
    final loc = AppLocalizations.of(context)!;
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.communities,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16.sp)),
            SizedBox(height: 8.h),
            _profile.communities.isEmpty
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.noCommunitiesJoined,
                  style: TextStyle(fontSize: 16.sp, color: const Color(0xFF326B80)),
                ),
                if (widget.isOwnProfile) ...[
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    onPressed: () async {
                      final savedAreaId = await SharedPrefs.getLastSelectedAreaId();
                      if (savedAreaId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommunitiesPage(areaId: savedAreaId),
                          ),
                        );
                      } else {
                        Navigator.pushNamed(context, '/fields');
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF326B80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    child: Text(loc.joinCommunity,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ],
            )
                : Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _profile.communities
                  .map((c) => CommunityBox(title: c))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة التواصل (البريد الإلكتروني)

  Widget contactSection() {
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          // نص: Contact me at + الإيميل
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_profile.email.isNotEmpty) {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: _profile.email,
                  );
                  launchUrl(emailUri);
                }
              },
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16.sp, color: const Color(0xFF326B80)),
                  children: [
                    TextSpan(text: '${loc.contactMeAt} '),
                    TextSpan(
                      text: _profile.email.isNotEmpty ? _profile.email : loc.writeEmail,
                      style: const TextStyle(decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // أيقونة التعديل
          if (widget.isOwnProfile)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue, size: 20.r),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(loc.emailLabel, style: TextStyle(color: const Color(0xFF326B80))),
                    content: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(loc.cancel, style: const TextStyle(color: Colors.red)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF326B80)),
                        onPressed: () {
                          setState(() {
                            _profile = _profile.copyWith(email: _emailController.text);
                            _hasChanges = true;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(loc.save),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

}

/// بطاقة المجتمع كما هي
class CommunityBox extends StatelessWidget {
  final String title;

  const CommunityBox({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
