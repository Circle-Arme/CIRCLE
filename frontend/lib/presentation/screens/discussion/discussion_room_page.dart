import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/data/models/thread_model.dart';
import 'package:frontend/core/services/thread_service.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/presentation/screens/thread/thread_page.dart';
import 'package:frontend/presentation/screens/thread/create_thread_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../widgets/custom_drawer.dart';

// تأكد من وجود صفحة فرص العمل JobOpportunitiesPage في المشروع
import 'package:frontend/presentation/screens/job_opportunities/job_opportunities_page.dart';

class DiscussionRoomPage extends StatefulWidget {
  final int communityId;

  const DiscussionRoomPage({Key? key, required this.communityId})
      : super(key: key);

  @override
  State<DiscussionRoomPage> createState() => _DiscussionRoomPageState();
}

class _DiscussionRoomPageState extends State<DiscussionRoomPage> {
  // المتغيرات الخاصة بالفلترة:
  // _activeFilterType: نوع الفلترة العام (topic أو engagement)
  // _selectedFilterOption: الخيار المحدد ضمن الفئة المختارة
  String _activeFilterType = 'topic'; // القيمة الافتراضية "حسب الموضوع"
  String _selectedFilterOption = 'All'; // ضمن موضوع، الخيار الافتراضي "الكل"
  String _searchQuery = '';

  late Future<List<ThreadModel>> _threadsFuture;

  @override
  void initState() {
    super.initState();
    _threadsFuture = ThreadService.fetchThreads(widget.communityId);
  }

  Future<void> _refreshThreads() async {
    setState(() {
      _threadsFuture = ThreadService.fetchThreads(widget.communityId);
    });
  }

