// pages/discussion_room_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/thread_model.dart.dart';
import '../theme/app_colors.dart';
import 'thread_page.dart';
import 'create_thread_form.dart';

class DiscussionRoomPage extends StatefulWidget {
  const DiscussionRoomPage({Key? key}) : super(key: key);

  @override
  State<DiscussionRoomPage> createState() => _DiscussionRoomPageState();
}

class _DiscussionRoomPageState extends State<DiscussionRoomPage> {
  // قائمة تجريبية من الثريدات (يمكن استبدالها ببيانات من API)
  List<ThreadModel> allThreads = [
    ThreadModel(
      id: "1",
      title: "مرحبا! لدي سؤال عن المشروع",
      creatorName: "Abeer",
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      repliesCount: 5,
      classification: 'Q&A',
      content: "تفاصيل أكثر حول السؤال...",
      tags: ["مشروع", "Flutter", "استفسار"],
    ),
    ThreadModel(
      id: "2",
      title: "اقتراح تطوير ميزة البحث",
      creatorName: "Mayada",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      repliesCount: 2,
      classification: 'General',
      content: "لدي فكرة حول تحسين واجهة البحث...",
      tags: ["اقتراح", "تطوير", "UI/UX"],
    ),
  ];

  // خيارات الفلترة
  final List<String> filterOptions = ['All', 'Q&A', 'General'];
  String _selectedFilter = 'All';

  // متغير لتخزين قيمة البحث
  String _searchQuery = '';

  // دالة إرجاع الثريدات المفلترة بناءً على التصنيف والبحث
  List<ThreadModel> _getFilteredThreads() {
    List<ThreadModel> filtered = allThreads;
    if (_selectedFilter != 'All') {
      filtered =
          filtered.where((t) => t.classification == _selectedFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((t) =>
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return filtered;
  }

  // دالة إنشاء ثريد جديد عبر عرض الفورم
  Future<void> _createNewThread() async {
    final newThread = await showDialog<ThreadModel>(
      context: context,
      builder: (_) => const CreateThreadPage(),
    );
    if (newThread != null) {
      setState(() {
        allThreads.insert(0, newThread);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredThreads = _getFilteredThreads();

    return Scaffold(
      appBar: AppBar(
        title: const Text("غرفة النقاش"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        titleTextStyle: const TextStyle(
          color: AppColors.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        // شريط بحث مدمج ضمن AppBar
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'ابحث عن موضوع...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
        ),
      ),
      // خلفية برغماتية بسيطة
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.grey.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // قائمة الفلاتر باستخدام ChoiceChips
              SizedBox(
                height: 40.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filterOptions.length,
                  itemBuilder: (context, index) {
                    final option = filterOptions[index];
                    String label = option == 'All'
                        ? 'الكل'
                        : option == 'Q&A'
                        ? 'سؤال وجواب'
                        : 'نقاش عام';
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: ChoiceChip(
                        label: Text(
                          label,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        selected: _selectedFilter == option,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = option;
                          });
                        },
                        selectedColor:
                        AppColors.primaryColor.withOpacity(0.2),
                        backgroundColor: Colors.grey[300],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              // عرض قائمة الثريدات باستخدام AnimatedSwitcher
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: filteredThreads.isNotEmpty
                      ? ListView.builder(
                    key: ValueKey<String>(
                        _selectedFilter + _searchQuery),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredThreads.length,
                    itemBuilder: (context, index) {
                      final thread = filteredThreads[index];
                      return ModernThreadCard(
                        thread: thread,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ThreadPage(thread: thread),
                            ),
                          );
                        },
                      );
                    },
                  )
                      : Center(
                    child: Text(
                      "لا توجد مواضيع",
                      style: TextStyle(
                          fontSize: 16.sp, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewThread,
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text("موضوع جديد"),
      ),
    );
  }
}

// بطاقة عرض الثريد بأسلوب عصري
class ModernThreadCard extends StatelessWidget {
  final ThreadModel thread;
  final VoidCallback onTap;

  const ModernThreadCard({
    Key? key,
    required this.thread,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isQnA = thread.classification == 'Q&A';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // أيقونة الموضوع مع خلفية متدرجة
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isQnA
                        ? [Colors.blueAccent, Colors.lightBlueAccent]
                        : [Colors.green, Colors.lightGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.all(12.w),
                child: Icon(
                  isQnA ? Icons.question_answer : Icons.chat,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "بقلم ${thread.creatorName}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // عرض الوسوم في صف واحد
                    Wrap(
                      spacing: 6.w,
                      children: thread.tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          backgroundColor:
                          AppColors.primaryColor.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(
                    Icons.message,
                    size: 18.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "${thread.repliesCount}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
