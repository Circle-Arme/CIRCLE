import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/services/thread_service.dart';
import 'package:frontend/core/services/UserProfileService.dart';
import 'package:frontend/data/models/thread_model.dart';
import 'package:frontend/presentation/screens/profile/user_profile_page.dart';
import 'package:frontend/presentation/screens/profile/organization_profile_page.dart';

class ThreadPage extends StatefulWidget {
  final String threadId;
  const ThreadPage({Key? key, required this.threadId}) : super(key: key);

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  late Future<ThreadModel> _threadFuture;
  ThreadModel? _thread;

  final List<_Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _isLiked = false;
  int _likesCount = 0;
  String? _currentUserId;

  final Map<String, int> _replyLikesCount = {};
  final Set<String> _likedReplies = {};

  _Message? _replyingTo;
  PlatformFile? _replyFile;

  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _loadThread();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final offset = _scrollController.offset;
    setState(() {
      // نظهر السهم إذا لم نكن في الأسفل
      _showScrollToBottom =
          offset < _scrollController.position.maxScrollExtent - 200;
    });
  }

  Future<void> _loadThread() async {
    _currentUserId = await AuthService.getCurrentUserId();
    _thread = await ThreadService.getThreadById(widget.threadId);
    _threadFuture = Future.value(_thread);
    _likesCount = _thread!.likesCount;
    _isLiked = _thread!.likedByMe;

    _messages
      ..clear()
      ..add(_Message.fromThread(_thread!, _currentUserId));

    void walk(ApiReply r, int depth) {
      _replyLikesCount[r.id] = r.likesCount;
      if (r.isLiked) _likedReplies.add(r.id);
      _messages.add(_Message.fromApi(r, depth, _currentUserId));
      for (final c in r.children) walk(c, depth + 1);
    }

    for (final r in _thread!.repliesTree) {
      walk(r, 1);
    }

    setState(() {});
  }

  Future<void> _toggleLike() async {
    await ThreadService.toggleLike(widget.threadId);
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
  }

  Future<void> _toggleReplyLike(String replyId) async {
    try {
      await ThreadService.toggleReplyLike(replyId);
      setState(() {
        if (_likedReplies.contains(replyId)) {
          _replyLikesCount[replyId] = (_replyLikesCount[replyId] ?? 1) - 1;
          _likedReplies.remove(replyId);
        } else {
          _replyLikesCount[replyId] = (_replyLikesCount[replyId] ?? 0) + 1;
          _likedReplies.add(replyId);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
    }
  }

  Future<void> _pickReplyFile() async {
    final res = await FilePicker.platform.pickFiles();
    if (res != null) setState(() => _replyFile = res.files.first);
  }

  Future<void> _sendReply() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _replyFile == null) return;

    final parentId = _replyingTo?.id;
    await ThreadService.createReply(
      widget.threadId,
      text,
      parentReplyId: parentId,
      file: _replyFile,
    );

    setState(() {
      _controller.clear();
      _replyFile = null;
      _replyingTo = null;
    });
    await _loadThread();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildMsg(_Message m, AppLocalizations loc) {
    // الثريد الرئيسي
    if (m.isThread) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r)),
          elevation: 3,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _avatar(m.senderName),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                        );
                        try {
                          final profile = await UserProfileService
                              .fetchUserProfileById(m.userId);
                          Navigator.pop(context);
                          if (profile.userType == 'organization') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrganizationProfilePage(
                                  profile: profile,
                                  isOwnProfile: m.isMe,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfilePage(
                                  profile: profile,
                                  isOwnProfile: m.isMe,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('فشل جلب البروفايل: $e')),
                          );
                        }
                      },
                      child: Text(
                        m.senderName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                          color:
                          m.isMe ? Colors.blue.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  m.text,
                  style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                ),
                if (m.fileUrl != null)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: _fileWidget(m.fileUrl!, loc),
                  ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Text(
                      timeago.format(
                        m.timestamp,
                        locale:
                        Localizations.localeOf(context).languageCode,
                      ),
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            _isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18.r,
                            color:
                            _isLiked ? Colors.red : Colors.grey[600],
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '$_likesCount',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // الردود
    final double baseIndent = 24.w;
    return Stack(
      children: [
        if (m.depth > 0)
          Positioned(
            left: 16.w + (m.depth - 1) * baseIndent + 8.w,
            top: 0,
            bottom: 0,
            width: 2.w,
            child: Container(color: Colors.grey.shade300),
          ),
        Padding(
          padding: EdgeInsets.only(
            left: 16.w + m.depth * baseIndent,
            right: 16.w,
            top: 8.h,
            bottom: 8.h,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: m.isMe
                  ? Colors.blue.shade100
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _avatar(m.senderName),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                          );
                          try {
                            final profile = await UserProfileService
                                .fetchUserProfileById(m.userId);
                            Navigator.pop(context);
                            if (profile.userType == 'organization') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrganizationProfilePage(
                                        profile: profile,
                                        isOwnProfile: m.isMe,
                                      ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfilePage(
                                    profile: profile,
                                    isOwnProfile: m.isMe,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                  Text('فشل جلب البروفايل: $e')),
                            );
                          }
                        },
                        child: Text(
                          m.senderName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                            color: m.isMe
                                ? Colors.blue.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      timeago.format(
                        m.timestamp,
                        locale:
                        Localizations.localeOf(context).languageCode,
                      ),
                      style: TextStyle(
                          fontSize: 10.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (m.text.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      m.text,
                      style: TextStyle(
                          fontSize: 14.sp, color: Colors.black87),
                    ),
                  ),
                if (m.fileUrl != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: _fileWidget(m.fileUrl!, loc),
                  ),
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _toggleReplyLike(m.id),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              size: 18.r,
                              color: _likedReplies.contains(m.id)
                                  ? Colors.orange.shade700
                                  : Colors.grey[600],
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${_replyLikesCount[m.id] ?? 0}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      GestureDetector(
                        onTap: () {
                          setState(() => _replyingTo = m);
                          _focusNode.requestFocus();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            loc.reply,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatar(String n) {
    final color = Colors.primaries[n.hashCode % Colors.primaries.length].shade200;
    return CircleAvatar(
      radius: 16.r,
      backgroundColor: color,
      child: Text(
        n.isNotEmpty ? n[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _fileWidget(String url, AppLocalizations loc) {
    final img = ['.png', '.jpg', '.jpeg', '.gif']
        .any((ext) => url.toLowerCase().endsWith(ext));
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication),
      child: img
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.network(
          url,
          height: 140.h,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 140.h,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      )
          : Container(
        padding: EdgeInsets.all(8.w),
        margin: EdgeInsets.only(top: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.insert_drive_file,
                color: Colors.blue.shade700),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                url.split('/').last,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.blue.shade700,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(AppLocalizations loc) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyingTo != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${loc.replyingTo} ${_replyingTo!.senderName}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          size: 20.r, color: Colors.grey),
                      onPressed: () => setState(() => _replyingTo = null),
                    ),
                  ],
                ),
              ),
            if (_replyFile != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_file,
                        size: 20.r, color: Colors.green.shade700),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _replyFile!.name,
                        style: TextStyle(fontSize: 13.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          size: 20.r, color: Colors.grey),
                      onPressed: () => setState(() => _replyFile = null),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file,
                      size: 24.r, color: Colors.grey[700]),
                  onPressed: _pickReplyFile,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: loc.writeMessage,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                      ),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                FloatingActionButton(
                  mini: true,
                  onPressed: _sendReply,
                  backgroundColor: Colors.blue,
                  child:
                  Icon(Icons.send, size: 20.r, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue, size: 24.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: FutureBuilder<ThreadModel>(
          future: _threadFuture,
          builder: (_, snap) => Text(
            snap.hasData ? snap.data!.title : loc.threadDetails,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.grey,
              size: 24.r,
            ),
            onPressed: _toggleLike,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Center(
              child: Text(
                '$_likesCount',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) => _buildMsg(_messages[i], loc),
                ),
              ),
              _input(loc),
            ],
          ),
          if (_showScrollToBottom)
            Positioned(
              left: 16.w,
              top: MediaQuery.of(context).padding.top +
                  kToolbarHeight +
                  8.h,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.blue,
                onPressed: _scrollToBottom,
                child: Icon(Icons.arrow_downward,
                    size: 20.r, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _Message {
  final String id;
  final String userId;
  final int depth;
  final String text;
  final String senderName;
  final DateTime timestamp;
  final bool isMe;
  final bool isThread;
  final String? fileUrl;
  final bool isLiked;

  _Message({
    required this.id,
    required this.userId,
    required this.depth,
    required this.text,
    required this.senderName,
    required this.timestamp,
    required this.isMe,
    required this.isThread,
    this.fileUrl,
    required this.isLiked,
  });

  factory _Message.fromThread(
      ThreadModel t, String? currentUserId) =>
      _Message(
        id: t.id,
        userId: t.creatorId,
        depth: 0,
        text: t.details,
        senderName: t.creatorName,
        timestamp: t.createdAt,
        isMe: t.creatorId == currentUserId,
        isThread: true,
        fileUrl: t.fileAttachment,
        isLiked: t.likedByMe,
      );

  factory _Message.fromApi(
      ApiReply r, int depth, String? currentUserId) =>
      _Message(
        id: r.id,
        userId: r.creatorId,
        depth: depth,
        text: r.text,
        senderName: r.creatorName,
        timestamp: r.createdAt,
        isMe: r.creatorId == currentUserId,
        isThread: false,
        fileUrl: r.file,
        isLiked: r.isLiked,
      );
}
