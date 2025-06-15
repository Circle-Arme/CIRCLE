import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/data/models/thread_model.dart';
import 'package:frontend/presentation/screens/thread/thread_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'job_opportunity_card.dart';
// presentation/widgets/job_threads_list_widget.dart
class JobThreadsListWidget extends StatelessWidget {
  final Future<List<ThreadModel>> threadsFuture;
  final List<ThreadModel> Function(List<ThreadModel>) filterThreads;
  final Future<void> Function() onRefresh;
  final int currentUserId;
  final int communityId;
  final void Function(ThreadModel) onEdit;
  final Future<void> Function(ThreadModel) onDelete;

  const JobThreadsListWidget({
    Key? key,
    required this.threadsFuture,
    required this.filterThreads,
    required this.onRefresh,
    required this.currentUserId,
    required this.communityId,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return FutureBuilder<List<ThreadModel>>(
      future: threadsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("${loc.error}: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final filteredThreads = filterThreads(snapshot.data!);
          if (filteredThreads.isEmpty) {
            return Center(child: Text(loc.noThreads,
                style: TextStyle(fontSize: 16.sp, color: Colors.grey)));
          }
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: filteredThreads.length,
              itemBuilder: (context, index) {
                final thread = filteredThreads[index];
                final isOwner = int.tryParse(thread.creatorId) == currentUserId;

                return JobOpportunityCard(
                  thread: thread,
                  isOwner: isOwner,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ThreadDetailPage(threadId: thread.id, communityId: communityId,),
                      ),
                    );
                  },
                  onEdit: () => onEdit(thread),
                  onDelete: () => onDelete(thread),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
