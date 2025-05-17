import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/data/models/thread_model.dart';
import 'package:frontend/core/services/thread_service.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/presentation/blocs/thread/thread_bloc.dart';
import 'package:frontend/presentation/blocs/thread/thread_event.dart';
import 'package:frontend/presentation/blocs/thread/thread_state.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/presentation/screens/thread/create_thread_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/utils/shared_prefs.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/threads_list_widget.dart';
import 'package:frontend/presentation/screens/job_opportunities/job_opportunities_page.dart';

import '../advanced_discussion/advanced_discussion_room_page.dart';
import '../thread/edit_thread_form.dart';

class DiscussionRoomPage extends StatefulWidget {
  final int communityId;

  const DiscussionRoomPage({Key? key, required this.communityId}) : super(key: key);

  @override
  State<DiscussionRoomPage> createState() => _DiscussionRoomPageState();
}

class _DiscussionRoomPageState extends State<DiscussionRoomPage> {
  String _selectedFilterOption = 'All';
  String _searchQuery = '';
  String _communityLevel = 'both';
  late Future<List<ThreadModel>> _threadsFuture;
  late Future<String?> _userTypeFuture;
  late Future<String?> _currentUserIdFuture;

  @override
  void initState() {
    super.initState();
    _threadsFuture = ThreadService.fetchThreads(widget.communityId, roomType: 'discussion_general');
    _userTypeFuture = AuthService.getUserType();
    _currentUserIdFuture = AuthService.getCurrentUserId();
    context.read<ThreadBloc>().add(FetchThreadsEvent(widget.communityId, 'discussion_general'));
    SharedPrefs.getCommunityLevel(widget.communityId)
        .then((lvl) => setState(() => _communityLevel = lvl ?? 'both'));
  }

  Future<void> _refreshThreads() async {
    context.read<ThreadBloc>().add(FetchThreadsEvent(widget.communityId, 'discussion_general'));
  }

