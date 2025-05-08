// lib/widgets/delete_confirmation.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeleteConfirmation extends StatelessWidget {
  final String? message;
  const DeleteConfirmation({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(
        loc.confirmTitle,
        style:
        Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Text(message ?? loc.genericDeleteConfirm),
      actionsPadding:
      EdgeInsets.only(left: 16.w, right: 16.w, bottom: 10.h, top: 4.h),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            side: BorderSide(color: Colors.grey.shade400),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          ),
          child: Text(loc.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          ),
          child: Text(loc.delete),
        ),
      ],
    );
  }
}
