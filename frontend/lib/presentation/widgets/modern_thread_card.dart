import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/data/models/thread_model.dart';
import '../theme/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ModernThreadCard extends StatelessWidget {
  final ThreadModel thread;
  final VoidCallback onTap;
  final bool isOwner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ModernThreadCard({
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
    final bool isQnA = thread.classification == 'Q&A';
    final bool isJob = thread.isJobOpportunity;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
              // القسم العلوي: الأيقونة، العنوان، الاسم، التاغات
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الأيقونة الدائرية
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isJob
                            ? [AppColors.primaryColorLight1, AppColors.primaryColorLight2]
                            : isQnA
                            ? [AppColors.primaryColor, AppColors.primaryColor]
                            : [AppColors.primaryColor, AppColors.primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.all(10.w),
                    child: Icon(
                      isJob
                          ? Icons.work
                          : isQnA
                          ? Icons.question_answer
                          : Icons.chat,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // المحتوى الرئيسي
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // العنوان
                        Text(
                          thread.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        // اسم المستخدم
                        Text(
                          "${loc.by} ${thread.creatorName}",
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                        ),
                        if (thread.tags.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          // التاغات
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
                                      colors: isJob
                                          ? [AppColors.primaryColorLight1, AppColors.primaryColorLight2]
                                          : isQnA
                                          ? [AppColors.primaryColor, AppColors.primaryColor]
                                          : [AppColors.primaryColor, AppColors.primaryColor],
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
                                      color: isJob
                                          ? Colors.orange.shade900
                                          : isQnA
                                          ? Colors.white
                                          : Colors.green.shade900,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // قائمة الخيارات للمالك
                  if (isOwner)
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
              ),
              SizedBox(height: 12.h),
              // القسم السفلي: الإحصائيات (التعليقات والإعجابات)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(),
                  // التعليقات
                  Row(
                    children: [
                      Icon(
                        Icons.message,
                        size: 15.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "${thread.repliesCount}",
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
                        "${thread.likesCount}",
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