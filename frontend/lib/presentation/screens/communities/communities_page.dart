import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/core/services/community_service.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/data/models/community_model.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/presentation/screens/communities/rooms_selection_page.dart';
import 'package:frontend/presentation/screens/communities/organization_rooms_page.dart';
import 'package:frontend/presentation/screens/job_opportunities/job_opportunities_page.dart';
import '../../widgets/custom_drawer.dart';

class CommunitiesPage extends StatefulWidget {
  final String areaId;


  const CommunitiesPage({Key? key, required this.areaId}) : super(key: key);

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  late Future<List<dynamic>> futureData;



  @override
  void initState() {
    super.initState();
    // نجلب من خلال Future.wait قائمتي المجتمعات والانضمامات
    futureData = Future.wait([
      CommunityService.fetchCommunities(widget.areaId),
      CommunityService.fetchMyCommunities(),
    ]);
  }

  /// دالة لجلب البيانات معاً (قائمة المجتمعات وقائمة الانضمامات)
  Future<List<dynamic>> _fetchData() async {
    final communities = await CommunityService.fetchCommunities(widget.areaId);
    final joined = await CommunityService.fetchMyCommunities();
    return [communities, joined];
  }

  /// دالة عرض حوار الانضمام مع اختيار المستوى
  void _showJoinDialog(BuildContext context, int communityId, String communityName) async {
    final userProfile = await SharedPrefs.getUserProfile();

    // اسماء المفاتيح
    final loc = AppLocalizations.of(context)!;
    final titleText = loc.titleJoinCommunity(communityName);

    // إذا كان المستخدم من نوع "organization"
    if (userProfile?.userType == 'organization') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(titleText, textAlign: TextAlign.center),
          content: Text(
            loc.joinCommunityConfirmationSimple, // مثال: "هل ترغب بالانضمام إلى هذا المجتمع؟"
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _joinCommunity(context, communityId, 'job_only');
              },
              child: Text(loc.btnJoin, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF326B80))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.btnCancel),
            ),
          ],
        ),
      );
      return;
    }

    // للمستخدم العادي: حوار اختيار المستوى
    showDialog(
      context: context,
      builder: (_) {
        String? _selectedLevel;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            title: Text(titleText, textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.subtitleChooseLevel,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),

                RadioListTile<String>(
                  value: 'beginner',
                  groupValue: _selectedLevel,
                  title: Text(loc.levelGeneral),
                  onChanged: (v) => setState(() => _selectedLevel = v),
                ),
                RadioListTile<String>(
                  value: 'advanced',
                  groupValue: _selectedLevel,
                  title: Text(loc.levelAdvanced),
                  onChanged: (v) => setState(() => _selectedLevel = v),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.btnCancel),
              ),
              ElevatedButton(
                onPressed: _selectedLevel == null
                    ? null
                    : () {
                  Navigator.pop(context);
                  if (_selectedLevel == 'advanced') {
                  // هنا نظهر حوار التأكيد الإضافي بدل الانضمام مباشرة
                  _showAdvancedConfirmationDialog(context, communityId);
                  } else {
                  // للمستوى العام نكمل مباشرة
                  _joinCommunity(context, communityId, _selectedLevel!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  backgroundColor: const Color(0xFF326B80),
                ),
                child: Text(
                  loc.btnJoin,
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFFF5F9F9)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  /// حوار تأكيد إضافي عند اختيار المستوى المتقدم (للمستخدم العادي)
  void _showAdvancedConfirmationDialog(BuildContext context, int communityId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: Text(
            AppLocalizations.of(context)!.joinGeneralLevel,
            style: TextStyle(fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _joinCommunity(context, communityId, 'both');
              },
              child: Text(
              AppLocalizations.of(context)!.yes,
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF326B80)),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _joinCommunity(context, communityId, 'advanced');
              },
              child: Text(
                AppLocalizations.of(context)!.advancedOnly,
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF326B80)),
              ),
            ),
          ],
        );
      },
    );
  }

  /// دالة مساعدة لتنفيذ طلب الانضمام للمجتمع
  Future<void> _joinCommunity(BuildContext ctx, int communityId, String level,) async {
    try {
      final nav = Navigator.of(ctx, rootNavigator: true);
      final userProfile = await SharedPrefs.getUserProfile();
      final userType = userProfile?.userType;

      if (userType == 'organization') {
        await CommunityService.joinCommunity(communityId, level: 'job_only');
        nav.pushReplacement(
          MaterialPageRoute(
            builder: (_) => OrganizationRoomsPage(communityId: communityId),
          ),
        );
        return;                         // ⛔ مهم لإيقاف المتابعة
      }

      await CommunityService.joinCommunity(communityId, level: level);
      nav.pushReplacement(
        MaterialPageRoute(
          builder: (_) => RoomsSelectionPage(
            communityId: communityId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(ctx)!.errorOccurred(e.toString()))),
      );
    }
  }


  /// دالة لبناء بطاقة عرض المجتمع مع التحقق من حالة الانضمام
  Widget _buildCommunityCard(
      BuildContext context,
      CommunityModel community,
      List<CommunityModel> joinedCommunities,
      ) {
    // التحقق من وجود هذا المجتمع في قائمة المجتمعات التي انضم إليها المستخدم
    final isJoined = joinedCommunities.any((joined) => joined.id == community.id);

    return Column(
      children: [
        CircleAvatar(
          radius: 60.r,
          backgroundImage: community.image != null
              ? NetworkImage(community.image!)
              : null,
          backgroundColor: const Color(0xFFD9E6EC),
        ),
        SizedBox(height: 8.h),
        Text(
          community.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF326B80),
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),
        isJoined
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
            SizedBox(width: 6.w),
            Text(
              "Already joined",
              style: TextStyle(color: Colors.green, fontSize: 14.sp),
            ),
          ],
        )
            : ElevatedButton(
          onPressed: () => _showJoinDialog(context, community.id, community.name),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF326B80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          ),
          child: Text(
            AppLocalizations.of(context)!.join,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFFF5F9F9),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Divider(
            color: Colors.orange,
            thickness: 2,
            indent: 50.w,
            endIndent: 50.w,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F9),
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF326B80),
            size: 24.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.communities,
          style: TextStyle(
            color: const Color(0xFF326B80),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Icon(
              Icons.notifications_none,
              color: const Color(0xFF326B80),
              size: 24.sp,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: FutureBuilder<List<dynamic>>(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.errorOccurred(snapshot.error.toString()),
                ),
              );
            } else if (!snapshot.hasData || (snapshot.data![0] as List).isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)!.noCommunities),
              );
            } else {
              final communities = snapshot.data![0] as List<CommunityModel>;
              final joined = snapshot.data![1] as List<CommunityModel>;

              return Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.joinCommunityPrompt,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF326B80),
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  Expanded(
                    child: ListView.builder(
                      itemCount: communities.length,
                      itemBuilder: (context, index) => _buildCommunityCard(
                        context,
                        communities[index],
                        joined,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
