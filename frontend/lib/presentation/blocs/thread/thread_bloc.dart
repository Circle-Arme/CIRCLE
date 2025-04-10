import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/thread_service.dart';
import 'thread_event.dart';
import 'thread_state.dart';

class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  ThreadBloc() : super(ThreadInitial()) {
    on<FetchThreadsEvent>((event, emit) async {
      emit(ThreadLoading());
      try {
        final threads = await ThreadService.fetchThreads(
          event.communityId,
          isJobOpportunity: event.isJobOpportunity,
        );
        emit(ThreadLoaded(threads));
      } catch (e) {
        emit(ThreadError(e.toString()));
      }
    });

    on<CreateThreadEvent>((event, emit) async {
      emit(ThreadLoading());
      try {
        await ThreadService.createThread(
          event.communityId,
          event.title,
          event.content,
          event.classification,
          event.tags,
          isJobOpportunity: event.isJobOpportunity,
        );
        final threads = await ThreadService.fetchThreads(
          event.communityId,
          isJobOpportunity: event.isJobOpportunity,
        );
        emit(ThreadLoaded(threads));
      } catch (e) {
        emit(ThreadError(e.toString()));
      }
    });
  }
}
