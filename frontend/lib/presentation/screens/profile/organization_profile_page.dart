import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:frontend/data/models/user_profile_model.dart';
import 'package:frontend/core/services/organization_user_service.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/presentation/widgets/custom_drawer.dart';
import 'package:frontend/presentation/screens/admin/widgets/delete_confirmation.dart';

/*--------------------- ألوان وثوابت ---------------------*/
const _primaryColor = Color(0xFF326B80);
const _appBarBg     = Color(0xFFE9F1F2);
const _dividerThick = .8;

class OrganizationProfilePage extends StatefulWidget {
  final UserProfileModel profile;   // قد يكون ناقص الحقول الاختيارية
  final bool isOwnProfile;
  final bool isAdmin;

  const OrganizationProfilePage({
    Key? key,
    required this.profile,
    this.isOwnProfile = true,
    this.isAdmin      = false,
  }) : super(key: key);

  @override
  State<OrganizationProfilePage> createState() => _OrganizationProfilePageState();
}

class _OrganizationProfilePageState extends State<OrganizationProfilePage> {
  late UserProfileModel _profile;
  bool _hasChanges = false;
  bool _loading    = true;

  late TextEditingController _nameCtl;
  late TextEditingController _workCtl;
  late TextEditingController _posCtl;
  late TextEditingController _descCtl;
  late TextEditingController _emailCtl;
  late TextEditingController _websiteCtl;

