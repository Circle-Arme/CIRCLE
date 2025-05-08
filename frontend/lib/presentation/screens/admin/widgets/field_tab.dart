// lib/presentation/tabs/field_tab.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import 'package:frontend/core/services/field_service.dart';
import 'package:frontend/data/models/area_model.dart';
import 'create_edit_dialog.dart';
import 'delete_confirmation.dart';

class FieldTab extends StatefulWidget {
  const FieldTab({Key? key}) : super(key: key);

  @override
  State<FieldTab> createState() => _FieldTabState();
}

class _FieldTabState extends State<FieldTab> {
  List<AreaModel> _fields = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    setState(() => _loading = true);
    try {
      _fields = await FieldService.fetchFields();
    } catch (e) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.fetchError}: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  /* ───────── إنشاء / تعديل مجال ───────── */
  Future<void> _openCreateOrEdit([AreaModel? field]) async {
    final loc = AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CreateEditDialog<AreaModel>(
        title: field == null ? loc.createField : loc.editField,
        initialData: field ?? AreaModel.empty(),
        formBuilder: (data, onChanged) {
          final titleCtr = TextEditingController(text: data.title);
          final descCtr = TextEditingController(text: data.subtitle);
          String? imagePath = data.image;

          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleCtr,
                    decoration: InputDecoration(labelText: loc.fieldName),
                    validator: (v) =>
                    v!.isEmpty ? loc.enterFieldName : null,
                    onChanged: (v) => onChanged(data.copyWith(title: v)),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: descCtr,
                    decoration: InputDecoration(labelText: loc.description),
                    validator: (v) => v!.isEmpty ? loc.enterDescription : null,
                    onChanged: (v) => onChanged(data.copyWith(subtitle: v)),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setState(() => imagePath = picked.path);
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
        onSubmit: (model) => field == null
            ? FieldService.createField(model.title, model.subtitle, model.image)
            : FieldService.updateField(model.id, model.title, model.subtitle, model.image),
      ),
    );
    if (result == true) _loadFields();
  }

  /* ───────── حذف مجال ───────── */
  Future<void> _confirmDelete(int fieldId) async {
    final loc = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteConfirmation(message: loc.deleteFieldConfirm),
    );
    if (ok == true) {
      try {
        await FieldService.deleteField(fieldId);
        _loadFields();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.deleteError}: $e')),
        );
      }
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
            label: Text(loc.addField,style: const TextStyle(color: Colors.white)),
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
              : _fields.isEmpty
              ? Center(child: Text(loc.noFields))
              : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: _fields.length,
            itemBuilder: (_, i) {
              final f = _fields[i];
              return Card(
                margin:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: ListTile(
                  title: Text(f.title),
                  subtitle: Text(f.subtitle),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _openCreateOrEdit(f),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(f.id),
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
