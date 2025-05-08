// lib/presentation/tabs/community_tab.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import 'package:frontend/core/services/field_service.dart';
import 'package:frontend/core/services/CommunityService.dart';
import 'package:frontend/data/models/area_model.dart';
import 'package:frontend/data/models/community_model.dart';

import 'create_edit_dialog.dart';
import 'delete_confirmation.dart';

class CommunityTab extends StatefulWidget {
  const CommunityTab({Key? key}) : super(key: key);

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  List<AreaModel> _fields = [];
  List<CommunityModel> _communities = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final fields = await FieldService.fetchFields();
      final communities = await CommunityService.fetchAdminCommunities();
      setState(() {
        _fields = fields;
        _communities = communities;
      });
    } catch (e) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.fetchError}: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  /* ───────────────────── إنشاء / تعديل ───────────────────── */
  Future<void> _openCreateOrEdit([CommunityModel? community]) async {
    final loc = AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CreateEditDialog<CommunityModel>(
        title: community == null ?  loc.createCommunity : loc.editCommunity,
        initialData: community ?? CommunityModel.empty(),
        formBuilder: (data, onChanged) {
          final AreaModel selectedField = _fields.firstWhere(
                (f) => f.id.toString() == data.areaId,
            orElse: () => AreaModel.empty(),
          );
          String? imagePath = data.image;

          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<AreaModel>(
                    value: selectedField.id == 0 ? null : selectedField,
                    decoration: InputDecoration(labelText: loc.field),
                    items: _fields
                        .map((f) => DropdownMenuItem<AreaModel>(
                      value: f,
                      child: Text(f.title),
                    ))
                        .toList(),
                    onChanged: (f) =>
                        onChanged(data.copyWith(areaId: f!.id.toString())),
                    validator: (v) => v == null ? loc.selectField : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    initialValue: data.name,
                    decoration:
                    InputDecoration(labelText: loc.communityName),
                    validator: (v) =>
                    v!.isEmpty ? loc.enterCommunityName : null,
                    onChanged: (v) => onChanged(data.copyWith(name: v)),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() => imagePath = pickedFile.path);
                        onChanged(data.copyWith(image: imagePath));
                      }
                    },
                    child: Text(loc.chooseImage),
                  ),
                  if (imagePath != null) ...[
                    SizedBox(height: 8.h),
                    Image.file(File(imagePath!), height: 100.h, fit: BoxFit.cover),
                  ],
                ],
              );
            },
          );
        },
        onSubmit: (model) {
          final fid = int.tryParse(model.areaId) ?? 0;
          return community == null
              ? CommunityService.createCommunity(fid, model.name, model.image)
              : CommunityService.updateCommunity(
              model.id, fid, model.name, model.image);
        },
      ),
    );

    if (result == true) _loadData();
  }

  /* ───────────────────── حذف مجتمع ───────────────────── */
  Future<void> _confirmDelete(int communityId) async {
    final loc = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmation(message: loc.deleteCommunityConfirm),
    );
    if (ok == true) {
      try {
        await CommunityService.deleteCommunity(communityId);
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.deleteError}: $e')),
        );
      }
    }
  }

  /* ───────────────────── Widget الرئيسي ───────────────────── */
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add,color: Colors.white),
            label: Text(loc.addCommunity,style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF326B80),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            onPressed: () => _openCreateOrEdit(),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _communities.isEmpty
              ? Center(child: Text(loc.noCommunities))
              : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: _communities.length,
            itemBuilder: (_, i) {
              final c = _communities[i];
              final fieldName = _fields
                  .firstWhere(
                    (f) => f.id.toString() == c.areaId,
                orElse: () => AreaModel.empty(),
              )
                  .title;

              return Card(
                margin: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 4.h),
                child: ListTile(
                  title: Text(c.name),
                  subtitle: Text('${loc.field}: $fieldName'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _openCreateOrEdit(c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(c.id),
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
