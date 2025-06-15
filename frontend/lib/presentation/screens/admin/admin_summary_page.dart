// lib/presentation/admin_dashboard/admin_summary_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:frontend/core/services/admin_summary_service.dart';

const _primaryColor = Color(0xFF326B80);

class AdminSummaryPage extends StatefulWidget {
  const AdminSummaryPage({super.key});

  @override
  State<AdminSummaryPage> createState() => _AdminSummaryPageState();
}

class _AdminSummaryPageState extends State<AdminSummaryPage> {
  late Future<SummaryData> _future;

  @override
  void initState() {
    super.initState();
    _future = AdminSummaryService.fetchSummary();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryColor,
        title: Text(loc.summary, style: const TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<SummaryData>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('${loc.errorPrefix}: ${snap.error}'));
          }

          final data = snap.data!;
          final stats = data.stats;
          final recent = data.recent;

          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ─── البطاقات المختصرة ───
                Text(loc.quickStats,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: _primaryColor)),
                SizedBox(height: 12.h),

                Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: [
                    _statChip(Icons.group, loc.totalUsers, stats.totalUsers),
                    _statChip(Icons.apartment, loc.totalOrganizations,
                        stats.totalOrganizations),
                    _statChip(Icons.security, loc.totalAdmins, stats.totalAdmins),
                    _statChip(Icons.category, loc.totalFields, stats.totalFields),
                    _statChip(Icons.groups, loc.totalCommunities,
                        stats.totalCommunities),
                    _statChip(Icons.forum, loc.totalThreads, stats.totalThreads),
                    _statChip(Icons.comment, loc.totalReplies, stats.totalReplies),
                  ],
                ),

                SizedBox(height: 24.h),

                /// ─── أحدث الأحداث ───
                Text(loc.recentActions,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: _primaryColor)),
                SizedBox(height: 12.h),
                Expanded(
                  child: recent.isEmpty
                      ? Center(child: Text(loc.noData))
                      : ListView.separated(
                    itemCount: recent.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade300),
                    itemBuilder: (_, i) {
                      final r = recent[i];
                      final icon = switch (r.type) {
                        'user'      => Icons.person,
                        'community' => Icons.groups,
                        'thread'    => Icons.forum,
                        _           => Icons.help
                      };
                      return ListTile(
                        leading:
                        Icon(icon, color: _primaryColor, size: 28.sp),
                        title: Text(r.title),
                        subtitle: Text(
                            '${r.type} • ${r.when.toLocal().toString().substring(0, 19)}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statChip(IconData icon, String label, int value) {
    return Container(
      width: 150.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _primaryColor, size: 28.sp),
          SizedBox(height: 6.h),
          Text('$value',
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor)),
          SizedBox(height: 4.h),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
