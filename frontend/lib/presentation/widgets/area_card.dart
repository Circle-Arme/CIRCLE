import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/data/models/area_model.dart';
import 'package:frontend/presentation/screens/communities/communities_page.dart';
import 'package:frontend/core/utils/shared_prefs.dart';
import '../theme/app_colors.dart';

class AreaCard extends StatelessWidget {
  final AreaModel area;
  const AreaCard({Key? key, required this.area}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                area.image,
                height: 180.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 180.h, color: Colors.grey[300]),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      area.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      area.subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        onPressed: () async {
                          await SharedPrefs.saveLastSelectedAreaId(area.id.toString());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommunitiesPage(areaId: area.id.toString()),
                            ),
                          );
                        },



                        child: const Text("Explore", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}