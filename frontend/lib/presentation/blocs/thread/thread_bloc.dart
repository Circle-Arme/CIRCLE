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
          roomType: event.roomType,
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
          event.roomType,
          event.title,
          event.content,
          event.classification,
          event.tags,
          file: event.file, // تمرير الملف
          isJobOpportunity: event.isJobOpportunity,
          jobType: event.jobType,
          location: event.location,
          salary: event.salary,
          jobLink: event.jobLink,
          jobLinkType: event.jobLinkType,
        );
        final threads = await ThreadService.fetchThreads(
          event.communityId,
          roomType: event.roomType,
          isJobOpportunity: event.isJobOpportunity,
        );
        emit(ThreadLoaded(threads));
      } catch (e) {
        emit(ThreadError(e.toString()));
      }
    });
    on<UpdateThreadEvent>((event, emit) async {
      emit(ThreadLoading());
      try {
        await ThreadService.updateThread(
          event.threadId,
          title:          event.title,
          details:        event.content,
          classification: event.classification,
          tags:           event.tags,
          file:           event.file,
          isJobOpportunity: event.isJobOpportunity,
          jobType:        event.jobType,
          location:       event.location,
          salary:         event.salary,
          jobLink:        event.jobLink,
          jobLinkType:    event.jobLinkType,
        );
        // أعد جلب الثريدات لتحديث القائمة:
        final threads = await ThreadService.fetchThreads(
          event.communityId,
          roomType:          event.roomType,
          isJobOpportunity:  event.isJobOpportunity,
        );
        emit(ThreadLoaded(threads));
      } catch (e) {
        emit(ThreadError(e.toString()));
      }
    });
  }
}