  /* ---------- lifecycle ---------- */
  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _initControllers();
    _loadLatestProfile();                // يجلب القيم الحقيقية من السيرفر
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _workCtl.dispose();
    _posCtl.dispose();
    _descCtl.dispose();
    _emailCtl.dispose();
    _websiteCtl.dispose();
    super.dispose();
  }

  /* ---------- helpers ---------- */
  void _initControllers() {
    _nameCtl    = TextEditingController(text: _profile.name);
    _workCtl    = TextEditingController(text: _profile.workEducation);
    _posCtl     = TextEditingController(text: _profile.position);
    _descCtl    = TextEditingController(text: _profile.description);
    _emailCtl   = TextEditingController(text: _profile.email);
    _websiteCtl = TextEditingController(text: _profile.website);
  }

  Future<void> _loadLatestProfile() async {
    if (!widget.isOwnProfile && !widget.isAdmin) {
      setState(() => _loading = false);
      return;
    }
    try {
      final fresh = await OrganizationUserService
          .fetchUserProfileById(_profile.userId.toString());
      setState(() {
        _profile = fresh;
        _initControllers();
        _loading = false;
      });
    } catch (e) {
      // لو فشل الجلب، اعرض على الأقل القيم الممررة
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    final loc = AppLocalizations.of(context)!;
    try {
      await OrganizationUserService.updateOrganizationUser(
        _profile.userId,
        _profile,
      );
      setState(() => _hasChanges = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loc.saveSuccess)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${loc.saveError}: $e')));
    }
  }

  Future<void> _deleteProfile() async {
    final loc = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteConfirmation(
        message: 'هل تريد حذف هذه المنظمة نهائيًا؟',
      ),
    );
    if (confirm == true) {
      try {
        await OrganizationUserService.deleteOrganizationUser(_profile.userId);
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(loc.deleteSuccess)));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('خطأ في الحذف: $e')));
      }
    }
  }

  /* ---------- UI helpers ---------- */
  void _editDialog({
    required String label,
    required TextEditingController ctl,
    required void Function(String) onSaved,
    bool multiline = false,
    bool isEmail   = false,
  }) {
    final loc = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label, style: const TextStyle(color: _primaryColor)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctl,
            maxLines: multiline ? 3 : 1,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: label,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return '$label ${loc.requiredHint}';
              if (isEmail && !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(v)) {
                return loc.invalidEmail;
              }
              return null;
            },
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
              if (formKey.currentState!.validate()) {
                onSaved(ctl.text.trim());
                setState(() => _hasChanges = true);
                Navigator.pop(context);
              }
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }

  Widget _inlineEditable({
    required Widget child,
    required bool canEdit,
    required VoidCallback onEdit,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: child),
        if (canEdit)
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.edit, size: 18, color: _primaryColor),
            onPressed: onEdit,
          ),
      ],
    );
  }

  /* ---------- build ---------- */
  @override
  Widget build(BuildContext context) {
    final loc     = AppLocalizations.of(context)!;
    final canEdit = widget.isAdmin;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: widget.isOwnProfile ? const CustomDrawer() : null,
      appBar: AppBar(
        backgroundColor: _appBarBg,
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
          loc.organizationProfile.toUpperCase(),
          style: TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: loc.deleteUser,
              onPressed: _deleteProfile,
            ),
        ],
      ),
      floatingActionButton: canEdit && _hasChanges
          ? FloatingActionButton(
        onPressed: _saveProfile,
        backgroundColor: _primaryColor,
        child: const Icon(Icons.save, color: Colors.white),
      )
          : null,
      body: _buildBody(loc, canEdit),
    );
  }

  Widget _buildBody(AppLocalizations loc, bool canEdit) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /** HEADER **/
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40.r,
                  backgroundColor: const Color(0xFFE1ECF4),
                  child: const Icon(Icons.apartment, size: 40, color: _primaryColor),
                ),
                SizedBox(height: 12.h),
                _inlineEditable(
                  canEdit: canEdit,
                  onEdit: () => _editDialog(
                    label: loc.organizationName,
                    ctl : _nameCtl,
                    onSaved: (v) => _profile = _profile.copyWith(name: v),
                  ),
                  child: Text(
                    _profile.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 17.sp,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                _inlineEditable(
                  canEdit: canEdit,
                  onEdit : () => _editDialog(
                    label: loc.organizationDetails,
                    ctl : _workCtl,
                    onSaved: (v) => _profile = _profile.copyWith(workEducation: v),
                  ),
                  child: Text(
                    _profile.workEducation.isEmpty
                        ? loc.organizationDetails
                        : _profile.workEducation,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                  ),
                ),
                if (_profile.position.isNotEmpty)
                  _inlineEditable(
                    canEdit: canEdit,
                    onEdit: () => _editDialog(
                      label: loc.position,
                      ctl : _posCtl,
                      onSaved: (v) => _profile = _profile.copyWith(position: v),
                    ),
                    child: Text(
                      _profile.position,
                      style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          const Divider(thickness: _dividerThick, color: _primaryColor),

          /** DESCRIPTION **/
          SizedBox(height: 16.h),
          Text(loc.description, style: _titleStyle),
          SizedBox(height: 6.h),
          _inlineEditable(
            canEdit: canEdit,
            onEdit : () => _editDialog(
              label: loc.description,
              ctl : _descCtl,
              onSaved: (v) => _profile = _profile.copyWith(description: v),
              multiline: true,
            ),
            child: Text(
              _profile.description.isEmpty
                  ? loc.defaultDescription
                  : _profile.description,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ),
          SizedBox(height: 24.h),
          const Divider(thickness: _dividerThick, color: _primaryColor),

          /** COMMUNITIES **/
          SizedBox(height: 16.h),
          Text(loc.communities, style: _titleStyle),
          SizedBox(height: 8.h),
          if (_profile.communities.isEmpty)
            Text(loc.noCommunitiesJoined,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]))
          else
            Column(
              children: _profile.communities
                  .map((c) => _rowWithIcon(Icons.groups, c))
                  .toList(),
            ),
          SizedBox(height: 24.h),
          const Divider(thickness: _dividerThick, color: _primaryColor),

          /** EMAIL **/
          SizedBox(height: 16.h),
          _inlineEditable(
            canEdit: canEdit,
            onEdit : () => _editDialog(
              label: loc.emailLabel,
              ctl : _emailCtl,
              onSaved: (v) => _profile = _profile.copyWith(email: v),
              isEmail: true,
            ),
            child: _emailText(loc),
          ),

          /** WEBSITE **/
          SizedBox(height: 8.h),
          _inlineEditable(
            canEdit: canEdit,
            onEdit : () => _editDialog(
              label: loc.websiteLabel,
              ctl : _websiteCtl,
              onSaved: (v) => _profile = _profile.copyWith(website: v),
            ),
            child: _websiteText(loc),
          ),

          /** CHANGE PASSWORD (only for owner) **/
          if (widget.isOwnProfile) ...[
            SizedBox(height: 32.h),
            Center(
              child: ElevatedButton(
                onPressed: () => _showChangePasswordDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
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
    );
  }

  /* ---------- small reusable widgets ---------- */
  TextStyle get _titleStyle => TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.bold,
    color: _primaryColor,
  );

  Widget _rowWithIcon(IconData icon, String text) => Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Row(
      children: [
        Icon(icon, size: 18, color: _primaryColor),
        SizedBox(width: 8.w),
        Text(text, style: TextStyle(fontSize: 14.sp)),
      ],
    ),
  );

  Widget _emailText(AppLocalizations loc) => GestureDetector(
    onTap: _profile.email.isEmpty
        ? null
        : () => launchUrl(Uri(scheme: 'mailto', path: _profile.email)),
    child: RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14.sp, color: Colors.black),
        children: [
          TextSpan(
              text: '${loc.contactMeAt} ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text: _profile.email.isEmpty
                ? loc.defaultEmail
                : _profile.email,
            style: const TextStyle(
                color: Colors.blue, decoration: TextDecoration.underline),
          ),
        ],
      ),
    ),
  );

  Widget _websiteText(AppLocalizations loc) => GestureDetector(
    onTap: _profile.website.isEmpty
        ? null
        : () => launchUrl(Uri.parse(_profile.website)),
    child: RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14.sp, color: Colors.black),
        children: [
          TextSpan(
              text: '${loc.websiteLabel} ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text: _profile.website.isEmpty ? loc.unSpecified : _profile.website,
            style: TextStyle(
              color: _profile.website.isEmpty ? Colors.grey : Colors.blue,
              decoration: _profile.website.isEmpty
                  ? null
                  : TextDecoration.underline,
            ),
          ),
        ],
      ),
    ),
  );



/*------------------------ Change Password ------------------------*/
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
                decoration: InputDecoration(labelText: loc.oldPassword, border: const OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? loc.passwordHint : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: newCtl,
                obscureText: true,
                decoration: InputDecoration(labelText: loc.newPassword, border: const OutlineInputBorder()),
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.cancel, style: const TextStyle(color: Colors.red))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await AuthService.changePassword(oldCtl.text.trim(), newCtl.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.passwordChangedSuccess)));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.error}: $e')));
                }
              }
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }
}
