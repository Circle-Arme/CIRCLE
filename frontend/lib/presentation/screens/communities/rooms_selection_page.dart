import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../widgets/custom_drawer.dart';
import '../discussion/discussion_room_page.dart';
import '../job_opportunities/job_opportunities_page.dart';

class RoomsSelectionPage extends StatelessWidget {
  final int communityId;

  const RoomsSelectionPage({Key? key, required this.communityId}) : super(key: key);

  Widget _buildRoomCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
          Icon(icon, size: 60.sp, color: const Color(0xFF326B80)),
          SizedBox(height: 16.h),
          Text(
            label,
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
            onPressed: onTap,
            child: Text(
              AppLocalizations.of(context)!.enter,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFFF5F9F9)),
            ),
          ),
        ],
      ),
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
          AppLocalizations.of(context)!.selectRoom,
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
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.createInspiringEnvironment,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: const Color(0xFF326B80),
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            _buildRoomCard(
              context: context,
              icon: Icons.groups,
              label: AppLocalizations.of(context)!.discussionRoom,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiscussionRoomPage(communityId: communityId),
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),
            _buildRoomCard(
              context: context,
              icon: Icons.handshake,
              label: AppLocalizations.of(context)!.jobOpportunities,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobOpportunitiesPage(communityId: communityId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
