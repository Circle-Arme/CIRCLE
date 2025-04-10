import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/presentation/blocs/thread/thread_bloc.dart';
import 'package:frontend/presentation/blocs/thread/thread_event.dart';
import '../../theme/app_colors.dart';

class CreateThreadForm extends StatefulWidget {
  final int communityId;
  final bool isJobOpportunity;

  const CreateThreadForm({
    Key? key,
    required this.communityId,
    this.isJobOpportunity = false,
  }) : super(key: key);

  @override
  State<CreateThreadForm> createState() => _CreateThreadFormState();
}

class _CreateThreadFormState extends State<CreateThreadForm> {
  final _formKey = GlobalKey<FormState>();
  String _classification = 'Q&A';
  final List<String> _classificationOptions = ['Q&A', 'General'];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final List<String> tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      context.read<ThreadBloc>().add(
        CreateThreadEvent(
          widget.communityId,
          _titleController.text.trim(),
          _contentController.text.trim(),
          _classification,
          tags,
          isJobOpportunity: widget.isJobOpportunity,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => ThreadBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isJobOpportunity ? loc.createJobOpportunity : loc.createThread),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: AppColors.primaryColor),
          titleTextStyle: const TextStyle(
            color: AppColors.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        loc.topicClassification,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(width: 10.w),
                      DropdownButton<String>(
                        value: _classification,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _classification = val;
                            });
                          }
                        },
                        items: _classificationOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(
                              option == 'Q&A' ? loc.filterQna : loc.filterGeneral,
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: loc.topicTitle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return loc.enterTopicTitle;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      labelText: loc.tagsHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: loc.topicContent,
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    maxLines: 6,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return loc.enterTopicContent;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: Text(
                      loc.createTopic,
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