  List<ThreadModel> _filterThreads(List<ThreadModel> threads) {
    var filtered = List<ThreadModel>.from(threads);

    // فلترة حسب التصنيف
    if (_selectedFilterOption == 'Q&A' || _selectedFilterOption == 'General') {
      filtered = filtered.where((t) => t.classification == _selectedFilterOption).toList();
    }
    // الأكثر تفاعلاً
    else if (_selectedFilterOption == 'mostPopular') {
      filtered.sort((a, b) => b.repliesCount.compareTo(a.repliesCount));
    }
    // البحث بالكلمات
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    // الافتراضي: زمنيًا (لا يحتاج كود إضافي)
    return filtered;
  }
  void _onRoomSelected(String value) {
    if (value == 'discussion' && runtimeType != DiscussionRoomPage) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DiscussionRoomPage(communityId: widget.communityId),
        ),
      );
    } else if (value == 'advanced' && runtimeType != AdvancedDiscussionRoomPage) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdvancedDiscussionRoomPage(communityId: widget.communityId),
        ),
      );
    } else if (value == 'jobs' && runtimeType != JobOpportunitiesPage) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => JobOpportunitiesPage(communityId: widget.communityId),
        ),
      );
    }
  }


  Future<void> _createNewThread() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateThreadForm(
          communityId: widget.communityId,
          roomType:    'discussion_general',    // أو job_opportunities
          isJobOpportunity: false,              // ← true فى صفحة الوظائف
          threadBloc: context.read<ThreadBloc>(),
        ),
      ),
    );

    //if (created == true) _refreshThreads();     // حدِّث القائمة فقط
    _refreshThreads();
  }

  Future<void> _confirmDelete(ThreadModel thread) async {
    final loc = AppLocalizations.of(context)!;

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          loc.delete,
          style: const TextStyle(color: Colors.red),
        ),
        content: Text(loc.confirmDeleteThread), // أضف هذا المفتاح في arb
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(loc.delete),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ThreadService.deleteThread(int.parse(thread.id));
      _refreshThreads();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.threadDeleted)), // مفتاح جديد أيضًا
      );
    }
  }


  /// شريط الشيبس الأفقي
  Widget _buildFilterChips() {
    final loc = AppLocalizations.of(context)!;
    final options = [
      {'label': loc.filterAll,     'value': 'All'},
      {'label': loc.filterQna,     'value': 'Q&A'},
      {'label': loc.filterGeneral, 'value': 'General'},
      {'label': loc.mostPopular,   'value': 'mostPopular'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final value = option['value']!;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(option['label']!, style: TextStyle(fontSize: 14.sp)),
              selected: _selectedFilterOption == value,
              onSelected: (_) {
                setState(() => _selectedFilterOption = value);
                _refreshThreads();
              },
              selectedColor: AppColors.primaryColor.withOpacity(0.25),
              backgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// helper
  Widget _menuRow({
    required IconData icon,
    required String text,
    required bool selected,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        if (selected)
          const Icon(Icons.check, color: AppColors.primaryColor),
      ],
    );
  }

  Widget _buildRoomSwitcher() {
    return FutureBuilder<String?>(
      future: SharedPrefs.getCommunityLevel(widget.communityId),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();   // لم يصل المستوى بَعْد
        final level = snap.data!;                            // beginner / advanced / both

        return PopupMenuButton<String>(
          tooltip: AppLocalizations.of(context)!.switchRoom,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
          onSelected: _onRoomSelected,
          itemBuilder: (ctx) => _buildMenuItems(ctx, level),
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext ctx, String level) {
    final loc = AppLocalizations.of(ctx)!;
    final items = <PopupMenuEntry<String>>[];

    if (level == 'both' || level == 'beginner') {
      items.add(
        PopupMenuItem(
          value: 'discussion',
          child: _menuRow(
            icon: Icons.forum,
            text: loc.discussionRoom,
            selected: runtimeType == DiscussionRoomPage,
          ),
        ),
      );
    }
    if (level == 'both' || level == 'advanced') {
      items.add(
        PopupMenuItem(
          value: 'advanced',
          child: _menuRow(
            icon: Icons.school,
            text: loc.advancedDiscussionRoom,
            selected: runtimeType == AdvancedDiscussionRoomPage,
          ),
        ),
      );
    }

    // غرفة فرص العمل متاحة دائمًا
    items.add(const PopupMenuDivider());
    items.add(
      PopupMenuItem(
        value: 'jobs',
        child: _menuRow(
          icon: Icons.work,
          text: loc.jobOpportunities,
          selected: runtimeType == JobOpportunitiesPage,
        ),
      ),
    );
    return items;
  }



  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return FutureBuilder<String?>(
      future: _userTypeFuture,
      builder: (context, snapshot) {
        print('[MENU] snapshot state = ${snapshot.connectionState}, data = ${snapshot.data}');
        // تحويل المنظمات لصفحة الوظائف مباشرة
        if (snapshot.hasData && snapshot.data == 'organization') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => JobOpportunitiesPage(communityId: widget.communityId),
              ),
            );
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          drawer: const CustomDrawer(),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.primaryColor),
            title: Text(
              loc.discussionRoom,
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              FutureBuilder<String?>(
                future: _userTypeFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.done && snap.data == 'normal') {
                    // هنا تستدعي زرّ السهم الجاهز
                    return _buildRoomSwitcher();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(60.h),
              child: SearchBarWidget(
                hintText: loc.searchTopic,
                onChanged: (value) => setState(() => _searchQuery = value),
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
                  _buildFilterChips(),          // ← الشيبس الأفقي
                  SizedBox(height: 16.h),
                  Expanded(
                    child: BlocBuilder<ThreadBloc, ThreadState>(
                      builder: (context, state) {
                        if (state is ThreadLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is ThreadError) {
                          return Center(child: Text("${loc.error}: ${state.message}"));
                        } else if (state is ThreadLoaded) {
                          // ← تلفين هنا FutureBuilder لقراءة currentUserId
                          return FutureBuilder<String?>(
                            future: _currentUserIdFuture,
                            builder: (context, userSnap) {
                              if (userSnap.connectionState != ConnectionState.done) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              // حول السلسلة لرقم (أو افتراضي -1 لو فشل)
                              final currentUserId = int.tryParse(userSnap.data ?? '') ?? -1;

                              return ThreadsListWidget(
                                threadsFuture:   Future.value(state.threads),
                                filterThreads:  _filterThreads,
                                onRefresh:      _refreshThreads,
                                currentUserId:  currentUserId,        // ← صار معرف
                                onEdit: (thread) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditThreadForm(
                                        thread:thread,
                                        communityId: widget.communityId,
                                        roomType:    'discussion_general',
                                        isJobOpportunity: thread.isJobOpportunity,
                                        threadBloc:  context.read<ThreadBloc>(),),
                                    ),
                                  ).then((_) => _refreshThreads());
                                },
                                onDelete: _confirmDelete,
                              );
                            },
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
            label: Text(loc.newTopic, style: const TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }
}
