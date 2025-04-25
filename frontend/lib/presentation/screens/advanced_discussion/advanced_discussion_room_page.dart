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
import 'package:frontend/presentation/screens/job_opportunities/job_opportunities_page.dart';

class AdvancedDiscussionRoomPage extends StatefulWidget {
  final int communityId;

  const AdvancedDiscussionRoomPage({Key? key, required this.communityId}) : super(key: key);

  @override
  State<AdvancedDiscussionRoomPage> createState() => _AdvancedDiscussionRoomPage();
}

class _AdvancedDiscussionRoomPage extends State<AdvancedDiscussionRoomPage> {
String _activeFilterType = 'topic';
  String _selectedFilterOption = 'All';
  String _searchQuery = '';
  late Future<List<ThreadModel>> _threadsFuture;
  late Future<String?> _userTypeFuture;

  @override
  void initState() {
    super.initState();
    _threadsFuture = ThreadService.fetchThreads(widget.communityId);
    _userTypeFuture = AuthService.getUserType();
    context.read<ThreadBloc>().add(FetchThreadsEvent(widget.communityId)); // الآن يمكن الوصول إلى ThreadBloc
  }

  Future<void> _refreshThreads() async {
    context.read<ThreadBloc>().add(FetchThreadsEvent(widget.communityId));
  }

  List<ThreadModel> _filterThreads(List<ThreadModel> threads) {
    List<ThreadModel> filtered = threads;

    if (_activeFilterType == 'topic') {
      if (_selectedFilterOption == 'Q&A' || _selectedFilterOption == 'General') {
        filtered = filtered.where((t) => t.classification == _selectedFilterOption).toList();
      }
    } else if (_activeFilterType == 'engagement') {
      if (_selectedFilterOption == 'mostPopular') {
        filtered.sort((a, b) => b.repliesCount.compareTo(a.repliesCount));
      } else if (_selectedFilterOption == 'latest') {
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  Future<void> _createNewThread() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateThreadForm(
          communityId: widget.communityId,
          isJobOpportunity: false,
          threadBloc: context.read<ThreadBloc>(), // الآن يمكن الوصول إلى ThreadBloc
        ),
      ),
    );
    _refreshThreads();
  }

  Widget _buildFilterButton() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          _activeFilterType = value;
          _selectedFilterOption = (value == 'topic') ? 'All' : 'latest';
        });
        _refreshThreads();
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'topic', child: Text(AppLocalizations.of(context)!.filterByTopic)),
        PopupMenuItem(value: 'engagement', child: Text(AppLocalizations.of(context)!.filterByEngagement)),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.filter_list, color: AppColors.primaryColor),
          SizedBox(width: 4.w),
          const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    List<ChoiceChip> chips = [];
    if (_activeFilterType == 'topic') {
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
          onSelected: (selected) {
            setState(() => _selectedFilterOption = option);
            _refreshThreads();
          },
          selectedColor: AppColors.primaryColor.withOpacity(0.2),
          backgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        );
      }).toList();
    } else if (_activeFilterType == 'engagement') {
      final engagementOptions = ['latest', 'mostPopular'];
      chips = engagementOptions.map((option) {
        String label = option == 'latest'
            ? AppLocalizations.of(context)!.latest
            : AppLocalizations.of(context)!.mostPopular;
        return ChoiceChip(
          label: Text(label, style: TextStyle(fontSize: 14.sp)),
          selected: _selectedFilterOption == option,
          onSelected: (selected) {
            setState(() => _selectedFilterOption = option);
            _refreshThreads();
          },
          selectedColor: AppColors.primaryColor.withOpacity(0.2),
          backgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        );
      }).toList();
    }
    return Wrap(spacing: 12.w, runSpacing: 8.h, children: chips);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return FutureBuilder<String?>(
      future: _userTypeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data == "organization") {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => JobOpportunitiesPage(communityId: widget.communityId)),
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
                  fontWeight: FontWeight.bold),
            ),
            actions: [
              FutureBuilder<String?>(
                future: _userTypeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (snapshot.hasData && snapshot.data == "regular") {
                    return PopupMenuButton<String>(
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
                          child: Row(
                            children: [
                              const Icon(Icons.forum, color: AppColors.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                loc.discussionRoom,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              const Icon(Icons.check, color: AppColors.primaryColor),
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
                              Text(loc.jobOpportunities),
                            ],
                          ),
                        ),
                      ],
                    );
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
                    child: BlocBuilder<ThreadBloc, ThreadState>(
                      builder: (context, state) {
                        if (state is ThreadLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is ThreadError) {
                          return Center(child: Text("${loc.error}: ${state.message}"));
                        }  else if (state is ThreadLoaded) {
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
      },
    );
  }
}
