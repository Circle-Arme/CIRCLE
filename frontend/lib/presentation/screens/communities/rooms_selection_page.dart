import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/core/services/CommunityService.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/data/models/user_profile_model.dart';
import 'package:frontend/presentation/widgets/custom_drawer.dart';
import 'package:frontend/presentation/screens/discussion/discussion_room_page.dart';
import 'package:frontend/presentation/screens/job_opportunities/job_opportunities_page.dart';
import 'package:frontend/presentation/screens/advanced_discussion/advanced_discussion_room_page.dart';

class RoomsSelectionPage extends StatelessWidget {
  final int communityId;
  final String userLevel;

  const RoomsSelectionPage({
    Key? key,
    required this.communityId,
    required this.userLevel,
  }) : super(key: key);

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
                    await _leaveCommunity(context);
                  },
                  child: Text(
                    loc.leave,
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFFF5F9F9)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _leaveCommunity(BuildContext context) async {
    try {
      await CommunityService.leaveCommunity(communityId);
      await SharedPrefs.removeCommunityLevel(communityId);
      Navigator.pushReplacementNamed(context, '/fields');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorOccurred(e.toString())),
        ),
      );
    }
  }

  void _showUpgradeDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          content: Text(
            userLevel == "advanced"
                ? loc.joinGeneralAlso
                : loc.joinAdvancedAlso,
            style: TextStyle(fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.cancelThisRequest),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await CommunityService.changeCommunityLevel(communityId, "both");
                  await SharedPrefs.saveCommunityLevel(communityId, "both");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoomsSelectionPage(
                        communityId: communityId,
                        userLevel: "both",
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.errorOccurred(e.toString()))),
                  );
                }
              },
              child: Text(loc.yes),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return FutureBuilder<UserProfileModel?>(
      future: SharedPrefs.getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userType = snapshot.data?.userType ?? 'normal';
        List<Widget> roomCards = [];

        if (userType == 'organization') {
          // المنظمات ترى فقط غرفة "الفرص الوظيفية"
          roomCards.add(
            _buildRoomCard(
              context: context,
              icon: Icons.handshake,
              label: loc.jobOpportunities,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobOpportunitiesPage(communityId: communityId),
                  ),
                );
              },
            ),
          );
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
            ),
            body: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(children: roomCards),
            ),
          );
        } else {
          // المستخدمون العاديون يرون الغرف بناءً على المستوى
          if (userLevel == "both") {
            roomCards.add(
              _buildRoomCard(
                context: context,
                icon: Icons.groups,
                label: loc.generalDiscussionRoom,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiscussionRoomPage(communityId: communityId),
                    ),
                  );
                },
              ),
            );
            roomCards.add(
              _buildRoomCard(
                context: context,
                icon: Icons.forum,
                label: loc.advancedDiscussionRoom,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdvancedDiscussionRoomPage(communityId: communityId),
                    ),
                  );
                },
              ),
            );
          } else if (userLevel == "beginner") {
            roomCards.add(
              _buildRoomCard(
                context: context,
                icon: Icons.groups,
                label: loc.generalDiscussionRoom,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiscussionRoomPage(communityId: communityId),
                    ),
                  );
                },
              ),
            );
          } else if (userLevel == "advanced") {
            roomCards.add(
              _buildRoomCard(
                context: context,
                icon: Icons.forum,
                label: loc.advancedDiscussionRoom,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdvancedDiscussionRoomPage(communityId: communityId),
                    ),
                  );
                },
              ),
            );
          }

          // إضافة غرفة فرص العمل لجميع المستويات (للمستخدمين العاديين)
          roomCards.add(
            _buildRoomCard(
              context: context,
              icon: Icons.handshake,
              label: loc.jobOpportunities,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobOpportunitiesPage(communityId: communityId),
                  ),
                );
              },
            ),
          );
          //style: TextStyle(fontSize: 14.sp, color: const Color(0xFFF5F9F9)),
          if (userLevel != "both") {
            roomCards.add(
              Padding(
                padding: EdgeInsets.only(top: 24.h),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.swap_horiz, size: 20.sp, color:  Color(0xFFF5F9F9)),
                  label: Text(
                    loc.changeMyLevel,
                    style: TextStyle(fontSize: 14.sp, color:  Color(0xFFF5F9F9)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF326B80),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                  ),
                  onPressed: () => _showUpgradeDialog(context),
                ),
              ),
            );
          }
        }

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
            child: SingleChildScrollView(
              child: Column(
                children: roomCards,
              ),
            ),
          ),
        );
      },
    );
  }
}