// presentation/widgets/modern_thread_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/data/models/thread_model.dart';
import '../theme/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ModernThreadCard extends StatelessWidget {
  final ThreadModel thread;
  final VoidCallback onTap;

  const ModernThreadCard({
    Key? key,
    required this.thread,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final bool isQnA = thread.classification == 'Q&A';
    final bool isJob = thread.isJobOpportunity;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isJob
                        ? [Colors.orangeAccent, Colors.deepOrangeAccent]
                        : isQnA
                        ? [Colors.blueAccent, Colors.lightBlueAccent]
                        : [Colors.green, Colors.lightGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.all(12.w),
                child: Icon(
                  isJob
                      ? Icons.work
                      : isQnA
                      ? Icons.question_answer
                      : Icons.chat,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "${loc.by} ${thread.creatorName}",
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    ),
                    if (thread.tags.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 6.w,
                        children: thread.tags.map((tag) {
                          return Chip(
                            label: Text(tag, style: TextStyle(fontSize: 12.sp)),
                            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(Icons.message, size: 18.sp, color: Colors.grey[600]),
                  SizedBox(height: 4.h),
                  Text(
                    "${thread.repliesCount}",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}