/// حالات (States) AlertBloc – تعتمد على Equatable.
/// ---------------------------------------------------------------------------
import 'package:equatable/equatable.dart';
import 'package:frontend/data/models/alert_model.dart';

abstract class AlertState extends Equatable {
  const AlertState();

  @override
  List<Object?> get props => [];
}

class AlertInitial extends AlertState {
  const AlertInitial();
}

class AlertLoading extends AlertState {
  const AlertLoading();
}

class AlertLoaded extends AlertState {
  final List<AlertModel> list;
  const AlertLoaded(this.list);

  @override
  List<Object?> get props => [list];
}

class AlertError extends AlertState {
  final String message;
  const AlertError(this.message);

  @override
  List<Object?> get props => [message];
}
