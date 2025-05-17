import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/presentation/blocs/thread/thread_bloc.dart';
import 'package:frontend/presentation/blocs/thread/thread_event.dart';
import 'package:frontend/presentation/blocs/thread/thread_state.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_colors.dart';

class CreateThreadForm extends StatefulWidget {
  final int communityId;
  final String roomType;
  final bool isJobOpportunity;
  final ThreadBloc threadBloc;

  const CreateThreadForm({
    Key? key,
    required this.communityId,
    required this.roomType,
    this.isJobOpportunity = false,
    required this.threadBloc,
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
  final TextEditingController _jobLinkController = TextEditingController();
  final List<String> _jobTypeOptions = ['Full-time', 'Part-time', 'Remote'];
  String _jobType = 'Full-time';
  String _jobLinkType = 'direct';
  PlatformFile? _selectedFile;

  String? jobType;
  String? location;
  String? salary;

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _contentController.dispose();
    _jobLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final List<String> tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      widget.threadBloc.add(
        CreateThreadEvent(
          widget.communityId,
          widget.roomType,
          _titleController.text.trim(),
          _contentController.text.trim(),
          _classification,
          tags,
          file: _selectedFile,
          isJobOpportunity: widget.isJobOpportunity,
          jobType: widget.isJobOpportunity ? _jobType : null,
          location: widget.isJobOpportunity ? location : null,
          salary: widget.isJobOpportunity ? salary : null,
          jobLink: widget.isJobOpportunity ? _jobLinkController.text.trim() : null,
          jobLinkType: widget.isJobOpportunity ? _jobLinkType : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocListener<ThreadBloc, ThreadState>(
      bloc: widget.threadBloc,
      listener: (context, state) {
        if (state is ThreadLoaded) {
          //Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.threadCreatedSuccessfully)),
          );
        } else if (state is ThreadError) {
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
                  if (!widget.isJobOpportunity)
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
                        borderSide: const BorderSide(color: AppColors.borderColor),
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
                        borderSide: const BorderSide(color: AppColors.borderColor),
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
                        borderSide: const BorderSide(color: AppColors.borderColor),
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
                  SizedBox(height: 16.h),
                  if (widget.isJobOpportunity) ...[
                    DropdownButtonFormField<String>(
                      value: _jobType,
                      items: _jobTypeOptions.map((opt) {
                        return DropdownMenuItem(
                          value: opt,
                          child: Text(
                            opt == 'Full-time'
                                ? loc.fullTime
                                : opt == 'Part-time'
                                ? loc.partTime
                                : loc.remote,
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: loc.jobType,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                        ),

                      ),
                      onChanged: (val) => setState(() => _jobType = val!),
                      validator: (_) => null, // ليس مطلوبًا
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: loc.location,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                      onChanged: (val) {
                        location = val;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: loc.salary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                      onChanged: (val) {
                        salary = val;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _jobLinkController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        labelText: loc.jobLink,
                        hintText: 'https://example.com/job/123',
                        prefixIcon: const Icon(Icons.link),
                        //helperText: loc.jobLinkType, // مثلاً: "انسخ رابط التقديم المباشر أو صفحة الوظيفة"
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc.enterJobLink;        // "الرجاء إدخال رابط التقديم"
                        }
                        final urlPattern = r'^(https?:\/\/)'      // بروتوكول إجباري
                            r'([-\w]+\.)+[\w]{2,}'                // دومين
                            r'(\/[-\w@:%_\+.~#?&//=]*)?$';        // مسار اختياري
                        if (!RegExp(urlPattern).hasMatch(value.trim())) {
                          return loc.invalidJobLink;               // "الرجاء إدخال رابط صحيح"
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

// —— اختيار نوع الرابط باستخدام DropdownButtonFormField ——
                    DropdownButtonFormField<String>(
                      value: _jobLinkType,
                      decoration: InputDecoration(
                        labelText: loc.jobLinkType,               // تأكد من وجود هذا المفتاح في الترجمة: "نوع الرابط"
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'direct',
                          child: Text(loc.directApplyLink),   // "رابط تقديم مباشر"
                        ),
                        DropdownMenuItem(
                          value: 'external',
                          child: Text(loc.externalJobPage),   // "صفحة الوظيفة الخارجية"
                        ),
                      ],
                      onChanged: (val) => setState(() => _jobLinkType = val!),
                    ),
                    SizedBox(height: 16.h),
                  ],
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file, color: Colors.white),
                    label: Text(_selectedFile != null ? _selectedFile!.name : loc.attachFile, style: const TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),),
                  ),
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