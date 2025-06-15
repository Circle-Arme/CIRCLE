import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:frontend/core/services/organization_user_service.dart';
import 'package:frontend/data/models/user_profile_model.dart';
 // تأكد من المسار الصحيح

import '../../../blocs/organization/organization_bloc.dart';
import '../../../blocs/organization/organization_event.dart';
import '../../../blocs/organization/organization_state.dart';
import '../../../widgets/search_bar_widget.dart';
import 'create_edit_dialog.dart';
import 'delete_confirmation.dart';

class OrganizationTab extends StatelessWidget {
  const OrganizationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrganizationBloc()..add(FetchOrganizations()),
      child: const _OrganizationTabContent(),
    );
  }
}

class _OrganizationTabContent extends StatefulWidget {
  const _OrganizationTabContent();

  @override
  State<_OrganizationTabContent> createState() => _OrganizationTabContentState();
}

class _OrganizationTabContentState extends State<_OrganizationTabContent> {
  String _searchQuery = '';

  Future<void> _showCreateOrgDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    const primaryColor = Color(0xFF326B80);

    final formKey = GlobalKey<FormState>();
    final nameCtr = TextEditingController();
    final emailCtr = TextEditingController();
    final passCtr = TextEditingController();
    final workCtr = TextEditingController();
    final posCtr = TextEditingController();
    final descCtr = TextEditingController();
    final webCtr = TextEditingController();

    await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(loc.createOrg),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtr,
                  decoration: InputDecoration(labelText: loc.orgName),
                  validator: (v) => v!.trim().isEmpty ? loc.nameRequired : null,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: emailCtr,
                  decoration: InputDecoration(labelText: loc.email),
                  validator: (v) =>
                  (v != null && v.contains('@')) ? null : loc.invalidEmail,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: passCtr,
                  obscureText: true,
                  decoration: InputDecoration(labelText: loc.password),
                  validator: (v) => (v != null && v.length >= 6)
                      ? null
                      : loc.passwordShort,
                ),
                SizedBox(height: 20.h),
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
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor, // لون النص إلى 0xFF326B80
              side: const BorderSide(color: primaryColor), // لون الحدود إلى 0xFF326B80
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            ),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              );
              if (!formKey.currentState!.validate()) return;
              final profile = UserProfileModel.empty().copyWith(
                name: nameCtr.text.trim(),
                email: emailCtr.text.trim(),
                userType: 'organization',
                workEducation: workCtr.text.trim(),
                position: posCtr.text.trim(),
                description: descCtr.text.trim(),
                website: webCtr.text.trim(),
              );
              context.read<OrganizationBloc>().add(
                CreateOrganization(profile, passCtr.text.trim()),
              );
              Navigator.pop(context, true);
            },
            child: Text(loc.create,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditOrgDialog(BuildContext context, UserProfileModel user) async {
    final loc = AppLocalizations.of(context)!;

    await showDialog<bool>(
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
        onSubmit: (model) async =>
            context.read<OrganizationBloc>().add(UpdateOrganization(model.id, model)),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int userId) async {
    final loc = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmation(message: loc.deleteOrgConfirm),
    );
    if (ok == true) {
      context.read<OrganizationBloc>().add(DeleteOrganization(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizationBloc, OrganizationState>(
      listener: (context, state) {
        if (state is OrganizationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)!.fetchError}: ${state.error}')),
          );
        }
      },
      builder: (context, state) {
        final loc = AppLocalizations.of(context)!;
        List<UserProfileModel> organizations = [];

        if (state is OrganizationLoaded) {
          organizations = state.organizations;
        }

        final filtered = organizations.where((u) =>
        u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            u.email.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

        return Stack(
          children: [
            Column(
              children: [
                SearchBarWidget(
                  hintText: loc.searchOrg,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                Expanded(
                  child: state is OrganizationLoading
                      ? const Center(child: CircularProgressIndicator())
                      : organizations.isEmpty
                      ? Center(child: Text(loc.noOrgs))
                      : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final u = filtered[i];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: ListTile(
                          title: Text(u.name),
                          subtitle: Text(u.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF326B80)),
                                onPressed: () => _showEditOrgDialog(context, u),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(context, u.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: FloatingActionButton.extended(
                  onPressed: () => _showCreateOrgDialog(context),
                  icon: const Icon(Icons.add, color: Color(0xFF326B80)),
                  label: Text(
                    loc.addOrg,
                    style: const TextStyle(color: Color(0xFF326B80)),
                  ),
                  backgroundColor: const Color(0xFFF5F9F9),
                  foregroundColor: const Color(0xFF326B80),
                  shape: const StadiumBorder(
                    side: BorderSide(color: Color(0xFF326B80)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}