import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/data/models/area_model.dart';
import 'package:frontend/core/services/area_service.dart';
import '../../widgets/area_card.dart';
import '../../widgets/custom_drawer.dart';
import '../../theme/app_colors.dart';
import '../communities/communities_page.dart';
import '../profile/user_profile_page.dart';
import 'package:frontend/core/utils/shared_prefs.dart';

class FieldsPage extends StatefulWidget {
  final bool isProfileFilled;

  const FieldsPage({Key? key, this.isProfileFilled = false}) : super(key: key);

  @override
  State<FieldsPage> createState() => _FieldsPageState();
}

class _FieldsPageState extends State<FieldsPage> {
  late Future<List<AreaModel>> futureAreas;
  bool _showProfilePrompt = false;
  String _searchQuery = '';
  List<AreaModel> _allAreas = [];
  List<AreaModel> _filteredAreas = [];

  @override
  void initState() {
    super.initState();
    futureAreas = AreaService.fetchAreas();
    _checkAndShowProfilePrompt();
  }

  Future<void> _checkAndShowProfilePrompt() async {
    final hasSeenPrompt = await SharedPrefs.hasSeenProfilePrompt();

    if (!hasSeenPrompt) {
      setState(() {
        _showProfilePrompt = true;
      });
      await SharedPrefs.setProfilePromptSeen(true);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredAreas = _allAreas.where((area) {
        return area.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              color: AppColors.primaryColor,
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        centerTitle: true,
        title: const Text(
          "CIRCLE",
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            color: AppColors.primaryColor,
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: loc.searchAreas,
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: FutureBuilder<List<AreaModel>>(
                    future: futureAreas,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            loc.errorOccurred(snapshot.error.toString()),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text(loc.noAreas));
                      } else {
                        _allAreas = snapshot.data!;
                        _filteredAreas = _searchQuery.isEmpty
                            ? _allAreas
                            : _filteredAreas;
                        return ListView.separated(
                          itemCount: _filteredAreas.length,
                          separatorBuilder: (_, __) => SizedBox(height: 16.h),
                          itemBuilder: (context, index) {
                            final area = _filteredAreas[index];
                            return GestureDetector(
                              onTap: () async {
                                await SharedPrefs.saveLastSelectedAreaId(
                                    area.id.toString());
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommunitiesPage(
                                        areaId: area.id.toString()),
                                  ),
                                );
                              },
                              child: AreaCard(area: area),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          if (_showProfilePrompt)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        loc.completeProfilePrompt,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF326B80),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF326B80),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        onPressed: () async {
                          final profile = await SharedPrefs.getUserProfile();
                          if (profile != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(
                                  profile: profile,
                                  isOwnProfile: true,
                                ),
                              ),
                            ).then((newProfile) {
                              if (newProfile != null) {
                                setState(() {
                                  _showProfilePrompt = false;
                                });
                              }
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "لم يتم العثور على بيانات المستخدم")),
                            );
                          }
                        },
                        child: Text(
                          loc.fillProfile,
                          style:
                          TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showProfilePrompt = false;
                          });
                        },
                        child: Text(
                          loc.skip,
                          style: const TextStyle(color: Colors.red),
                        ),
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
}