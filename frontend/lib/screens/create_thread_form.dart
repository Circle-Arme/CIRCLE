// pages/create_thread_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/thread_model.dart.dart';
import '../theme/app_colors.dart';

class CreateThreadPage extends StatefulWidget {
  const CreateThreadPage({Key? key}) : super(key: key);

  @override
  State<CreateThreadPage> createState() => _CreateThreadPageState();
}

class _CreateThreadPageState extends State<CreateThreadPage> {
  final _formKey = GlobalKey<FormState>();

  // الحقول المطلوبة لإنشاء الثريد
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

  // دالة التحقق من صحة النموذج وإنشاء الثريد
  void _submit() {
    if (_formKey.currentState!.validate()) {
      // تحويل الوسوم من نص إلى قائمة (يفترض فصلها بفواصل)
      final List<String> tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // إنشاء كائن جديد من نوع ThreadModel
      final newThread = ThreadModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        creatorName: "CurrentUser", // يجب استبداله باسم المستخدم الحالي
        createdAt: DateTime.now(),
        repliesCount: 0,
        classification: _classification,
        content: _contentController.text.trim(),
        tags: tags,
      );

      // إرجاع الثريد الجديد للصفحة السابقة أو معالجته حسب الحاجة
      Navigator.pop(context, newThread);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إنشاء موضوع جديد"),
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
                // حقل اختيار تصنيف الموضوع
                Row(
                  children: [
                    Text(
                      "تصنيف الموضوع:",
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
                            option == 'Q&A' ? "سؤال وجواب" : "نقاش عام",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // حقل عنوان الموضوع
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "عنوان الموضوع",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "يرجى إدخال عنوان الموضوع";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                // حقل الوسوم
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    labelText: "الوسوم (افصل بين كل وسم بفاصلة)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // حقل المحتوى (متعدد الأسطر)
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: "المحتوى",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "يرجى إدخال محتوى الموضوع";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                // زر إنشاء الموضوع
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: 40.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    backgroundColor: AppColors.primaryColor,
                  ),
                  child: Text(
                    "إنشاء الموضوع",
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
