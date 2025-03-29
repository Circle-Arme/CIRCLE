// pages/thread_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/thread_model.dart.dart';
import '../theme/app_colors.dart';

class ThreadPage extends StatefulWidget {
  final ThreadModel thread;
  const ThreadPage({Key? key, required this.thread}) : super(key: key);

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  // قائمة تجريبية للرسائل
  List<_Message> messages = [
    _Message(
      text: "مرحبًا! لدي استفسار حول نقطة معينة في المشروع",
      senderName: "Abeer",
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isMe: false,
      isStarred: false,
      avatarUrl: "https://i.pravatar.cc/150?img=3",
    ),
    _Message(
      text: "أهلًا بك، تفضلي بالتفصيل أكثر",
      senderName: "Mayada",
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      isMe: true,
      isStarred: false,
      avatarUrl: "https://i.pravatar.cc/150?img=5",
    ),
  ];

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar بتنسيق عصري
      appBar: AppBar(
        title: Text(widget.thread.title),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        titleTextStyle: const TextStyle(
          color: AppColors.primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.grey.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // بطاقة معلومات الثريد
            _buildThreadHeader(widget.thread),
            // قائمة الرسائل
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),
            // شريط الإدخال
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  /// بطاقة عرض معلومات الثريد: العنوان، الكاتب، التاريخ، التصنيف، المحتوى، الوسوم...
  Widget _buildThreadHeader(ThreadModel thread) {
    final bool isQnA = thread.classification == 'Q&A';

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الثريد
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // أيقونة التصنيف
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isQnA
                        ? [Colors.blueAccent, Colors.lightBlueAccent]
                        : [Colors.green, Colors.lightGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  isQnA ? Icons.question_answer : Icons.chat,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  thread.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // الكاتب والتاريخ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "بقلم ${thread.creatorName}",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14.sp,
                ),
              ),
              Text(
                _formatDate(thread.createdAt),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          Divider(
            height: 24.h,
            color: Colors.grey[300],
            thickness: 1,
          ),
          // محتوى الثريد
          Text(
            thread.content,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[800]),
          ),
          SizedBox(height: 10.h),
          // الوسوم
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: thread.tags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// فقاعات الرسائل
  Widget _buildMessageBubble(_Message msg) {
    final isMe = msg.isMe;
    final bubbleColor = isMe ? Colors.lightBlue.shade50 : Colors.white;
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // صورة المرسل (إذا لم يكن المستخدم الحالي)
          if (!isMe) _buildAvatar(msg.avatarUrl),
          // فقاعة الرسالة
          Flexible(
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    msg.senderName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMe ? AppColors.primaryColor : Colors.orangeAccent,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 8.w, right: 8.w, top: 4.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: alignment,
                    children: [
                      Text(
                        msg.text,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // أيقونة النجمة
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                msg.isStarred = !msg.isStarred;
                              });
                            },
                            child: Icon(
                              msg.isStarred ? Icons.star : Icons.star_border,
                              color: msg.isStarred ? Colors.amber : Colors.grey,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // التوقيت
                          Text(
                            _timeAgo(msg.timestamp),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // صورة المرسل (إذا كان المستخدم الحالي)
          if (isMe)
            Padding(
              padding: EdgeInsets.only(left: 6.w),
              child: _buildAvatar(msg.avatarUrl),
            ),
        ],
      ),
    );
  }

  /// بناء الصورة الرمزية (Avatar)
  Widget _buildAvatar(String? url) {
    return CircleAvatar(
      radius: 18.r,
      backgroundImage:
      url != null && url.isNotEmpty ? NetworkImage(url) : null,
      child: (url == null || url.isEmpty) ? const Icon(Icons.person) : null,
    );
  }

  /// شريط إدخال الرسالة في الأسفل
  Widget _buildMessageInput() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.attach_file, color: AppColors.primaryColor),
              onPressed: _showAttachOptions,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "اكتب رسالة...",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: AppColors.primaryColor),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  /// عرض خيارات الإرفاق
  void _showAttachOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('صورة'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_collection),
                title: const Text('فيديو'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickVideo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.mic),
                title: const Text('تسجيل صوت'),
                onTap: () {
                  Navigator.pop(ctx);
                  _recordAudio();
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('ملف'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickDocument();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// إرسال الرسالة
  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final newMsg = _Message(
      text: text,
      senderName: "CurrentUser",
      timestamp: DateTime.now(),
      isMe: true,
      isStarred: false,
      avatarUrl: "https://i.pravatar.cc/150?img=5",
    );
    setState(() {
      messages.add(newMsg);
    });
    _controller.clear();
    // إرسال للباك اند...
  }

  /// أمثلة لتوابع الإرفاق
  void _pickImage() {
    // فتح ImagePicker...
  }

  void _pickVideo() {
    // فتح ImagePicker للفيديو...
  }

  void _recordAudio() {
    // بدء التسجيل...
  }

  void _pickDocument() {
    // اختيار ملف...
  }

  /// حساب فارق الوقت
  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) {
      return "${diff.inDays} يوم";
    } else if (diff.inHours > 0) {
      return "${diff.inHours} ساعة";
    } else if (diff.inMinutes > 0) {
      return "${diff.inMinutes} دقيقة";
    } else {
      return "الآن";
    }
  }

  /// تنسيق تاريخ بسيط
  String _formatDate(DateTime dateTime) {
    return "${dateTime.year}/${dateTime.month}/${dateTime.day}";
  }
}

// نموذج داخلي تجريبي للرسائل
class _Message {
  String text;
  String senderName;
  DateTime timestamp;
  bool isMe;      // هل المرسل هو المستخدم الحالي
  bool isStarred; // هل تم وضع نجمة
  String? avatarUrl;

  _Message({
    required this.text,
    required this.senderName,
    required this.timestamp,
    required this.isMe,
    required this.isStarred,
    this.avatarUrl,
  });
}
