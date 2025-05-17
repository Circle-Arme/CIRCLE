import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/data/models/thread_model.dart';
import '../theme/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class JobOpportunityCard extends StatelessWidget {
  final ThreadModel thread;
  final VoidCallback onTap;
  final bool isOwner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const JobOpportunityCard({
    Key? key,
    required this.thread,
    required this.onTap,
    required this.isOwner,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white,Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border(
            left: BorderSide(width: 6.w, color: AppColors.primaryColor),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColorLight2.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان + نوع الوظيفة
              Row(
                children: [
                  Icon(Icons.work, color: AppColors.primaryColor, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      thread.title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    thread.jobType ?? '',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (isOwner) ...[
                    SizedBox(width: 8.w),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 18.sp, color: Colors.grey[600]),
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'edit', child: Text(loc.edit)),
                        PopupMenuItem(value: 'delete', child: Text(loc.delete)),
                      ],
                    ),
                  ],
                ],
              ),
              SizedBox(height: 8.h),
              // المكان + الراتب
              Row(
                children: [
                  Icon(Icons.location_on, size: 16.sp, color:AppColors.primaryColor),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      thread.location ?? loc.notSpecified,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                    ),
                  ),
                  Icon(Icons.attach_money, size: 16.sp, color: AppColors.primaryColor),
                  SizedBox(width: 4.w),
                  Text(
                    thread.salary ?? loc.notSpecified,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                  ),
                ],
              ),
              if (thread.tags.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: thread.tags.map((tag) {
                    return GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${loc.tagClicked}: $tag")),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryColorLight1, AppColors.primaryColorLight2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              SizedBox(height: 12.h),
              // الرابط + الإحصائيات
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (thread.jobLink != null) {
                          launchUrl(
                            Uri.parse(thread.jobLink!),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.link, size: 16.sp, color: AppColors.primaryColor),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              thread.jobLinkType == 'direct' ? loc.directApplyLink : loc.externalJobPage,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.primaryColor,
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // التعليقات
                  Row(
                    children: [
                      Icon(Icons.message, size: 15.sp, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Text(
                        '${thread.repliesCount}',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  // الإعجابات
                  Row(
                    children: [
                      Icon(
                        thread.likedByMe ? Icons.favorite : Icons.favorite_border,
                        size: 15.sp,
                        color: thread.likedByMe ? AppColors.primaryColor : Colors.grey[600],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${thread.likesCount}',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                      ),
                    ],
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