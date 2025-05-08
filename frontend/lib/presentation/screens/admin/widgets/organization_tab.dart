// lib/presentation/admin_dashboard/widgets/organization_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:frontend/core/services/organization_user_service.dart';
import 'package:frontend/data/models/user_profile_model.dart';

import 'create_edit_dialog.dart';
import 'delete_confirmation.dart';

class OrganizationTab extends StatefulWidget {
  const OrganizationTab({Key? key}) : super(key: key);

  @override
  State<OrganizationTab> createState() => _OrganizationTabState();
}

class _OrganizationTabState extends State<OrganizationTab> {
  List<UserProfileModel> _orgUsers = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadOrgUsers();
  }

  Future<void> _loadOrgUsers() async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      _orgUsers = await OrganizationUserService.fetchOrganizationUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.fetchError}: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  /* ───────── إنشاء منظمة ───────── */
  Future<void> _showCreateOrgDialog() async {
    final loc = AppLocalizations.of(context)!;

    final formKey = GlobalKey<FormState>();
    final nameCtr = TextEditingController();
    final emailCtr = TextEditingController();
    final passCtr = TextEditingController();
    final workCtr = TextEditingController();
    final posCtr = TextEditingController();
    final descCtr = TextEditingController();
    final webCtr = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        //style: TextStyle(color: Colors.white, fontSize: 18.sp),
        //style: const TextStyle(
        //                 color: AppColors.primaryColor,
        //                 fontSize: 20,
        title: Text(loc.createOrg),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /*** مطلوب: الاسم ***/
                TextFormField(
                  controller: nameCtr,
                  decoration: InputDecoration(labelText: loc.orgName),
                  validator: (v) => v!.trim().isEmpty ? loc.nameRequired : null,
                ),
                SizedBox(height: 12.h),

                /*** مطلوب: البريد ***/
                TextFormField(
                  controller: emailCtr,
                  decoration: InputDecoration(labelText: loc.email),
                  validator: (v) =>
                  (v != null && v.contains('@')) ? null : loc.invalidEmail,
                ),
                SizedBox(height: 12.h),

                /*** مطلوب: كلمة المرور ***/
                TextFormField(
                  controller: passCtr,
                  obscureText: true,
                  decoration: InputDecoration(labelText: loc.password),
                  validator: (v) => (v != null && v.length >= 6)
                      ? null
                      : loc.passwordShort,
                ),
                SizedBox(height: 20.h),

                /*** اختياريّات ***/
                TextFormField(
                  controller: workCtr,
                  decoration: InputDecoration(labelText: loc.workEducationOpt),
                ),
                SizedBox(height: 12.h),

                TextFormField(
                  controller: posCtr,
                  decoration: InputDecoration(labelText: loc.positionOpt),
                ),
                SizedBox(height: 12.h),

                TextFormField(
                  controller: descCtr,
                  decoration: InputDecoration(labelText: loc.descriptionOpt),
                  maxLines: 2,
                ),
                SizedBox(height: 12.h),

                TextFormField(
                  controller: webCtr,
                  decoration: InputDecoration(labelText: loc.websiteOpt),
                ),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                final profile = UserProfileModel.empty().copyWith(
                  name: nameCtr.text.trim(),
                  email: emailCtr.text.trim(),
                  userType: 'organization',
                  workEducation: workCtr.text.trim(),
                  position: posCtr.text.trim(),
                  description: descCtr.text.trim(),
                  website: webCtr.text.trim(),
                );
                await OrganizationUserService.createOrganizationUser(
                    profile, passCtr.text.trim());
                Navigator.pop(context, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${loc.createOrgFail}: $e')),
                );
              }
            },
            child: Text(loc.create),
          ),
        ],
      ),
    );

    if (created == true) _loadOrgUsers();
  }

  /* ───────── تعديل منظمة ───────── */
  Future<void> _showEditOrgDialog(UserProfileModel user) async {
    final loc = AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CreateEditDialog<UserProfileModel>(
        title: loc.editOrg,
        initialData: user,
        formBuilder: (data, onChanged) {
          final nameCtr = TextEditingController(text: data.name);
          final emailCtr = TextEditingController(text: data.email);
          final workCtr = TextEditingController(text: data.workEducation);
          final posCtr = TextEditingController(text: data.position);
          final descCtr = TextEditingController(text: data.description);
          final webCtr = TextEditingController(text: data.website);

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtr,
                  decoration: InputDecoration(labelText: loc.orgName),
                  validator: (v) => v!.trim().isEmpty ? loc.nameRequired : null,
                  onChanged: (v) => onChanged(data.copyWith(name: v)),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: emailCtr,
                  decoration: InputDecoration(labelText: loc.email),
                  validator: (v) =>
                  (v != null && v.contains('@')) ? null : loc.invalidEmail,
                  onChanged: (v) => onChanged(data.copyWith(email: v)),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: workCtr,
                  decoration: InputDecoration(labelText: loc.workEducation),
                  onChanged: (v) => onChanged(data.copyWith(workEducation: v)),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: posCtr,
                  decoration: InputDecoration(labelText: loc.position),
                  onChanged: (v) => onChanged(data.copyWith(position: v)),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: descCtr,
                  decoration: InputDecoration(labelText: loc.description),
                  maxLines: 2,
                  onChanged: (v) => onChanged(data.copyWith(description: v)),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: webCtr,
                  decoration: InputDecoration(labelText: loc.website),
                  onChanged: (v) => onChanged(data.copyWith(website: v)),
                ),
              ],
            ),
          );
        },
        onSubmit: (model) =>
            OrganizationUserService.updateOrganizationUser(model.id, model),
      ),
    );

    if (result == true) _loadOrgUsers();
  }

  /* ───────── حذف منظمة ───────── */
  Future<void> _confirmDelete(int userId) async {
    final loc = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmation(message: loc.deleteOrgConfirm),
    );
    if (ok == true) {
      await OrganizationUserService.deleteOrganizationUser(userId);
      _loadOrgUsers();
    }
  }

  /* ───────── واجهة التبويب ───────── */
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add,color: Colors.white),
            label: Text(loc.addOrg,style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF326B80),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            onPressed: _showCreateOrgDialog,
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _orgUsers.isEmpty
              ? Center(child: Text(loc.noOrgs))
              : ListView.builder(
            itemCount: _orgUsers.length,
            itemBuilder: (_, i) {
              final u = _orgUsers[i];
              return Card(
                margin: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 8.h),
                child: ListTile(
                  title: Text(u.name),
                  subtitle: Text(u.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.blue),
                        onPressed: () => _showEditOrgDialog(u),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () => _confirmDelete(u.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
