import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';

import '../../blocs/thread/thread_bloc.dart';
import '../../blocs/thread/thread_event.dart';
import '../../blocs/thread/thread_state.dart';
import '../../theme/app_colors.dart';


class CreateThreadForm extends StatefulWidget {
  final int communityId;
  final String roomType;
  final bool isJobOpportunity;
  final ThreadBloc threadBloc;

  const CreateThreadForm({
    super.key,
    required this.communityId,
    required this.roomType,
    this.isJobOpportunity = false,
    required this.threadBloc,
  });

  @override
  State<CreateThreadForm> createState() => _CreateThreadFormState();
}

class _CreateThreadFormState extends State<CreateThreadForm> {
  /* ─────────── controllers & state ─────────── */
  final _formKey          = GlobalKey<FormState>();
  bool _waitingResponse = false;
  bool   _submitted       = false;

  String _classification  = 'Q&A';
  final  _classificationOptions = ['Q&A', 'General'];

  final _titleController   = TextEditingController();
  final _tagsController    = TextEditingController();
  final _contentController = TextEditingController();
  final _jobLinkController = TextEditingController();

  final _jobTypeOptions = ['Full-time', 'Part-time', 'Remote'];
  String _jobType      = 'Full-time';
  String _jobLinkType  = 'direct';

  PlatformFile? _selectedFile;
  bool _clearFile = false;

  String? location;
  String? salary;

  /* ─────────── dispose ─────────── */
  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _contentController.dispose();
    _jobLinkController.dispose();
    super.dispose();
  }

  /*─────────── clear ─────────── */

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _clearFile = true;                       // flag for the event
    });
  }


  /* ─────────── helpers ─────────── */
  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles();
    if (res != null) {
      setState(() => _selectedFile = res.files.first);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _waitingResponse = true);

    setState(() => _submitted = true);

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    widget.threadBloc.add(CreateThreadEvent(
      widget.communityId,
      widget.roomType,
      _titleController.text.trim(),
      _contentController.text.trim(),
      _classification,
      tags,
      file: _selectedFile,
      isJobOpportunity: widget.isJobOpportunity,
      jobType:  widget.isJobOpportunity ? _jobType                  : null,
      location: widget.isJobOpportunity ? location                  : null,
      salary:   widget.isJobOpportunity ? salary                    : null,
      jobLink:  widget.isJobOpportunity ? _jobLinkController.text.trim() : null,
      jobLinkType: widget.isJobOpportunity ? _jobLinkType           : null,
    ));
  }

  /* ─────────── build ─────────── */
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocListener<ThreadBloc, ThreadState>(
      bloc: widget.threadBloc,

      listenWhen: (_, __) => _waitingResponse,       // استمع فقط أثناء الانتظار
      listener: (context, state) {
        if (state is ThreadLoaded) {
          _waitingResponse = false;                  // أوقف الاستماع
          Navigator.pop(context, true);              // رجوع *مرة واحدة*
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.threadCreatedSuccessfully)),
          );
        } else if (state is ThreadError) {
          _waitingResponse = false;                  // أوقف الاستماع
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${loc.failedToCreateThread}: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },

      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isJobOpportunity
              ? loc.createJobOpportunity
              : loc.createThread),
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

                  /* ───────── التصنيف ───────── */
                  if (!widget.isJobOpportunity)
                    Row(
                      children: [
                        Text(loc.topicClassification,
                            style: TextStyle(fontSize: 16.sp)),
                        SizedBox(width: 10.w),
                        DropdownButton<String>(
                          value: _classification,
                          items: _classificationOptions.map((opt) {
                            return DropdownMenuItem(
                              value: opt,
                              child: Text(
                                opt == 'Q&A'
                                    ? loc.filterQna
                                    : loc.filterGeneral,
                                style: TextStyle(fontSize: 16.sp),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _classification = val!),
                        ),
                      ],
                    ),

                  SizedBox(height: 16.h),

                  /* ───────── العنوان ───────── */
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: loc.topicTitle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                        const BorderSide(color: AppColors.borderColor),
                      ),
                    ),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? loc.enterTopicTitle : null,
                  ),

                  SizedBox(height: 16.h),

                  /* ───────── الوسوم ───────── */
                  TextFormField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      labelText: loc.tagsHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                        const BorderSide(color: AppColors.borderColor),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  /* ───────── المحتوى ───────── */
                  TextFormField(
                    controller: _contentController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: loc.topicContent,
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                        const BorderSide(color: AppColors.borderColor),
                      ),
                    ),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? loc.enterTopicContent : null,
                  ),

                  /* ───────── حقول الوظائف ───────── */
                  if (widget.isJobOpportunity) ...[
                    SizedBox(height: 16.h),
                    DropdownButtonFormField<String>(
                      value: _jobType,
                      decoration: InputDecoration(
                        labelText: loc.jobType,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                          const BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                      items: _jobTypeOptions.map((opt) {
                        return DropdownMenuItem(
                          value: opt,
                          child: Text(opt == 'Full-time'
                              ? loc.fullTime
                              : opt == 'Part-time'
                              ? loc.partTime
                              : loc.remote),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _jobType = val!),
                    ),

                    SizedBox(height: 16.h),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: loc.location,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                          const BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                      onChanged: (v) => location = v,
                    ),

                    SizedBox(height: 16.h),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: loc.salary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                          const BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                      onChanged: (v) => salary = v,
                    ),

                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _jobLinkController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: loc.jobLink,
                        hintText: 'https://example.com/job/123',
                        prefixIcon: const Icon(Icons.link),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                          const BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                      validator: (v) {
                        if (!widget.isJobOpportunity) return null;
                        if (v == null || v.trim().isEmpty) {
                          return loc.enterJobLink;
                        }
                        final p =
                        RegExp(r'^(https?:\/\/)([-\w]+\.)+[\w]{2,}(/[-\w@:%_\+.~#?&//=]*)?$');
                        return p.hasMatch(v.trim()) ? null : loc.invalidJobLink;
                      },
                    ),

                    SizedBox(height: 16.h),
                    DropdownButtonFormField<String>(
                      value: _jobLinkType,
                      decoration: InputDecoration(
                        labelText: loc.jobLinkType,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                          const BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'direct',
                          child: Text(loc.directApplyLink),
                        ),
                        DropdownMenuItem(
                          value: 'external',
                          child: Text(loc.externalJobPage),
                        ),
                      ],
                      onChanged: (v) => setState(() => _jobLinkType = v!),
                    ),
                  ],

                  /* ───────── attachment ───────── */
                  SizedBox(height: 16.h),
                  if (_selectedFile == null && !_clearFile)
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file, color: Colors.white),
                      label: Text(loc.attachFile, style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    )
                  else
                    ListTile(
                      leading: const Icon(Icons.insert_drive_file, color: AppColors.primaryColor),
                      title: Text(_selectedFile?.name ?? loc.previousAttachment),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: _removeFile,
                      ),
                    ),

                  /* ───────── زر الإنشاء ───────── */
                  SizedBox(height: 24.h),
                  BlocBuilder<ThreadBloc, ThreadState>(
                    bloc: widget.threadBloc,
                    builder: (context, state) {
                      if (state is ThreadLoading) {
                        return const CircularProgressIndicator();
                      }
                      return ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40.w, vertical: 12.h),
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        child: Text(
                          loc.createTopic,
                          style:
                          TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                      );
                    },
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
