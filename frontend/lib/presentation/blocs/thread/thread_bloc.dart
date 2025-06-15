import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/services/realtime_service.dart';
import 'package:frontend/core/services/thread_service.dart';
import 'package:frontend/data/models/rt_event.dart';
import 'package:frontend/data/models/thread_model.dart';
import 'thread_event.dart';
import 'thread_state.dart';

class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  StreamSubscription<RTEvent>? _rtSub;
  String? _currentRoomType;
  int? _currentCommunityId;

  ThreadBloc() : super(ThreadInitial()) {
    /*──────────────── Start Realtime ────────────────*/
    on<StartRealtimeEvent>((event, emit) async {
      try {
        if (event.communityId == null) {
          emit(ThreadError('Invalid community ID'));
          return;
        }
        _currentRoomType = event.roomType;
        _currentCommunityId = event.communityId;
        await RealTimeService.connectCommunity(event.communityId!);

        _rtSub?.cancel();
        _rtSub = RealTimeService.stream().listen(
          _handleRT,
          onError: (e) => emit(ThreadError('Real-time connection error: $e')),
        );
      } catch (e) {
        emit(ThreadError('Failed to start real-time: $e'));
      }
    });

    /*──────────────── Fetch ────────────────*/
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

    /*──────────────── Create ────────────────*/
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
          file: event.file,
          isJobOpportunity: event.isJobOpportunity,
          jobType: event.jobType,
          location: event.location,
          salary: event.salary,
          jobLink: event.jobLink,
          jobLinkType: event.jobLinkType,
        );

        if (state is ThreadLoaded) {
          emit(ThreadLoaded((state as ThreadLoaded).threads));
        } else {
          final threads = await ThreadService.fetchThreads(
            event.communityId,
            roomType: event.roomType,
            isJobOpportunity: event.isJobOpportunity,
          );
          emit(ThreadLoaded(threads));
        }
      } catch (e) {
        emit(ThreadError('Failed to create thread: $e'));
      }
    });

    /*──────────────── Update ────────────────*/
    on<UpdateThreadEvent>((event, emit) async {
      emit(ThreadLoading());

      try {
        final updated = await ThreadService.updateThread(
          event.threadId,
          title: event.title,
          details: event.content,
          classification: event.classification,
          tags: event.tags,
          file: event.file,
          isJobOpportunity: event.isJobOpportunity,
          jobType: event.jobType,
          location: event.location,
          salary: event.salary,
          jobLink: event.jobLink,
          jobLinkType: event.jobLinkType,
        );

        if (state is ThreadLoaded) {
          // استبدل العنصر فى القائمة الحالية
          final list = List<ThreadModel>.from((state as ThreadLoaded).threads);
          final idx  = list.indexWhere((t) => t.id == event.threadId.toString());
          if (idx != -1) list[idx] = updated;
          emit(ThreadLoaded(list));
        } else {
          // لم تكن هناك قائمة مسبقًا: اجلبها من الخادم أو كوّن واحدة بها العنصر المحدث
          emit(ThreadLoaded([updated]));
          // أو:
          // final threads = await ThreadService.fetchThreads(event.communityId,
          //     roomType: event.roomType,
          //     isJobOpportunity: event.isJobOpportunity);
          // emit(ThreadLoaded(threads));
        }
      } catch (e) {
        emit(ThreadError('Failed to update thread: $e'));
      }
    });


    /*──────────────── Internal RT events ────────────────*/
    on<ThreadAdded>((e, emit) {
      if (state is ThreadLoaded) {
        final list = List<ThreadModel>.from((state as ThreadLoaded).threads);
        list.insert(0, e.thread);
        emit(ThreadLoaded(list));
      } else {
        emit(ThreadLoaded([e.thread]));
      }
    });

    on<ThreadDeleted>((e, emit) {
      if (state is ThreadLoaded) {
        final list = List<ThreadModel>.from((state as ThreadLoaded).threads)
          ..removeWhere((t) => t.id == e.id);
        emit(ThreadLoaded(list));
      }
    });

    on<ThreadUpdated>((event, emit) {
      if (state is! ThreadLoaded) return;

      final list = List<ThreadModel>.from((state as ThreadLoaded).threads);
      final idx  = list.indexWhere((t) => t.id == event.thread.id);
      if (idx != -1) {
        list[idx] = event.thread;
        emit(ThreadLoaded(list));
      } else {
        // لو لم يكن موجوداً أضفه (اختياري)
        list.insert(0, event.thread);
        emit(ThreadLoaded(list));
      }
    });


    on<ThreadLikeToggled>((e, emit) {
      if (state is ThreadLoaded) {
        final list = List<ThreadModel>.from((state as ThreadLoaded).threads);
        final idx = list.indexWhere((t) => t.id == e.id.toString());
        if (idx != -1) {
          list[idx] = list[idx].copyWith(
            likesCount: e.likes,
            likedByMe: e.likedByMe,
          );
          emit(ThreadLoaded(list));
        } else if (_currentCommunityId != null && _currentRoomType != null) {
          print('Thread with id ${e.id} not found in current list. Refreshing threads...');
          add(FetchThreadsEvent(
            _currentCommunityId!,
            _currentRoomType!,
            isJobOpportunity: _currentRoomType == 'job_opportunities',
          ));
        }
      } else if (_currentCommunityId != null && _currentRoomType != null) {
        print('State is not ThreadLoaded. Refreshing threads...');
        add(FetchThreadsEvent(
          _currentCommunityId!,
          _currentRoomType!,
          isJobOpportunity: _currentRoomType == 'job_opportunities',
        ));
      }
    });

    on<RepliesCountChanged>((e, emit) {
      if (state is ThreadLoaded) {
        final list = List<ThreadModel>.from((state as ThreadLoaded).threads);
        final idx = list.indexWhere((t) => t.id == e.threadId);
        if (idx != -1) {
          list[idx] = list[idx].copyWith(repliesCount: e.replies);
          emit(ThreadLoaded(list));
        }
      }
    });

    on<ReplyAdded>((e, emit) {
      // يمكن توسيع هذا لدعم عرض الردود الجديدة في الواجهة
    });

    on<ReplyLikeToggled>((e, emit) {
      // يمكن توسيع هذا لدعم تحديث إعجابات الردود في الواجهة
    });
  }

  /*──────────── Handle incoming RT JSON ────────────*/
  void _handleRT(RTEvent ev) {
    final eventRoomType = ev.payload['room_type']?.toString();
    if (_currentRoomType != null && eventRoomType != _currentRoomType) {
      return;
    }

    switch (ev.type) {
      case 'thread_created':
        add(ThreadAdded(ThreadModel.fromJson(ev.payload['thread'])));
        break;
      case 'thread_updated':
        add(ThreadUpdated(ThreadModel.fromJson(ev.payload['thread'])));
        break;
      case 'thread_deleted':
        add(ThreadDeleted(ev.payload['id'].toString()));
        break;
      case 'thread_like_toggled':
        final threadId = ev.payload['id']?.toString();
        final likes = ev.payload['likes'] as int?;
        final likedByMe = ev.payload['liked_by_me'] as bool?;
        if (threadId != null && likes != null && likedByMe != null) {
          add(ThreadLikeToggled(
            id: threadId,
            likes: likes,
            likedByMe: likedByMe,
          ));
        } else {
          print('Invalid thread_like_toggled payload: ${ev.payload}');
        }
        break;
      case 'reply_added':
      case 'reply_deleted':
        add(RepliesCountChanged(
          threadId: ev.payload['thread_id'].toString(),
          replies: ev.payload['replies'] as int? ?? 0,
        ));
        if (ev.type == 'reply_added') {
          add(ReplyAdded(ReplyModel.fromJson(ev.payload['reply'])));
        }
        break;
      case 'reply_like_toggled':
        add(ReplyLikeToggled(
          id: ev.payload['id'].toString(),
          likes: ev.payload['likes'] as int? ?? 0,
        ));
        break;
      default:
        print('Unhandled RT event: ${ev.type}');
    }
  }

  @override
  Future<void> close() {
    _rtSub?.cancel();
    RealTimeService.dispose();
    _currentRoomType = null;
    _currentCommunityId = null;
    return super.close();
  }
}