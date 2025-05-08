// lib/widgets/create_edit_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef OnSubmit<T> = Future<void> Function(T data);

class CreateEditDialog<T> extends StatefulWidget {
  final String title;
  final T initialData;
  final Widget Function(T data, void Function(T updated)) formBuilder;
  final OnSubmit<T> onSubmit;

  const CreateEditDialog({
    super.key,
    required this.title,
    required this.initialData,
    required this.formBuilder,
    required this.onSubmit,
  });

  @override
  State<CreateEditDialog<T>> createState() => _CreateEditDialogState<T>();
}

class _CreateEditDialogState<T> extends State<CreateEditDialog<T>> {
  late T _currentData;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _currentData = widget.initialData;
  }

  void _onFieldChanged(T updated) => _currentData = updated;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await widget.onSubmit(_currentData);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.errorPrefix}: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      titlePadding: EdgeInsets.only(top: 24.h, bottom: 8.h),
      title: Center(
        child: Text(
          widget.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      contentPadding:
      EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: widget.formBuilder(_currentData, _onFieldChanged),
        ),
      ),
      actionsPadding:
      EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h, top: 8.h),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        OutlinedButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            side: BorderSide(color: Colors.grey.shade400),
            padding:
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          ),
          child: Text(loc.cancel),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            padding:
            EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          child: _loading
              ? SizedBox(
            width: 20.w,
            height: 20.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(loc.save),
        ),
      ],
    );
  }
}
