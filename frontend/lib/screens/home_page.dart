import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/area_model.dart';
import '../services/area_service.dart';
import '../widgets/area_card.dart';
import '../widgets/custom_drawer.dart';
import '../theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<AreaModel>> futureAreas;

  @override
  void initState() {
    super.initState();
    futureAreas = AreaService.fetchAreas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: const CustomDrawer(),
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: FutureBuilder<List<AreaModel>>(
          future: futureAreas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("خطأ: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("لا توجد مجالات."));
            } else {
              final areas = snapshot.data!;
              return ListView.separated(
                itemCount: areas.length,
                separatorBuilder: (_, __) => SizedBox(height: 16.h),
                itemBuilder: (context, index) => AreaCard(area: areas[index]),
              );
            }
          },
        ),
      ),
    );
  }
}
