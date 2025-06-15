/// الـ BLoC المسؤول عن منطق تنبيهات المستخدم.
/// ---------------------------------------------------------------------------
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/alert_service.dart';
import 'package:frontend/data/models/alert_model.dart';

import 'alert_event.dart';
import 'alert_state.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  AlertBloc() : super(const AlertInitial()) {
    /* ── Fetch ─────────────────────────────────────────── */
    on<FetchAlerts>((event, emit) async {
      emit(const AlertLoading());
      try {
        final alerts =
        await AlertService.fetchAlerts(unreadOnly: event.unreadOnly);
        emit(AlertLoaded(alerts));
      } catch (e) {
        emit(AlertError(e.toString()));
      }
    });

    /* ── Push / Realtime ───────────────────────────────── */
    on<NewAlertPushed>((event, emit) {
      final current = state is AlertLoaded ? (state as AlertLoaded).list : <AlertModel>[];
      emit(AlertLoaded([event.alert, ...current]));
    });

    /* ── Mark single ───────────────────────────────────── */
    on<MarkAlertRead>((event, emit) async {
      if (state is! AlertLoaded) return;
      final current = List<AlertModel>.from((state as AlertLoaded).list);

      try {
        await AlertService.markRead(event.id);
        final idx = current.indexWhere((a) => a.id == event.id);
        if (idx != -1) current[idx] = current[idx].copyWith(isRead: true);
        emit(AlertLoaded(current));
      } catch (e) {
        emit(AlertError('Failed to mark alert as read • $e'));
      }
    });

    /* ── Mark all ──────────────────────────────────────── */
    on<MarkAllRead>((event, emit) async {
      if (state is! AlertLoaded) return;
      var current = List<AlertModel>.from((state as AlertLoaded).list);

      try {
        await AlertService.markAllRead();
        current = [for (final a in current) a.copyWith(isRead: true)];
        emit(AlertLoaded(current));
      } catch (e) {
        emit(AlertError('Failed to mark all alerts as read • $e'));
      }
    });
    // داخل AlertBloc
    on<DeleteAlert>((event, emit) async {
      if (state is! AlertLoaded) return;
      final current = List<AlertModel>.from((state as AlertLoaded).list);

      try {
        await Future<void>.delayed(Duration(milliseconds: 200)); // مُجرّد انتظار رمزى
        current.removeWhere((a) => a.id == event.id);
        emit(AlertLoaded(current));
      } catch (e) {
        emit(AlertError('Failed to delete alert • $e'));
      }
    });

  }
}
