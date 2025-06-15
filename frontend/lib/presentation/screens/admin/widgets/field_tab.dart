import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';


import 'package:frontend/core/services/field_service.dart';
import 'package:frontend/data/models/area_model.dart';
import 'package:frontend/presentation/widgets/search_bar_widget.dart';
import 'package:mime/mime.dart';

import '../../../blocs/field/field_bloc.dart';
import '../../../blocs/field/field_event.dart';
import '../../../blocs/field/field_state.dart';
import 'community_tab.dart';
import 'create_edit_dialog.dart';
import 'delete_confirmation.dart';



class FieldTab extends StatelessWidget {
  const FieldTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FieldBloc(FieldService())..add(FetchFields()),
      child: const _FieldTabContent(),
    );
  }
}

class _FieldTabContent extends StatefulWidget {
  const _FieldTabContent();

  @override
  State<_FieldTabContent> createState() => _FieldTabContentState();
}

class _FieldTabContentState extends State<_FieldTabContent> {
  String _searchQuery = '';

  Future<String?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }
      final size = await file.length();
      if (size > 5 * 1024 * 1024) {
        throw Exception('Image size is too large');
      }
      final mime = lookupMimeType(pickedFile.path);
      if (mime != 'image/jpeg' && mime != 'image/png') {
        throw Exception('Unsupported image format');
      }
      return pickedFile.path;
    }
    return null;
  }

  Future<void> _openCreateOrEdit(BuildContext context, [AreaModel? field]) async {
    final loc = AppLocalizations.of(context)!;
    const primaryColor = Color(0xFF326B80);

    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        String? imagePath = field?.image;
        bool removeOld = false; // NEW: Flag to track image removal
        final titleController = TextEditingController(text: field?.title ?? '');
        final descController = TextEditingController(text: field?.subtitle ?? '');

        return CreateEditDialog<AreaModel>(
          title: field == null ? loc.createField : loc.editField,
          initialData: field ?? AreaModel.empty(),
          formBuilder: (data, onChanged) {
            return StatefulBuilder(
              builder: (context, setState) {
                Future<void> _choose() async {
                  final path = await pickImage();
                  if (path != null) {
                    setState(() {
                      imagePath = path;
                      removeOld = false; // Reset removal flag
                    });
                    onChanged(data.copyWith(image: path));
                    print('Image updated: $imagePath');
                  }
                }

                void _clear() {
                  setState(() {
                    imagePath = null;
                    removeOld = true; // Set flag to clear image
                  });
                  onChanged(data.copyWith(image: null));
                  print('Image cleared');
                }

                return Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: loc.fieldName,
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
                        validator: (v) => v == null || v.isEmpty ? loc.enterFieldName : null,
                        onChanged: (v) {
                          onChanged(data.copyWith(title: v.trim()));
                          print('Title updated: ${titleController.text}');
                        },
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: descController,
                        decoration: InputDecoration(
                          labelText: loc.description,
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
                        validator: (v) => v == null || v.isEmpty ? loc.enterDescription : null,
                        onChanged: (v) {
                          onChanged(data.copyWith(subtitle: v.trim()));
                          print('Description updated: ${descController.text}');
                        },
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _choose,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: Text(loc.chooseImage),
                          ),
                          const SizedBox(width: 12),
                          if (imagePath != null && imagePath!.isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: _clear,
                              icon: const Icon(Icons.clear, size: 18, color: Colors.red),
                              label: Text(loc.clear),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                      if (imagePath != null && imagePath!.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: primaryColor),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Image(
                            image: imagePath!.startsWith('http')
                                ? NetworkImage(imagePath!) as ImageProvider
                                : FileImage(File(imagePath!)),
                            height: 100.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
          onSubmit: (model) {
            final updatedTitle = titleController.text.trim();
            final updatedDesc = descController.text.trim();
            final updatedImage = (imagePath == null || imagePath!.trim().isEmpty) ? null : imagePath;

            print('Submitting: title=$updatedTitle, subtitle=$updatedDesc, image=$updatedImage, clearImage=$removeOld');
            if (updatedTitle.isEmpty || updatedDesc.isEmpty) {
              throw Exception(loc.enterFieldName);
            }
            if (field == null) {
              context.read<FieldBloc>().add(CreateField(updatedTitle, updatedDesc, updatedImage));
            } else {
              context.read<FieldBloc>().add(UpdateField(
                model.id,
                updatedTitle,
                updatedDesc,
                updatedImage,
                clearImage: removeOld, // NEW: Pass the clearImage flag
              ));
            }
            return Future.value();
          },
        );
      },
    );

    if (result == true) {
      CommunityTab.needRefresh = true;
    }
  }

  Future<void> _confirmDelete(BuildContext context, int fieldId) async {
    final loc = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmation(message: loc.deleteFieldConfirm),
    );
    if (ok == true) {
      context.read<FieldBloc>().add(DeleteField(fieldId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocConsumer<FieldBloc, FieldState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${loc.fetchError}: ${state.error}')),
          );
        }
      },
      builder: (context, state) {
        final filtered = state.fields.where((f) =>
        f.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            f.subtitle.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

        return Stack(
          children: [
            Column(
              children: [
                SearchBarWidget(
                  hintText: loc.searchField,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.fields.isEmpty
                      ? Center(child: Text(loc.noFields))
                      : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final f = filtered[i];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        child: ListTile(
                          title: Text(f.title),
                          subtitle: Text(f.subtitle),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF326B80)),
                                onPressed: () => _openCreateOrEdit(context, f),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(context, f.id),
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
                    loc.addField,
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