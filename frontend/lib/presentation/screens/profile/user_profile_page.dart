// lib/presentation/screens/profile/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:frontend/data/models/user_profile_model.dart';
import 'package:frontend/data/models/community_model.dart';
import 'package:frontend/core/services/UserProfileService.dart';
import 'package:frontend/core/services/CommunityService.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import '../../widgets/custom_drawer.dart';
import '../communities/communities_page.dart';

/* --------------------------- الثوابت --------------------------- */
const _primaryColor = Color(0xFF326B80);
const _headerBg     = Color(0xFFE9F1F2);
/* -------------------------------------------------------------- */

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
  bool _hasChanges = false;

  late final TextEditingController _nameCtl;
  late final TextEditingController _workCtl;
  late final TextEditingController _posCtl;
  late final TextEditingController _descCtl;
  late final TextEditingController _emailCtl;

  late Future<List<CommunityModel>> _communitiesFuture;

  @override
  void initState() {
    super.initState();
    _profile  = widget.profile;
    _nameCtl  = TextEditingController(text: _profile.name);
    _workCtl  = TextEditingController(text: _profile.workEducation);
    _posCtl   = TextEditingController(text: _profile.position);
    _descCtl  = TextEditingController(text: _profile.description);
    _emailCtl = TextEditingController(text: _profile.email);

    // نختار Future لجلب المجتمعات سواء للمستخدم الحالي أو أي مستخدم آخر
    if (widget.isOwnProfile) {
      _communitiesFuture = CommunityService.fetchMyCommunities();
    } else {
      _communitiesFuture =
          CommunityService.fetchCommunitiesForUser(_profile.userId);
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _workCtl.dispose();
    _posCtl.dispose();
    _descCtl.dispose();
    _emailCtl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final loc = AppLocalizations.of(context)!;
    try {
      await UserProfileService.saveUserProfile(_profile);
      await UserProfileService.saveUserProfileLocally(_profile);
      setState(() => _hasChanges = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loc.saveSuccess)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${loc.saveError}: $e')));
    }
  }

  void _editDialog(String field, TextEditingController ctl, String label) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label, style: const TextStyle(color: _primaryColor)),
        content: TextField(
          controller: ctl,
          maxLines: field == 'description' ? 3 : 1,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: label,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel, style: const TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            onPressed: () {
              setState(() {
                switch (field) {
                  case 'name':
                    _profile = _profile.copyWith(name: ctl.text);
                    break;
                  case 'workEducation':
                    _profile = _profile.copyWith(workEducation: ctl.text);
                    break;
                  case 'position':
                    _profile = _profile.copyWith(position: ctl.text);
                    break;
                  case 'description':
                    _profile = _profile.copyWith(description: ctl.text);
                    break;
                  case 'email':
                    _profile = _profile.copyWith(email: ctl.text);
                    break;
                }
                _hasChanges = true;
              });
              Navigator.pop(context);
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityRow(String name) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          const Icon(Icons.groups, size: 18, color: _primaryColor),
          SizedBox(width: 8.w),
          Text(name, style: TextStyle(fontSize: 14.sp)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: widget.isOwnProfile ? const CustomDrawer() : null,
      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        leading: widget.isOwnProfile
            ? Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: _primaryColor),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        )
            : null,
        centerTitle: true,
        title: Text(
          loc.profile.toUpperCase(),
          style: TextStyle(
            color: _primaryColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
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
      floatingActionButton: widget.isOwnProfile && _hasChanges
          ? FloatingActionButton(
        onPressed: _saveProfile,
        backgroundColor: _primaryColor,
        child: const Icon(Icons.save, color: Colors.white),
      )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // — Header —
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: const Color(0xFFE1ECF4),
                  child:
                  const Icon(Icons.person, size: 30, color: _primaryColor),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _inlineEditable(
                        text: _profile.name.isEmpty
                            ? loc.writeName
                            : _profile.name,
                        controller: _nameCtl,
                        field: 'name',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      _inlineEditable(
                        text: _profile.workEducation.isEmpty
                            ? loc.writeWorkEducation
                            : _profile.workEducation,
                        controller: _workCtl,
                        field: 'workEducation',
                        style:
                        TextStyle(fontSize: 13.sp, color: Colors.black87),
                      ),
                      if (_profile.position.isNotEmpty ||
                          widget.isOwnProfile)
                        _inlineEditable(
                          text: _profile.position.isEmpty
                              ? loc.writePosition
                              : _profile.position,
                          controller: _posCtl,
                          field: 'position',
                          style: TextStyle(
                              fontSize: 13.sp, color: Colors.black87),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // — Description —
            SizedBox(height: 24.h),
            _divider(),
            SizedBox(height: 16.h),
            _sectionTitle(loc.description),
            SizedBox(height: 6.h),
            _inlineEditable(
              text: widget.isOwnProfile
                  ? (_profile.description.isEmpty
                  ? loc.writeDescription
                  : _profile.description)
                  : (_profile.description.isEmpty ? '_' : _profile.description),
              controller: _descCtl,
              field: 'description',
              multiline: true,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),

            // — Communities — always visible, no toggle
            SizedBox(height: 24.h),
            _divider(),
            SizedBox(height: 16.h),
            _sectionTitle(loc.communities),
            SizedBox(height: 8.h),
            FutureBuilder<List<CommunityModel>>(
              future: _communitiesFuture,
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return Text(
                    loc.noCommunitiesJoined,
                    style:
                    TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  );
                }
                return Column(
                  children:
                  list.map((c) => _buildCommunityRow(c.name)).toList(),
                );
              },
            ),
            if (widget.isOwnProfile) ...[
              SizedBox(height: 12.h),
              OutlinedButton.icon(
                onPressed: () async {
                  final areaId = await SharedPrefs.getLastSelectedAreaId();
                  if (areaId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommunitiesPage(areaId: areaId),
                      ),
                    );
                  } else {
                    Navigator.pushNamed(context, '/fields');
                  }
                },
                icon: const Icon(Icons.add, color: _primaryColor),
                label: Text(
                  loc.joinCommunity,
                  style: const TextStyle(color: _primaryColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _primaryColor),
                ),
              ),
            ],

            // — Contact —
            SizedBox(height: 24.h),
            _divider(),
            SizedBox(height: 16.h),
            Row(
              children: [
                Text("${loc.contactMeAt} ",
                    style: TextStyle(fontSize: 14.sp)),
                GestureDetector(
                  onTap: _profile.email.isNotEmpty
                      ? () => launchUrl(
                      Uri(scheme: 'mailto', path: _profile.email.trim()))
                      : null,
                  child: _inlineEditable(
                    text: _profile.email.isEmpty
                        ? loc.writeEmail
                        : _profile.email,
                    controller: _emailCtl,
                    field: 'email',
                    isEmail: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      const Divider(thickness: .8, color: _primaryColor);

  Widget _sectionTitle(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.bold,
      color: _primaryColor,
    ),
  );

  Widget _inlineEditable({
    required String text,
    required TextEditingController controller,
    required String field,
    required TextStyle style,
    bool multiline = false,
    bool isEmail = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
      multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Flexible(child: Text(text, style: style)),
        if (widget.isOwnProfile)
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.edit, size: 18, color: _primaryColor),
            onPressed: () => _editDialog(
              field,
              controller,
              isEmail
                  ? AppLocalizations.of(context)!.emailLabel
                  : AppLocalizations.of(context)!.edit,
            ),
          ),
      ],
    );
  }
}
