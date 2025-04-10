import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/core/services/CommunityService.dart';
import 'package:frontend/data/models/community_model.dart';
import '../../widgets/custom_drawer.dart';
import 'package:frontend/presentation/screens/communities/rooms_selection_page.dart';

class CommunitiesPage extends StatefulWidget {
  final String areaId;


  const CommunitiesPage({Key? key, required this.areaId}) : super(key: key);

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  late Future<List<CommunityModel>> futureCommunities;

  @override
  void initState() {
    super.initState();
    futureCommunities = CommunityService.fetchCommunities(widget.areaId);
  }

  void _showJoinDialog(BuildContext context, int communityId, String communityName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          AppLocalizations.of(context)!.joinCommunityConfirmation(communityName),
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              AppLocalizations.of(context)!.yes,
              style: TextStyle(color: const Color(0xFF326B80), fontSize: 14.sp),
            ),
            onPressed: () async {
              try {
                await CommunityService.joinCommunity(communityId);
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoomsSelectionPage(communityId: communityId),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.errorOccurred(e.toString()))),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityCard(BuildContext context, CommunityModel community) {
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
        ElevatedButton(
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
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFFF5F9F9)),
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
          icon: Icon(Icons.arrow_back, color: const Color(0xFF326B80), size: 24.sp),
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
            child: Icon(Icons.notifications_none, color: const Color(0xFF326B80), size: 24.sp),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: FutureBuilder<List<CommunityModel>>(
          future: futureCommunities,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.errorOccurred(snapshot.error.toString()),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(AppLocalizations.of(context)!.noCommunities));
            } else {
              final communities = snapshot.data!;
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
                      itemBuilder: (context, index) =>
                          _buildCommunityCard(context, communities[index]),
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
