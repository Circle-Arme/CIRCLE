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
import '../../widgets/custom_drawer.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/threads_list_widget.dart';
import 'package:frontend/presentation/screens/discussion/discussion_room_page.dart';

class JobOpportunitiesPage extends StatefulWidget {
  final int communityId;

  const JobOpportunitiesPage({Key? key, required this.communityId}) : super(key: key);

  @override
  State<JobOpportunitiesPage> createState() => _JobOpportunitiesPageState();
}

class _JobOpportunitiesPageState extends State<JobOpportunitiesPage> {
  String _selectedFilterOption = 'All';
  String _searchQuery = '';
  late Future<List<ThreadModel>> _threadsFuture;
  late Future<String?> _userTypeFuture;

  @override
  void initState() {
    super.initState();
    _threadsFuture = ThreadService.fetchThreads(widget.communityId, roomType: 'job_opportunities', isJobOpportunity: true);
    _userTypeFuture = AuthService.getUserType();
    context.read<ThreadBloc>().add(FetchThreadsEvent(
      widget.communityId,
      'job_opportunities',
      isJobOpportunity: true,
    ));
  }

  Future<void> _refreshThreads() async {
    context.read<ThreadBloc>().add(FetchThreadsEvent(
      widget.communityId,
      'job_opportunities',
      isJobOpportunity: true,
    ));
  }

  List<ThreadModel> _filterThreads(List<ThreadModel> threads) {
    var filtered = List<ThreadModel>.from(threads);

    // فلترة حسب التصنيف Q&A أو General
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
    // الافتراضي: ديفولت ترتيب زمني (لا يحتاج كود إضافي)
    return filtered;
  }

  Future<void> _createNewThread() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateThreadForm(
          communityId: widget.communityId,
          roomType: 'job_opportunities',
          isJobOpportunity: true,
          threadBloc: context.read<ThreadBloc>(),
        ),
      ),
    );
    _refreshThreads();
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: Text(
          loc.jobOpportunities,
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          FutureBuilder<String?>(
            future: _userTypeFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              if (snapshot.hasData && snapshot.data == 'regular') {
                return IconButton(
                  icon: const Icon(Icons.forum, color: AppColors.primaryColor),
                  tooltip: loc.discussionRoom,
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DiscussionRoomPage(communityId: widget.communityId),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          )
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
              _buildFilterChips(),      // ← شريط الخيارات الأفقي
              SizedBox(height: 16.h),
              Expanded(
                child: BlocBuilder<ThreadBloc, ThreadState>(
                  builder: (context, state) {
                    if (state is ThreadLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ThreadError) {
                      return Center(child: Text("${loc.error}: ${state.message}"));
                    } else if (state is ThreadLoaded) {
                      return ThreadsListWidget(
                        threadsFuture: Future.value(state.threads),
                        filterThreads: _filterThreads,
                        onRefresh: _refreshThreads,
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
  }
}
