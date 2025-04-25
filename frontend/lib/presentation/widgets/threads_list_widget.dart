// presentation/widgets/threads_list_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/data/models/thread_model.dart';
import 'package:frontend/presentation/screens/thread/thread_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'modern_thread_card.dart'; // استيراد ModernThreadCard

class ThreadsListWidget extends StatelessWidget {
  final Future<List<ThreadModel>> threadsFuture;
  final List<ThreadModel> Function(List<ThreadModel>) filterThreads;
  final Future<void> Function() onRefresh;

  const ThreadsListWidget({
    Key? key,
    required this.threadsFuture,
    required this.filterThreads,
    required this.onRefresh,
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
            return Center(child: Text(loc.noThreads, style: TextStyle(fontSize: 16.sp, color: Colors.grey)));
          }
          return RefreshIndicator(
            onRefresh: onRefresh,
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
                      MaterialPageRoute(builder: (_) => ThreadPage(threadId: thread.id)),
                    );
                  },
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