  /// دالة الفلترة بناءً على نوع الفلترة (topic أو engagement) والخيار المحدد
  List<ThreadModel> _filterThreads(List<ThreadModel> threads) {
    List<ThreadModel> filtered = threads;

    // إذا كان التصنيف حسب الموضوع:
    if (_activeFilterType == 'topic') {
      if (_selectedFilterOption == 'Q&A' || _selectedFilterOption == 'General') {
        filtered = filtered.where((t) => t.classification == _selectedFilterOption).toList();
      }
      // إذا كانت القيمة "All" لا نطبق فلترة موضوعية
    }
    // إذا كان التصنيف حسب التفاعل:
    else if (_activeFilterType == 'engagement') {
      if (_selectedFilterOption == 'mostPopular') {
        filtered.sort((a, b) => b.repliesCount.compareTo(a.repliesCount));
      } else if (_selectedFilterOption == 'latest') {
        // تأكد أن موديل ThreadModel يحتوي على خاصية createdAt من نوع DateTime
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    }

    // فلترة البحث حسب عنوان الموضوع
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  Future<void> _createNewThread() async {
    final newThread = await Navigator.push<ThreadModel>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateThreadForm(
          communityId: widget.communityId,
          isJobOpportunity: false,
        ),
      ),
    );

    if (newThread != null) {
      try {
        await ThreadService.createThread(
          widget.communityId,
          newThread.title,
          newThread.content,
          newThread.classification,
          newThread.tags,
          isJobOpportunity: false,
        );
        _refreshThreads();
      } catch (e) {
        _showErrorSnack(e.toString());
      }
    }
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  /// زر "Filter" الذي يسمح بتحديد نوع الفلترة: حسب الموضوع أو حسب التفاعل
  Widget _buildFilterButton() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          _activeFilterType = value;
          // تعيين القيمة الافتراضية بناءً على نوع الفلترة
          _selectedFilterOption = (value == 'topic') ? 'All' : 'latest';
        });
        _refreshThreads();
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
            value: 'topic',
            child: Text(AppLocalizations.of(context)!.filterByTopic)),
        PopupMenuItem<String>(
            value: 'engagement',
            child: Text(AppLocalizations.of(context)!.filterByEngagement)),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.filter_list, color: AppColors.primaryColor),
          SizedBox(width: 4.w),
          //Text("Filter", style: TextStyle(color: AppColors.primaryColor)),
          const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
        ],
      ),
    );
  }

  /// بناء مجموعة الـ ChoiceChips بناءً على _activeFilterType
  Widget _buildFilterChips() {
    List<ChoiceChip> chips = [];
    if (_activeFilterType == 'topic') {
      // خيارات تصنيف الموضوع
      final topicOptions = ['All', 'Q&A', 'General'];
      chips = topicOptions.map((option) {
        String label;
        IconData icon;
        if (option == 'All') {
          label = AppLocalizations.of(context)!.filterAll;
          icon = Icons.list;
        } else if (option == 'Q&A') {
          label = AppLocalizations.of(context)!.filterQna;
          icon = Icons.question_answer;
        } else {
          label = AppLocalizations.of(context)!.filterGeneral;
          icon = Icons.forum;
        }
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18.sp),
              SizedBox(width: 4.w),
              Text(label, style: TextStyle(fontSize: 14.sp)),
            ],
          ),
          selected: _selectedFilterOption == option,
          onSelected: (bool selected) {
            setState(() {
              _selectedFilterOption = option;
            });
            _refreshThreads();
          },
          selectedColor: AppColors.primaryColor.withOpacity(0.2),
          backgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        );
      }).toList();
    } else if (_activeFilterType == 'engagement') {
      // خيارات تصنيف التفاعل
      final engagementOptions = ['latest', 'mostPopular'];
      chips = engagementOptions.map((option) {
        String label;
        if (option == 'latest') {
          label = AppLocalizations.of(context)!.latest;
        } else {
          label = AppLocalizations.of(context)!.mostPopular;
        }
        return ChoiceChip(
          label: Text(label, style: TextStyle(fontSize: 14.sp)),
          selected: _selectedFilterOption == option,
          onSelected: (bool selected) {
            setState(() {
              _selectedFilterOption = option;
            });
            _refreshThreads();
          },
          selectedColor: AppColors.primaryColor.withOpacity(0.2),
          backgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        );
      }).toList();
    }
    return Wrap(
      spacing: 12.w,
      runSpacing: 8.h,
      children: chips,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.discussionRoom,
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            // القائمة المنسدلة للتنقل بين غرفة النقاش وفرص العمل
            PopupMenuButton<String>(
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
              onSelected: (value) {
                if (value == 'jobs') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobOpportunitiesPage(communityId: widget.communityId),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'discussion',
                  enabled: false, // الصفحة الحالية
                  child: Row(
                    children: [
                      const Icon(Icons.forum, color: AppColors.primaryColor),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.discussionRoom),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'jobs',
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primaryColor,
                        child: Icon(Icons.work, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.jobOpportunities),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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
                hintText: AppLocalizations.of(context)!.searchTopic,
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
              // نجمع زر Filter مع الـ ChoiceChips في صف واحد لتوفير المساحة
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterButton(),
                    SizedBox(width: 8.w),
                    Expanded(child: _buildFilterChips()),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: FutureBuilder<List<ThreadModel>>(
                  future: _threadsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "${AppLocalizations.of(context)!.error}: ${snapshot.error}",
                        ),
                      );
                    } else if (snapshot.hasData) {
                      final threads = snapshot.data!;
                      final filteredThreads = _filterThreads(threads);

                      if (filteredThreads.isEmpty) {
                        return Center(
                          child: Text(
                            AppLocalizations.of(context)!.noThreads,
                            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _refreshThreads,
                        child: ListView.builder(
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
                                    builder: (_) => ThreadPage(threadId: thread.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewThread,
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.newTopic,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

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
                      "${AppLocalizations.of(context)!.by} ${thread.creatorName}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 6.w,
                      children: thread.tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          backgroundColor: AppColors.primaryColor.withOpacity(0.1),
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
