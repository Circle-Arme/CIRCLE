// lib/presentation/screens/thread/edit_thread_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';

//import 'create_thread_form.dart';        // للاستفادة من بعض الويدجتس المشتركة
import '../../../data/models/thread_model.dart';
import '../../blocs/thread/thread_bloc.dart';
import '../../blocs/thread/thread_event.dart';
import '../../blocs/thread/thread_state.dart';
import '../../theme/app_colors.dart';

class EditThreadForm extends StatefulWidget {
  final ThreadModel thread;
  final int communityId;
  final String roomType;
  final bool isJobOpportunity;
  final ThreadBloc threadBloc;


  const EditThreadForm({
    super.key,
    required this.thread,
    required this.communityId,
    required this.roomType,
    required this.threadBloc,
    this.isJobOpportunity = false,
  });

  @override
  State<EditThreadForm> createState() => _EditThreadFormState();
}

class _EditThreadFormState extends State<EditThreadForm> {
  final _formKey = GlobalKey<FormState>();
  bool _waitingResponse = false;                        // ★ جديد
  late TextEditingController _titleController;
  late TextEditingController _tagsController;
  late TextEditingController _contentController;
  late TextEditingController _jobTypeController;
  late TextEditingController _locationController;
  late TextEditingController _salaryController;
  late TextEditingController _jobLinkController;
  String _classification = 'Q&A';
  String _jobLinkType = 'direct';
  PlatformFile? _selectedFile;
  bool _clearExistingFile = false;

  String? jobType;
  String? location;
  String? salary;

  @override
  void initState() {
    super.initState();
    // مليء الحقول الحالية:
    _titleController   = TextEditingController(text: widget.thread.title);
    _tagsController    = TextEditingController(text: widget.thread.tags.join(', '));
    _contentController = TextEditingController(text: widget.thread.details);
    _jobTypeController  = TextEditingController(text: widget.thread.jobType);
    _locationController = TextEditingController(text: widget.thread.location);
    _salaryController   = TextEditingController(text: widget.thread.salary);
    _jobLinkController = TextEditingController(text: widget.thread.jobLink ?? '');
    _classification    = widget.thread.classification;
    _jobLinkType       = widget.thread.jobLinkType ?? 'direct';
    jobType            = widget.thread.jobType;
    location           = widget.thread.location;
    salary             = widget.thread.salary;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _contentController.dispose();
    _jobLinkController.dispose();
    _jobTypeController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _clearExistingFile = true;
    });
  }


  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _waitingResponse = true);            // ★
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      widget.threadBloc.add(
        UpdateThreadEvent(
          threadId:         int.parse(widget.thread.id),
          communityId:      widget.communityId,
          roomType:         widget.roomType,
          title:            _titleController.text.trim(),
          content:          _contentController.text.trim(),
          classification:   _classification,
          tags:             tags,
          file:             _selectedFile,
          isJobOpportunity: widget.isJobOpportunity,
          jobType:          widget.isJobOpportunity ? jobType : null,
          location:         widget.isJobOpportunity ? location : null,
          salary:           widget.isJobOpportunity ? salary : null,
          jobLink:          widget.isJobOpportunity ? _jobLinkController.text.trim() : null,
          jobLinkType:      widget.isJobOpportunity ? _jobLinkType : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return BlocListener<ThreadBloc, ThreadState>(
      bloc: widget.threadBloc,
      listenWhen: (_, __) => _waitingResponse,          // ★ استمع فقط أثناء الانتظار
      listener: (context, state) {
        if (state is ThreadLoaded) {
          setState(() => _waitingResponse = false);
          _waitingResponse = false;                     // أوقف الاستماع
          if (mounted) Navigator.pop(context);          // رجوع واحد
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.threadUpdatedSuccessfully)),
          );
        } else if (state is ThreadError) {
          setState(() => _waitingResponse = false);
          _waitingResponse = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${loc.failedToUpdateThread}: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.editTopic),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: AppColors.primaryColor),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // صنف الموضوع
                  if (!widget.isJobOpportunity)
                    Row(
                      children: [
                        Text(loc.topicClassification),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _classification,
                          onChanged: (v) => setState(() => _classification = v!),
                          items: ['Q&A','General']
                              .map((opt) => DropdownMenuItem(
                            value: opt,
                            child: Text(opt == 'Q&A' ? loc.filterQna : loc.filterGeneral),
                          ))
                              .toList(),
                        ),
                      ],
                    ),

                  SizedBox(height: 16.h),

                  // العنوان
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: loc.topicTitle),
                    validator: (v) => v!.trim().isEmpty ? loc.enterTopicTitle : null,
                  ),

                  SizedBox(height: 16.h),

                  // الوسوم
                  TextFormField(
                    controller: _tagsController,
                    decoration: InputDecoration(labelText: loc.tagsHint),
                  ),

                  SizedBox(height: 16.h),

                  // المحتوى
                  TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(labelText: loc.topicContent),
                    maxLines: 6,
                    validator: (v) => v!.trim().isEmpty ? loc.enterTopicContent : null,
                  ),

                  SizedBox(height: 16.h),
                  // حقول الوظيفة إن وجدت
                  if (widget.isJobOpportunity) ...[
                    SizedBox(height: 16.h),
                    // نوع الوظيفة
                    TextFormField(
                      controller: _jobTypeController,
                      decoration: InputDecoration(
                        labelText: loc.jobType,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onChanged: (v) => jobType = v,
                    ),
                    SizedBox(height: 16.h),

                    // المكان
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: loc.location,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onChanged: (v) => location = v,
                    ),
                    SizedBox(height: 16.h),

                    // الراتب
                    TextFormField(
                      controller: _salaryController,
                      decoration: InputDecoration(
                        labelText: loc.salary,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onChanged: (v) => salary = v,
                    ),
                    SizedBox(height: 16.h),

                    // رابط التقديم
                    TextFormField(
                      controller: _jobLinkController,
                      decoration: InputDecoration(labelText: loc.jobLink),
                      keyboardType: TextInputType.url,
                    ),
                    SizedBox(height: 12.h),

                    // نوع الرابط
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            value: 'direct',
                            groupValue: _jobLinkType,
                            title: Text(loc.directApplyLink),
                            onChanged: (v) => setState(() => _jobLinkType = v!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            value: 'external',
                            groupValue: _jobLinkType,
                            title: Text(loc.externalJobPage),
                            onChanged: (v) => setState(() => _jobLinkType = v!),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // إرفاق ملف جديد
                  /* ───────── attachment ───────── */
                  if (widget.thread.fileAttachment != null && !_clearExistingFile && _selectedFile == null)
                    ListTile(
                      leading: const Icon(Icons.insert_drive_file, color: AppColors.primaryColor),
                      title: Text(widget.thread.fileAttachmentName ?? loc.previousAttachment),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: _removeFile,
                      ),
                    )
                  else if (_selectedFile == null)
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
                      title: Text(_selectedFile!.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: _removeFile,
                      ),
                    ),



                  SizedBox(height: 24.h),

                  // زر الحفظ
                  BlocBuilder<ThreadBloc, ThreadState>(
                    bloc: widget.threadBloc,
                    builder: (context, state) {
                      if (state is ThreadLoading && _waitingResponse) {
                        return const CircularProgressIndicator();
                      }
                      return ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                        child: Text(
                            loc.saveChanges,
                          style: TextStyle(fontSize: 16.sp, color: Colors.white),
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
