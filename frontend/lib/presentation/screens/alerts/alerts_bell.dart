/// أيقونة الجرس في الـ AppBar مع عدّاد غير المقروء.
///
/// يُمرَّر لها الـ AlertBloc من أعلى (مثلا MultiBlocProvider).
/// ---------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/presentation/blocs/alert/alert_bloc.dart';
import 'package:frontend/presentation/blocs/alert/alert_state.dart';
import 'package:frontend/presentation/screens/alerts/alerts_page.dart';

class AlertsBell extends StatelessWidget {
  const AlertsBell({required this.bloc, super.key});
  final AlertBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertBloc, AlertState>(
      bloc: bloc,
      builder: (_, state) {
        final unread = state is AlertLoaded
            ? state.list.where((a) => !a.isRead).length
            : 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AlertsPage(bloc: bloc)),
              ),
            ),
            if (unread > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
