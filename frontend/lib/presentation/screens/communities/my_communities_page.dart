import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/data/models/user_profile_model.dart';
import 'package:frontend/data/models/area_model.dart';
import 'package:frontend/data/models/community_model.dart';
import 'package:frontend/presentation/screens/communities/rooms_selection_page.dart';
import 'package:frontend/presentation/screens/communities/communities_page.dart';
import 'package:frontend/presentation/screens/home/fields_page.dart';
import 'package:frontend/core/services/CommunityService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/communities/organization_rooms_page.dart';
import 'package:frontend/presentation/screens/job_opportunities/job_opportunities_page.dart';
import '../../widgets/custom_drawer.dart';

class MyCommunitiesPage extends StatefulWidget {
  const MyCommunitiesPage({super.key});

  @override
  State<MyCommunitiesPage> createState() => _MyCommunitiesPageState();
}

class _MyCommunitiesPageState extends State<MyCommunitiesPage> {
  List<CommunityModel>? _joinedCommunities;
  String? _userType; // لتخزين نوع المستخدم (organization أو normal)

  @override
  void initState() {
    super.initState();
    _loadJoinedCommunities();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await SharedPrefs.getUserProfile();
      setState(() {
        _userType = profile?.userType;
      });
    } catch (e) {
      // في حال حدوث خطأ يمكن طباعته أو إظهاره
      print("Error loading user profile: $e");
    }
  }

  Future<void> _loadJoinedCommunities() async {
    try {
      final communities = await CommunityService.fetchMyCommunities();
      setState(() {
        _joinedCommunities = communities;
      });
    } catch (e) {
      // يمكنك عرض رسالة خطأ هنا
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F9),
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF326B80), size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          loc.communities,
          style: TextStyle(
            color: const Color(0xFF326B80),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          Icon(Icons.notifications_none, color: const Color(0xFF326B80), size: 24.sp),
          SizedBox(width: 12.w),
        ],
      ),
      body: _joinedCommunities == null
          ? const Center(child: CircularProgressIndicator())
          : _joinedCommunities!.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _joinedCommunities!.length,
        itemBuilder: (context, index) {
          final community = _joinedCommunities![index];
          return _buildJoinedCommunityCard(context, community);
        },
      ),
    );
  }

  Widget _buildJoinedCommunityCard(BuildContext context, CommunityModel community) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60.r,
          backgroundColor: const Color(0xFFD9E6EC),
          // يمكنك إضافة صورة إذا كانت متوفرة ضمن community.image
          backgroundImage: community.image != null ? NetworkImage(community.image!) : null,
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
        ElevatedButton(
          onPressed: () {
            if (_userType == 'organization') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrganizationRoomsPage(communityId: community.id),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomsSelectionPage(
                    communityId: community.id,
                    userLevel: community.level ?? 'beginner',
                  ),
                ),
              );
            }
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF326B80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          ),
          child: const Icon(Icons.arrow_forward, color: Colors.white),
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

  Widget _buildEmptyState(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.noCommunitiesJoinedPrompt,
              style: TextStyle(color: Colors.red, fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () async {
                final areaId = await SharedPrefs.getLastSelectedAreaId();

                if (areaId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommunitiesPage(areaId: areaId),
                    ),
                  );
                } else {
                  // إذا لم يُحدد المستخدم مجال، فانتقل إلى صفحة المجالات
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FieldsPage(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF326B80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
