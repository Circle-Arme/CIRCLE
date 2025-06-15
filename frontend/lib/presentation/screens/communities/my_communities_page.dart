import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/data/models/community_model.dart';
import 'package:frontend/presentation/blocs/alert/alert_bloc.dart';
import 'package:frontend/presentation/blocs/alert/alert_event.dart';
import 'package:frontend/presentation/screens/communities/organization_rooms_page.dart';
import 'package:frontend/presentation/screens/communities/rooms_selection_page.dart';
import 'package:frontend/presentation/screens/home/fields_page.dart';
import 'package:frontend/core/services/community_service.dart';
import 'package:frontend/presentation/screens/alerts/alerts_bell.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/services/realtime_service.dart';
import '../../widgets/custom_drawer.dart';

class MyCommunitiesPage extends StatefulWidget {
  const MyCommunitiesPage({super.key});

  @override
  State<MyCommunitiesPage> createState() => _MyCommunitiesPageState();
}

class _MyCommunitiesPageState extends State<MyCommunitiesPage> {
  List<CommunityModel>? _joinedCommunities;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _loadJoinedCommunities();
    _loadUserProfile();
    // تهيئة جلب التنبيهات
    context.read<AlertBloc>().add(FetchAlerts(unreadOnly: false));
    // الاتصال بقناة التنبيهات
    AuthService.getCurrentUserId().then((userId) {
      if (userId != null) {
        RealTimeService.connectAlerts(int.parse(userId));
      }
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await SharedPrefs.getUserProfile();
      setState(() {
        _userType = profile?.userType;
      });
    } catch (e) {
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
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF326B80), size: 24),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        centerTitle: true,
        title: const Text(
          "CIRCLE",
          style: TextStyle(
            color: Color(0xFF326B80),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // إضافة زر الجرس للتنبيهات
          AlertsBell(bloc: context.read<AlertBloc>()),
          SizedBox(width: 12.w),
        ],
      ),
      body: Stack(
        children: [
          _joinedCommunities == null
              ? const Center(child: CircularProgressIndicator())
              : _joinedCommunities!.isEmpty
              ? _buildEmptyState(context)
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.w, top: 16.h, bottom: 8.h),
                child: Text(
                  "${loc.yourCommunities}:",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF326B80),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _joinedCommunities!.length,
                  itemBuilder: (context, index) {
                    final community = _joinedCommunities![index];
                    return _buildJoinedCommunityCard(context, community);
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: FloatingActionButton.extended(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FieldsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Color(0xFF326B80)),
                label: Text(
                  loc.joinCommunity,
                  style: const TextStyle(color: Color(0xFF326B80)),
                ),
                backgroundColor: const Color(0xFFF5F9F9),
                foregroundColor: const Color(0xFF326B80),
                shape: const StadiumBorder(
                  side: BorderSide(color: Color(0xFF326B80)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinedCommunityCard(BuildContext context, CommunityModel community) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60.r,
          backgroundColor: const Color(0xFFD9E6EC),
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
            final route = (_userType == 'organization')
                ? OrganizationRoomsPage(communityId: community.id)
                : RoomsSelectionPage(communityId: community.id);

            Navigator.push(context, MaterialPageRoute(builder: (_) => route))
                .then((_) => _loadJoinedCommunities());
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
          ],
        ),
      ),
    );
  }
}