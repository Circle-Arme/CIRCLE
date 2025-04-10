import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import '../../../core/services/thread_service.dart';
import '../../widgets/custom_drawer.dart';
import '../../blocs/thread/thread_bloc.dart';
import '../../blocs/thread/thread_event.dart';
import '../../blocs/thread/thread_state.dart';
import '../thread/create_thread_form.dart';
import '../thread/thread_page.dart';

class JobOpportunitiesPage extends StatelessWidget {
  final int communityId;

  const JobOpportunitiesPage({Key? key, required this.communityId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThreadBloc()
        ..add(FetchThreadsEvent(communityId, isJobOpportunity: false)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F9F9),
        drawer: const CustomDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: const Color(0xFF326B80), size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.discussionRoom,
            style: TextStyle(
              color: const Color(0xFF326B80),
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Icon(Icons.notifications_none, color: const Color(0xFF326B80), size: 24.sp),
            ),
          ],
        ),
        body: BlocBuilder<ThreadBloc, ThreadState>(
          builder: (context, state) {
            if (state is ThreadLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ThreadError) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.errorOccurred(state.message),
                ),
              );
            } else if (state is ThreadLoaded) {
              final threads = state.threads;
              if (threads.isEmpty) {
                return Center(child: Text(AppLocalizations.of(context)!.noThreads));
              }
              return Padding(
                padding: EdgeInsets.all(16.w),
                child: ListView.separated(
                  itemCount: threads.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final thread = threads[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        title: Text(
                          thread.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF326B80),
                            fontSize: 16.sp,
                          ),
                        ),
                        subtitle: Text(
                          thread.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ThreadPage(threadId: thread.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF326B80),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateThreadForm(
                  communityId: communityId,
                  isJobOpportunity: false,
                ),
              ),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
