import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/data/models/thread_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_drawer.dart';

class ThreadPage extends StatefulWidget {
  final String threadId;

  const ThreadPage({Key? key, required this.threadId}) : super(key: key);

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  late Future<ThreadModel> _threadFuture;

  final List<_Message> messages = [
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
  void initState() {
    super.initState();
    _threadFuture = _fetchThreadById(widget.threadId);
  }

  Future<ThreadModel> _fetchThreadById(String threadId) async {
    await Future.delayed(const Duration(seconds: 1)); // تمثيل تأخير API

    // في المستقبل: استبدل هذا ب ThreadService.getThreadById(threadId)
    return ThreadModel(
      id: threadId,
      title: "استفسار حول المشروع",
      creatorName: "Abeer",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      repliesCount: messages.length,
      classification: "Q&A",
      content: "هذا محتوى تجريبي للثريد. كيف يمكنني تحسين هذا المشروع؟",
      tags: ["مشروع", "استفسار"],
      communityId: "community_1",
      isJobOpportunity: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppColors.primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        title: Text(loc.threadDetails),
      ),
      body: FutureBuilder<ThreadModel>(
        future: _threadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("حدث خطأ: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("الثريد غير موجود"));
          }

          final thread = snapshot.data!;
          return _buildThreadUI(thread, loc);
        },
      ),
    );
  }

  Widget _buildThreadUI(ThreadModel thread, AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade100, Colors.grey.shade200],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          _buildThreadHeader(thread, loc),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _buildMessageBubble(msg, loc);
              },
            ),
          ),
          _buildMessageInput(loc),
        ],
      ),
    );
  }

  Widget _buildThreadHeader(ThreadModel thread, AppLocalizations loc) {
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isQnA
                        ? [Colors.blueAccent, Colors.lightBlueAccent]
                        : [Colors.green, Colors.lightGreen],
                  ),
                ),
                child: Icon(
                  thread.isJobOpportunity
                      ? Icons.handshake
                      : isQnA
                      ? Icons.question_answer
                      : Icons.chat,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${loc.by} ${thread.creatorName}",
                  style: TextStyle(color: Colors.grey[700], fontSize: 14.sp)),
              Text(
                _formatDate(thread.createdAt),
                style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
              ),
            ],
          ),
          Divider(height: 24.h, color: Colors.grey[300], thickness: 1),
          Text(thread.content,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[800])),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            children: thread.tags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_Message msg, AppLocalizations loc) {
    final isMe = msg.isMe;
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isMe ? Colors.lightBlue.shade50 : Colors.white;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) _buildAvatar(msg.avatarUrl),
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
                      fontSize: 14.sp,
                      color: isMe
                          ? AppColors.primaryColor
                          : Colors.orangeAccent,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4.h, left: 8.w, right: 8.w),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: alignment,
                    children: [
                      Text(msg.text, style: TextStyle(fontSize: 14.sp)),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() => msg.isStarred = !msg.isStarred);
                            },
                            child: Icon(
                              msg.isStarred
                                  ? Icons.star
                                  : Icons.star_border,
                              color: msg.isStarred ? Colors.amber : Colors.grey,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _timeAgo(msg.timestamp, context),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) Padding(
            padding: EdgeInsets.only(left: 6.w),
            child: _buildAvatar(msg.avatarUrl),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? url) {
    return CircleAvatar(
      radius: 18.r,
      backgroundImage:
      url != null && url.isNotEmpty ? NetworkImage(url) : null,
      child: (url == null || url.isEmpty)
          ? const Icon(Icons.person)
          : null,
    );
  }

  Widget _buildMessageInput(AppLocalizations loc) {
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
                  decoration: InputDecoration(
                    hintText: loc.writeMessage,
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

  void _showAttachOptions() {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: Text(loc.image),
            onTap: () {
              Navigator.pop(ctx);
              // TODO: handle image
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: Text(loc.video),
            onTap: () {
              Navigator.pop(ctx);
              // TODO: handle video
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(
        _Message(
          text: text,
          senderName: "CurrentUser",
          timestamp: DateTime.now(),
          isMe: true,
          isStarred: false,
          avatarUrl: "https://i.pravatar.cc/150?img=5",
        ),
      );
    });

    _controller.clear();
    // TODO: send to backend
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.year}/${dateTime.month}/${dateTime.day}";
  }

  String _timeAgo(DateTime time, BuildContext context) {
    final diff = DateTime.now().difference(time);
    final loc = AppLocalizations.of(context)!;

    if (diff.inDays > 0) return "${diff.inDays} ${loc.day}";
    if (diff.inHours > 0) return "${diff.inHours} ${loc.hour}";
    if (diff.inMinutes > 0) return "${diff.inMinutes} ${loc.minute}";
    return loc.now;
  }
}

class _Message {
  String text;
  String senderName;
  DateTime timestamp;
  bool isMe;
  bool isStarred;
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
