// lib/presentation/screens/alerts/alerts_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:frontend/data/models/alert_model.dart';
import 'package:frontend/presentation/blocs/alert/alert_bloc.dart';
import 'package:frontend/presentation/blocs/alert/alert_event.dart';
import 'package:frontend/presentation/blocs/alert/alert_state.dart';
import 'package:frontend/core/services/thread_service.dart';
import '../../theme/app_colors.dart';
import '../thread/thread_page.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({required this.bloc, super.key});
  final AlertBloc bloc;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: Text(
          loc.notifications,
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      /* ـــــــــــــــــــــــــ Body ـــــــــــــــــــــــــ */
      body: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundLight, AppColors.backgroundDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocBuilder<AlertBloc, AlertState>(
          bloc: bloc,
          builder: (_, state) {
            if (state is AlertLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AlertError) {
              return Center(child: Text(state.message));
            }

            if (state is! AlertLoaded || state.list.isEmpty) {
              return _EmptyState(loc: loc);
            }

            final alerts = state.list;

            return RefreshIndicator(
              onRefresh: () async => bloc.add(const FetchAlerts()),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 80), // مكان الـ FAB
                itemCount: alerts.length,
                itemBuilder: (context, i) {
                  final a = alerts[i];
                  return _AlertTile(
                    alert: a,
                    onTap: () => _openAlert(context, a),
                    onMarkRead: () => bloc.add(MarkAlertRead(a.id)),
                    bloc: bloc,
                  );
                },
              ),
            );
          },
        ),
      ),

      /* ــ FAB: Mark-All-Read ــ */
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'markAllRead',
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(
          Icons.check,
          color: Colors.white,
        ),
        label: Text(
          AppLocalizations.of(context)!.markAllRead,
          style: const TextStyle(color: Colors.white), // ✨ جعل النص أبيض
        ),
        onPressed: () => bloc.add(const MarkAllRead()),
      ),

    );
  }

  /* ——— Helpers ——— */
  void _openAlert(BuildContext context, AlertModel a) async {
    final loc = AppLocalizations.of(context)!;
    bloc.add(MarkAlertRead(a.id));

    if (a.objectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.noThreadId)),
      );
      return;
    }

    try {
      final thread = await ThreadService.getThreadById(a.objectId!.toString());
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ThreadDetailPage(
            threadId: thread.id,
            communityId: int.parse(thread.communityId),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${loc.error}: $e'),
        backgroundColor: Colors.red.withOpacity(0.8),
      ));
    }
  }
}

/* ـــــــــــــــــــــــــ Widget: تنبيه واحد ـــــــــــــــــــــــــ */
class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.alert,
    required this.onTap,
    required this.onMarkRead,
    required this.bloc,
  });

  final AlertModel alert;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;
  final AlertBloc bloc;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    final bgColor =
    alert.isRead ? Colors.white : Colors.orange.withOpacity(.08);

    return Slidable(
      key: ValueKey(alert.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: .25,
        children: [
          SlidableAction(
            onPressed: (_) => bloc.add(DeleteAlert(alert.id)),
            icon: Icons.delete,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: primary.withOpacity(.2),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: const Offset(0, 1),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* —ــ Icon —ــ */
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withOpacity(.12),
                ),
                child: _iconForType(alert.type),
              ),

              const SizedBox(width: 12),

              /* —ــ Message & time —ــ */
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight:
                        alert.isRead ? FontWeight.normal : FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeago.format(alert.createdAt, locale: 'en'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              /* —ــ Mark Single Read —ــ */
              if (!alert.isRead)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline,
                      color: AppColors.primaryColor),
                  onPressed: onMarkRead,
                  tooltip: 'Mark as read',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Icon _iconForType(AlertType t) {
    switch (t) {
      case AlertType.reply:
        return const Icon(Icons.chat_bubble, color: AppColors.primaryColor);
      case AlertType.job:
        return const Icon(Icons.work, color: AppColors.primaryColor);
      case AlertType.warn:
        return const Icon(Icons.warning, color: Colors.red);
      case AlertType.info:
        return const Icon(Icons.forum, color: AppColors.primaryColor);
      default:
        return const Icon(Icons.notifications, color: AppColors.primaryColor);
    }
  }
}

/* ـــــــــــــــــــــــــ Widget: لا توجد تنبيهات ـــــــــــــــــــــــــ */
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.loc});
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off,
              size: 72, color: AppColors.textSecondary.withOpacity(.4)),
          SizedBox(height: 20.h),
          Text(
            loc.noNotifications,
            style: TextStyle(
              fontSize: 18.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
