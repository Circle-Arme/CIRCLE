/// تعريف أحداث AlertBloc باستخدام Equatable لسهولة المقارنة.
/// ---------------------------------------------------------------------------
import 'package:equatable/equatable.dart';
import 'package:frontend/data/models/alert_model.dart';

abstract class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object?> get props => [];
}

/// جلب التنبيهات من الخادم.
class FetchAlerts extends AlertEvent {
  final bool unreadOnly;
  const FetchAlerts({this.unreadOnly = false});

  @override
  List<Object?> get props => [unreadOnly];
}

/// حدث دفع (Push) تنبيه جديد عبر WebSocket.
class NewAlertPushed extends AlertEvent {
  final AlertModel alert;
  const NewAlertPushed(this.alert);

  @override
  List<Object?> get props => [alert];
}

/// تعليم تنبيه واحد كمقروء.
class MarkAlertRead extends AlertEvent {
  final int id;
  const MarkAlertRead(this.id);

  @override
  List<Object?> get props => [id];
}

/// تعليم جميع التنبيهات كمقروءة.
class MarkAllRead extends AlertEvent {
  const MarkAllRead();
}
class DeleteAlert extends AlertEvent {
  final int id;
  const DeleteAlert(this.id);
}