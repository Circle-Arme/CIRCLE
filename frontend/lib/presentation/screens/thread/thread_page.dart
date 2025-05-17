// thread_page.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/services/thread_service.dart';
import 'package:frontend/core/services/UserProfileService.dart';
import 'package:frontend/core/services/organization_user_service.dart';
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
  int? _selectedMsgIndex;

  final DateFormat _timeFmt = DateFormat('h:mm a');

  @override
  void initState() {
    super.initState();
    _threadFuture = ThreadService.getThreadById(widget.threadId);
    _loadThread();
    _scrollController.addListener(() {
      setState(() {
        _showScrollToBottom =
            _scrollController.offset <
                _scrollController.position.maxScrollExtent - 50;
      });
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

    for (final r in _thread!.repliesTree) walk(r, 1);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _toggleLike() async {
    await ThreadService.toggleLike(widget.threadId);
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
  }

  Future<void> _toggleReplyLike(String id) async {
    await ThreadService.toggleReplyLike(id);
    setState(() {
      if (_likedReplies.contains(id)) {
        _replyLikesCount[id] = (_replyLikesCount[id] ?? 1) - 1;
        _likedReplies.remove(id);
      } else {
        _replyLikesCount[id] = (_replyLikesCount[id] ?? 0) + 1;
        _likedReplies.add(id);
      }
    });
  }

  Future<void> _pickReplyFile() async {
    final res = await FilePicker.platform.pickFiles();
    if (res != null) setState(() => _replyFile = res.files.first);
  }

  Future<void> _sendReply() async {
    final txt = _controller.text.trim();
    if (txt.isEmpty && _replyFile == null) return;
    await ThreadService.createReply(
      widget.threadId,
      txt,
      parentReplyId: _replyingTo?.id,
      file: _replyFile,
    );
    _controller.clear();
    _replyFile = null;
    _replyingTo = null;
    await _loadThread();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildMsgTile(int index, AppLocalizations loc) {
    final m = _messages[index];
    final isSelected = _selectedMsgIndex == index;
    return GestureDetector(
      onTap: () => setState(() =>
      _selectedMsgIndex = isSelected ? null : index),
      child: Stack(
        alignment: m.isThread
            ? Alignment.topRight
            : (m.isMe ? Alignment.topRight : Alignment.topLeft),
        clipBehavior: Clip.none,
        children: [
          _buildMsgContent(m, loc),
          if (isSelected) _buildActionBar(m, index),
        ],
      ),
    );
  }

  Widget _buildMsgContent(_Message m, AppLocalizations loc) {
    final timeText = _timeFmt.format(m.timestamp);
    final bool liked = m.isThread ? _isLiked : _likedReplies.contains(m.id);
    final int likes = m.isThread ? _likesCount : (_replyLikesCount[m.id] ?? 0);
    final Color primaryColor = const Color(0xFF326B80); // لون التطبيق الأساسي
    final Color bluishGray = const Color(0xFFE9F1F2); // رمادي مزرق للردود

    Future<void> _navigateToProfile() async {
      try {
        //final profile = await UserProfileService.fetchUserProfileById(m.userId);
        final profile = await OrganizationUserService.fetchUserProfileById(m.userId);
        final currentUserId = await AuthService.getCurrentUserId();
        final isOwnProfile = m.userId == currentUserId;

        Widget profilePage;
        if (profile.userType == 'organization') {
          profilePage = OrganizationProfilePage(
            profile: profile,
            isOwnProfile: isOwnProfile,
            isAdmin: false,
          );
        } else {
          profilePage = ProfilePage(
            profile: profile,
            isOwnProfile: isOwnProfile,
            isAdmin: false,
          );
        }

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => profilePage),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${loc.error}: $e')),
          );
        }
      }
    }

    if (m.isThread) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!m.isMe) // إخفاء الاسم إذا كان المرسل هو المستخدم
              Padding(
                padding: EdgeInsets.only(left: 8.w, bottom: 4.h),
                child: GestureDetector(
                  onTap: _navigateToProfile,
                  child: Text(
                    m.senderName.isNotEmpty ? m.senderName : loc.anonymous,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1.0.sw),
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.h),
                      if (m.jobType != null) ...[
                        Text('${loc.jobType}: ${m.jobType}', style: TextStyle(fontSize: 14.sp)),
                        SizedBox(height: 4.h),
                      ],
                      if (m.location != null) ...[
                        Text('${loc.location}: ${m.location}', style: TextStyle(fontSize: 14.sp)),
                        SizedBox(height: 4.h),
                      ],
                      if (m.salary != null) ...[
                        Text('${loc.salary}: ${m.salary}', style: TextStyle(fontSize: 14.sp)),
                        SizedBox(height: 8.h),
                      ],
                      Text(m.text, style: TextStyle(fontSize: 14.sp)),
                      SizedBox(height: 8.h),
                      if (m.jobLink != null) ...[
                        GestureDetector(
                          onTap: () => launchUrl(Uri.parse(m.jobLink!),
                              mode: LaunchMode.externalApplication),
                          child: Row(
                            children: [
                              Icon(Icons.link, size: 16.sp, color: Color(0xFF326B80)),
                              SizedBox(width: 6.w),
                              Text(
                                m.jobLinkType == 'direct' ? loc.directApplyLink : loc.externalJobPage,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  decoration: TextDecoration.underline,
                                  color: Color(0xFF326B80),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                      //Text(m.text, style: TextStyle(fontSize: 14.sp)),
                      if (m.fileUrl != null)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: _fileWidget(m.fileUrl!, loc),
                        ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Text(timeText, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
                          const Spacer(),
                          GestureDetector(
                            onTap: _toggleLike,
                            child: Row(
                              children: [
                                Icon(
                                  liked ? Icons.favorite : Icons.favorite_border,
                                  color: liked ? Color(0xFF326B80) : Colors.grey[600],
                                  size: 18.r,
                                ),
                                SizedBox(width: 4.w),
                                Text('$likes', style: TextStyle(fontSize: 12.sp)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final baseIndent = 20.w;
    final leftPad = 16.w + m.depth * baseIndent;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Padding(
        padding: EdgeInsets.only(left: leftPad, right: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!m.isMe) // إخفاء الاسم إذا كان المرسل هو المستخدم
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: GestureDetector(
                  onTap: _navigateToProfile,
                  child: Text(
                    m.senderName.isNotEmpty ? m.senderName : loc.anonymous,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 0.70.sw),
              child: Container(
                decoration: BoxDecoration(
                  color: m.isMe ? primaryColor : bluishGray,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(m.isMe ? 16 : 0),
                    bottomRight: Radius.circular(m.isMe ? 0 : 16),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (m.replyTo != null)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                        margin: EdgeInsets.only(bottom: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          m.replyTo!.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                    Text(
                      m.text,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: m.isMe ? Colors.white : primaryColor, // تغيير لون النص هنا
                      ),
                    ),
                    if (m.fileUrl != null)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: _fileWidget(m.fileUrl!, loc),

                      ),
                    SizedBox(height: 4.h),
                    Text(
                      timeText,
                      style: TextStyle(fontSize: 11.sp, color: m.isMe ? Colors.white70 : Colors.grey,),
                    ),
                  ],
                ),
              ),
            ),
            if (likes > 0)
              Padding(
                padding: EdgeInsets.only(top: 4.h, left: 4.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.thumb_up, size: 16.r, color: Color(0xFF326B80)),
                    SizedBox(width: 4.w),
                    Text('$likes', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar(_Message m, int index) {
    final isThread = m.isThread;
    return Positioned(
      right: m.isMe ? 4.w : null,
      left: m.isMe ? null : 4.w,
      top: 0,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.reply, size: 20, color: Color(0xFF326B80)),
              onPressed: () {
                setState(() {
                  _replyingTo = m;
                  _selectedMsgIndex = null;
                });
                _focusNode.requestFocus();
              },
            ),
            IconButton(
              icon: Icon(
                isThread
                    ? (_isLiked ? Icons.favorite : Icons.favorite_border)
                    : (_likedReplies.contains(m.id)
                    ? Icons.thumb_up
                    : Icons.thumb_up_off_alt),
                size: 20,
                color: isThread
                    ? (_isLiked ? Color(0xFF326B80) : Colors.grey)
                    : (_likedReplies.contains(m.id)
                    ? Color(0xFF326B80)
                    : Colors.grey),
              ),
              onPressed: () {
                setState(() {
                  if (isThread) {
                    _toggleLike();
                  } else {
                    _toggleReplyLike(m.id);
                  }
                  _selectedMsgIndex = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String n) {
    final color =
        Colors.primaries[n.hashCode % Colors.primaries.length].shade200;
    return CircleAvatar(
      radius: 16.r,
      backgroundColor: color,
      child: Text(
        n.isNotEmpty ? n[0].toUpperCase() : '?',
        style: TextStyle(
            fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  Widget _fileWidget(String url, AppLocalizations loc) {
    final img = ['.png', '.jpg', '.jpeg', '.gif']
        .any((ext) => url.toLowerCase().endsWith(ext));
    return InkWell(
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
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
                color: Color(0xFF326B80)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                url.split('/').last,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Color(0xFF326B80),
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
                          color: Color(0xFF326B80),
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
                        size: 20.r, color: Color(0xFF4B8697)),
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
                  icon:
                  Icon(Icons.attach_file, size: 24.r, color: Colors.grey),
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
                  backgroundColor: Color(0xFF326B80),
                  child: Icon(Icons.send, size: 20.r, color: Colors.white),
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
          icon: Icon(Icons.arrow_back, color: Color(0xFF326B80), size: 24.r),
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
              color: _isLiked ? Color(0xFF326B80) : Colors.grey,
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
                  itemBuilder: (_, i) => _buildMsgTile(i, loc),
                ),
              ),
              _input(loc),
            ],
          ),
          if (_showScrollToBottom)
            Positioned(
              right: 16.w, // نقل الزر إلى اليمين لتحسين تجربة المستخدم
              bottom: 80.h,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Color(0xFF326B80),
                onPressed: _scrollToBottom,
                child: Icon(Icons.arrow_downward, size: 20.r, color: Colors.white),
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
  final _Message? replyTo; // يدعم الاقتباس داخل الفقاعة
  final String? jobType;
  final String? location;
  final String? salary;
  final String? jobLink;
  final String? jobLinkType;

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
    this.replyTo,
    this.jobType,
    this.location,
    this.salary,
    this.jobLink,
    this.jobLinkType,

  });

  factory _Message.fromThread(ThreadModel t, String? currentUserId) =>
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
        jobType: t.jobType,
        location: t.location,
        salary: t.salary,
        jobLink: t.jobLink,
        jobLinkType: t.jobLinkType,
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
        replyTo: r.parentSnippet == null
            ? null
            : _Message(
          id:         r.parentSnippet!.id,
          userId:     r.parentSnippet!.creatorId,
          depth:      depth - 1,
          text:       r.parentSnippet!.text,
          senderName: r.parentSnippet!.creatorName,
          timestamp:  r.createdAt,      // لا أهمية كبيرة للوقت هنا
          isMe:       r.parentSnippet!.creatorId == currentUserId,
          isThread:   false,
          fileUrl:    r.parentSnippet!.file,
          isLiked:    false,
        ),
      );
}
