import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TelegramStyleChannelPage extends StatelessWidget {
  const TelegramStyleChannelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // خلفية متدرجة
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFDAF9CB), // لون خلفي يشبه تيلجرام (أخضر خفيف)
              Color(0xFFE0F0EC), // لون ثاني فاتح
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // شريط علوي
              _buildHeader(context),
              // قائمة الرسائل
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 8.h),
                  itemCount: demoMessages.length,
                  itemBuilder: (context, index) {
                    final msg = demoMessages[index];
                    return _buildMessageCard(msg);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // شريط علوي يشبه تيلجرام
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // زر الرجوع
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 8.w),

                // صورة القناة
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.blue,
                  child: const Text("C"), // أول حرف مثلاً
                ),
                SizedBox(width: 10.w),

                // اسم القناة
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Circle",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "4 subscribers", // عدد المشتركين
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // أيقونات البحث والإعدادات
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                SizedBox(width: 8.w),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // رسالة بشكل بطاقة (كأنها منشور في قناة)
  Widget _buildMessageCard(MessageModel msg) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اسم المرسل (هنا Circle)
            Text(
              msg.sender,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),

            // نص الرسالة
            Text(
              msg.text,
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 6.h),

            // سطر التفاعلات وعدد المشاهدات والتوقيت
            Row(
              children: [
                // أيقونة قلب + العدد
                GestureDetector(
                  onTap: () {
                    // عند الضغط، زيدي عداد اللايك مثلاً
                    msg.loveCount++;
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: msg.loveCount > 0 ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "${msg.loveCount}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),

                // عين عدد المشاهدات
                Icon(
                  Icons.remove_red_eye,
                  color: Colors.grey[600],
                  size: 18,
                ),
                SizedBox(width: 2.w),
                Text(
                  "${msg.views}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                SizedBox(width: 8.w),

                // الوقت
                Text(
                  msg.time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),

            SizedBox(height: 6.h),

            // زر Leave a comment
            if (msg.commentsCount > 0)
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.blue),
                        SizedBox(width: 4.w),
                        Text(
                          "${msg.commentsCount} comments",
                          style: const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            if (msg.commentsCount == 0)
              GestureDetector(
                onTap: () {
                  // فتح صفحة التعليقات
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.blue,
                      size: 14,
                    ),
                    SizedBox(width: 4.w),
                    const Text(
                      "Leave a comment",
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// قائمة رسائل تجريبية
List<MessageModel> demoMessages = [
  MessageModel(
    sender: "Circle",
    text: "T",
    loveCount: 1,
    views: 9,
    time: "12:43 AM",
    commentsCount: 2,
  ),
  MessageModel(
    sender: "Circle",
    text: "همم",
    loveCount: 0,
    views: 9,
    time: "12:44 AM",
    commentsCount: 0,
  ),
  MessageModel(
    sender: "Circle",
    text: "كل الرسائل كدا ثريد",
    loveCount: 0,
    views: 9,
    time: "12:45 AM",
    commentsCount: 0,
  ),
  MessageModel(
    sender: "Circle",
    text: "كدا الثريد ينجح",
    loveCount: 0,
    views: 9,
    time: "12:46 AM",
    commentsCount: 1,
  ),
  MessageModel(
    sender: "Circle",
    text: "عادت",
    loveCount: 0,
    views: 9,
    time: "12:46 AM",
    commentsCount: 0,
  ),
  MessageModel(
    sender: "Circle",
    text: "قف",
    loveCount: 0,
    views: 9,
    time: "12:46 AM",
    commentsCount: 3,
  ),
];

// نموذج الرسالة التجريبي
class MessageModel {
  String sender;
  String text;
  int loveCount;
  int views;
  String time;
  int commentsCount;

  MessageModel({
    required this.sender,
    required this.text,
    required this.loveCount,
    required this.views,
    required this.time,
    required this.commentsCount,
  });
}