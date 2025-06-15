import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/core/services/community_service.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/presentation/screens/job_opportunities/job_opportunities_page.dart';
import '../../widgets/custom_drawer.dart';

class OrganizationRoomsPage extends StatelessWidget {
  final int communityId;

  const OrganizationRoomsPage({Key? key, required this.communityId}) : super(key: key);

  void _showLeaveDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          content: Text(
            loc.leaveCommunityConfirmation,
            style: TextStyle(fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
          contentPadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 8.h),
          actionsPadding: EdgeInsets.only(bottom: 8.h, right: 8.w, left: 8.w),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    loc.cancelThisRequest,
                    style: TextStyle(fontSize: 14.sp, color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await CommunityService.leaveCommunity(communityId);
                    await SharedPrefs.removeCommunityLevel(communityId);
                    Navigator.pushReplacementNamed(context, '/fields');
                  },
                  child: Text(
                    loc.leave,
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoomCard(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.shade400),
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Icon(Icons.handshake, size: 60.sp, color: const Color(0xFF326B80)),
          SizedBox(height: 16.h),
          Text(
            loc.jobOpportunities,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF326B80),
            ),
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JobOpportunitiesPage(communityId: communityId),
                ),
              );
            },
            child: Text(
              loc.enter,
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
          loc.selectRoom,
          style: TextStyle(
            color: const Color(0xFF326B80),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showLeaveDialog(context),
            icon: Icon(Icons.logout, color: Colors.red, size: 24.sp),
            tooltip: loc.leave,
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildRoomCard(context),
          ],
        ),
      ),
    );
  }
}
