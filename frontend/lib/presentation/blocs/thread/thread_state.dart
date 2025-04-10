import '../../../data/models/thread_model.dart';

abstract class ThreadState {}

class ThreadInitial extends ThreadState {}

class ThreadLoading extends ThreadState {}

class ThreadLoaded extends ThreadState {
  final List<ThreadModel> threads;

  ThreadLoaded(this.threads);
}

class ThreadError extends ThreadState {
  final String message;

  ThreadError(this.message);
}