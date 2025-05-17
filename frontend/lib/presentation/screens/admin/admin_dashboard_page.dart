// lib/presentation/admin_dashboard/admin_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'widgets/organization_tab.dart';
import 'widgets/field_tab.dart';
import 'widgets/community_tab.dart';
import '../../widgets/custom_drawer.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF326B80),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          loc.adminDashboard,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFFAAAEB1),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.business),
              text: loc.organizations,
            ),
            Tab(
              icon: const Icon(Icons.category),
              text: loc.fields,
            ),
            Tab(
              icon: const Icon(Icons.groups),
              text: loc.communities,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OrganizationTab(),
          FieldTab(),
          CommunityTab(),
        ],
      ),
    );
  }
}
