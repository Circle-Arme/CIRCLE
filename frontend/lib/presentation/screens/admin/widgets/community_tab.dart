import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';


import 'package:frontend/core/services/field_service.dart';
import 'package:frontend/data/models/area_model.dart';
import 'package:frontend/data/models/community_model.dart';
import 'package:frontend/presentation/widgets/search_bar_widget.dart';
import 'package:mime/mime.dart';

import '../../../../core/services/CommunityService.dart';
import '../../../blocs/community/community_bloc.dart';
import '../../../blocs/community/community_event.dart';
import '../../../blocs/community/community_state.dart';
import '../../../blocs/field/field_bloc.dart';
import '../../../blocs/field/field_event.dart';
import 'create_edit_dialog.dart';
import 'delete_confirmation.dart';


class CommunityTab extends StatelessWidget {
  static bool needRefresh = false;
  const CommunityTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FieldBloc(FieldService())..add(FetchFields()),
        ),
        BlocProvider(
          create: (context) => CommunityBloc(CommunityService())..add(FetchCommunities()),
        ),
      ],
      child: const _CommunityTabContent(),
    );
  }
}

class _CommunityTabContent extends StatefulWidget {
  const _CommunityTabContent();

  @override
  State<_CommunityTabContent> createState() => _CommunityTabContentState();
}

class _CommunityTabContentState extends State<_CommunityTabContent> {
  String _searchQuery = '';

  Future<String?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      if (!await file.exists()) {
        throw Exception('الملف غير موجود');
      }
      final size = await file.length();
      if (size > 5 * 1024 * 1024) {
        throw Exception('حجم الصورة كبير جدًا');
      }
      final mime = lookupMimeType(pickedFile.path);
      if (mime != 'image/jpeg' && mime != 'image/png') {
        throw Exception('تنسيق الصورة غير مدعوم');
      }
      return pickedFile.path;
    }
    return null;
  }

  Future<void> _openCreateOrEdit(BuildContext context, [CommunityModel? community]) async {
    final loc = AppLocalizations.of(context)!;
    const primaryColor = Color(0xFF326B80); // لون التطبيق الأساسي

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CreateEditDialog<CommunityModel>(
        title: community == null ? loc.createCommunity : loc.editCommunity,
        initialData: community ?? CommunityModel.empty(),
        formBuilder: (data, onChanged) {
          final fields = context.read<FieldBloc>().state.fields;
          final selectedField = fields.firstWhere(
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
                    decoration: InputDecoration(
                      labelText: loc.field,
                      labelStyle: const TextStyle(color: primaryColor),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    items: fields
                        .map((f) => DropdownMenuItem<AreaModel>(
                      value: f,
                      child: Text(f.title, style: const TextStyle(color: primaryColor)),
                    ))
                        .toList(),
                    onChanged: (f) {
                      if (f != null) {
                        onChanged(data.copyWith(areaId: f.id.toString()));
                      }
                    },
                    validator: (v) => v == null ? loc.selectField : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    initialValue: data.name,
                    decoration: InputDecoration(
                      labelText: loc.communityName,
                      labelStyle: const TextStyle(color: primaryColor),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    style: const TextStyle(color: primaryColor),
                    validator: (v) => v!.isEmpty ? loc.enterCommunityName : null,
                    onChanged: (v) => onChanged(data.copyWith(name: v)),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () async {
                      imagePath = await pickImage();
                      if (imagePath != null) {
                        setState(() => imagePath = imagePath);
                        onChanged(data.copyWith(image: imagePath));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(loc.chooseImage),
                  ),
                  if (imagePath != null) ...[
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Image.file(
                        File(imagePath!),
                        height: 100.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
        onSubmit: (model) {
          final fid = int.tryParse(model.areaId);
          if (fid == null || fid == 0) {
            throw Exception('يرجى اختيار مجال صالح');
          }
          if (community == null) {
            context.read<CommunityBloc>().add(CreateCommunity(fid, model.name, model.image));
          } else {
            context.read<CommunityBloc>().add(UpdateCommunity(model.id, fid, model.name, model.image));
          }
          return Future.value();
        },
      ),
    );
    if (result == true) {
      CommunityTab.needRefresh = false;
    }
  }

  Future<void> _confirmDelete(BuildContext context, int communityId) async {
    final loc = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmation(message: loc.deleteCommunityConfirm),
    );
    if (ok == true) {
      context.read<CommunityBloc>().add(DeleteCommunity(communityId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocConsumer<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${loc.fetchError}: ${state.error}')),
          );
        }
      },
      builder: (context, state) {
        final fields = context.read<FieldBloc>().state.fields;
        final filtered = state.communities.where((c) {
          final nameMatch = c.name.toLowerCase().contains(_searchQuery.toLowerCase());
          final fieldName = fields.firstWhere(
                (f) => f.id.toString() == c.areaId,
            orElse: () => AreaModel.empty(),
          ).title.toLowerCase();
          final fieldMatch = fieldName.contains(_searchQuery.toLowerCase());
          return nameMatch || fieldMatch;
        }).toList();

        return Stack(
          children: [
            Column(
              children: [
                SearchBarWidget(
                  hintText: loc.searchCommunity,
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.communities.isEmpty
                      ? Center(child: Text(loc.noCommunities))
                      : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final c = filtered[i];
                      final fieldName = fields.firstWhere(
                            (f) => f.id.toString() == c.areaId,
                        orElse: () => AreaModel.empty(),
                      ).title;

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        child: ListTile(
                          leading: c.image != null
                              ? Image.network(
                            c.image!,
                            width: 50.w,
                            height: 50.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error),
                          )
                              : const Icon(Icons.group),
                          title: Text(c.name),
                          subtitle: Text('${loc.field}: $fieldName'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF326B80)),
                                onPressed: () => _openCreateOrEdit(context, c),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(context, c.id),
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
                  onPressed: () => _openCreateOrEdit(context),
                  icon: const Icon(Icons.add, color: Color(0xFF326B80)),
                  label: Text(
                    loc.addCommunity,
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