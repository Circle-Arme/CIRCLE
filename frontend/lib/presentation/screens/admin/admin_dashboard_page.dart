import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/core/services/organization_user_service.dart';
import 'package:frontend/core/services/field_service.dart';
import 'package:frontend/core/services/CommunityService.dart';
import 'package:frontend/core/services/chat_room_service.dart';
import 'package:frontend/data/models/user_profile_model.dart';
import 'package:frontend/data/models/area_model.dart';
import 'package:frontend/data/models/community_model.dart';
import 'package:frontend/presentation/widgets/custom_drawer.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserProfileModel> _orgUsers = [];
  List<AreaModel> _fields = [];
  List<CommunityModel> _communities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final orgUsers = await OrganizationUserService.fetchOrganizationUsers();
      final fields = await FieldService.fetchFields();
      // إذا كانت قائمة المجالات غير فارغة نستخدم id المجال الأول، وإلا نترك القائمة فارغة
      final communities = fields.isNotEmpty
          ? await CommunityService.fetchCommunities(fields.first.id.toString())
          : <CommunityModel>[];
      setState(() {
        _orgUsers = orgUsers;
        _fields = fields;
        _communities = communities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    }
  }

  Future<void> _deleteOrgUser(int userId) async {
    try {
      await OrganizationUserService.deleteOrganizationUser(userId);
      setState(() {
        _orgUsers.removeWhere((user) => user.id == userId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.deleteSuccess)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    }
  }

  Future<void> _deleteField(int fieldId) async {
    try {
      await FieldService.deleteField(fieldId);
      setState(() {
        _fields.removeWhere((field) => field.id == fieldId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.deleteSuccess)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    }
  }

  Future<void> _deleteCommunity(int communityId) async {
    try {
      await CommunityService.deleteCommunity(communityId);
      setState(() {
        _communities.removeWhere((community) => community.id == communityId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.deleteSuccess)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
      );
    }
  }

  void _showCreateFieldDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.createField),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.nameHint;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.description,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.descriptionHint;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // يُستحسن استدعاء dispose() للكنترولات هنا لو كانت ضمن Widget منفصلة
              },
              child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await FieldService.createField(
                      nameController.text.trim(),
                      descriptionController.text.trim(),
                      null, // يمكن إضافة دعم لرفع الصورة لاحقًا
                    );
                    Navigator.pop(context);
                    _fetchData();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.create),
            ),
          ],
        );
      },
    );
  }

  void _showEditFieldDialog(AreaModel field) {
    final nameController = TextEditingController(text: field.title);
    final descriptionController = TextEditingController(text: field.subtitle);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.editField),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.nameHint;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.description,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.descriptionHint;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await FieldService.updateField(
                      field.id,
                      nameController.text.trim(),
                      descriptionController.text.trim(),
                      null,
                    );
                    Navigator.pop(context);
                    _fetchData();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  void _showCreateCommunityDialog() {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    AreaModel? selectedField;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.createCommunity),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<AreaModel>(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.field,
                        border: const OutlineInputBorder(),
                      ),
                      items: _fields.map((field) {
                        return DropdownMenuItem<AreaModel>(
                          value: field,
                          child: Text(field.title),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedField = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return AppLocalizations.of(context)!.selectField;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.name,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.nameHint;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (selectedField == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.selectField)),
                    );
                    return;
                  }
                  try {
                    await CommunityService.createCommunity(
                      selectedField!.id,
                      nameController.text.trim(),
                      null,
                    );
                    Navigator.pop(context);
                    _fetchData();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.create),
            ),
          ],
        );
      },
    );
  }

  void _showEditCommunityDialog(CommunityModel community) {
    final nameController = TextEditingController(text: community.name);
    final formKey = GlobalKey<FormState>();
    AreaModel? selectedField = _fields.firstWhere((field) => field.id == community.areaId, orElse: () => AreaModel(id: 0, title: 'غير محدد', subtitle: '', image: null));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.editCommunity),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<AreaModel>(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.field,
                        border: const OutlineInputBorder(),
                      ),
                      value: selectedField,
                      items: _fields.map((field) {
                        return DropdownMenuItem<AreaModel>(
                          value: field,
                          child: Text(field.title),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedField = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return AppLocalizations.of(context)!.selectField;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.name,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.nameHint;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (selectedField == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.selectField)),
                    );
                    return;
                  }
                  try {
                    await CommunityService.updateCommunity(
                      community.id,
                      selectedField!.id,
                      nameController.text.trim(),
                      null,
                    );
                    Navigator.pop(context);
                    _fetchData();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  void _showCreateChatRoomDialog(CommunityModel community) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedType;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.createChatRoom),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.name,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.nameHint;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.type,
                        border: const OutlineInputBorder(),
                      ),
                      items: ['general', 'advanced', 'job_opportunities'].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return AppLocalizations.of(context)!.selectType;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (selectedType == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.selectType)),
                    );
                    return;
                  }
                  try {
                    await ChatRoomService.createChatRoom(
                      community.id,
                      nameController.text.trim(),
                      selectedType!,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.createSuccess)),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.create),
            ),
          ],
        );
      },
    );
  }

  void _showEditOrgUserDialog(UserProfileModel user) {
    final nameController = TextEditingController(text: user.name);
    final workEducationController = TextEditingController(text: user.workEducation);
    final positionController = TextEditingController(text: user.position);
    final descriptionController = TextEditingController(text: user.description);
    final emailController = TextEditingController(text: user.email);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.editOrgUser),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.organizationName,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.nameHint;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: workEducationController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.organizationDetails,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: positionController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.role,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.description,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.emailLabel,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.emailHint;
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return AppLocalizations.of(context)!.invalidEmail;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final updatedProfile = user.copyWith(
                      name: nameController.text.trim(),
                      workEducation: workEducationController.text.trim(),
                      position: positionController.text.trim(),
                      description: descriptionController.text.trim(),
                      email: emailController.text.trim(),
                    );
                    await OrganizationUserService.updateOrganizationUser(user.id, updatedProfile);
                    Navigator.pop(context);
                    _fetchData();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }

  void _showCreateOrgUserDialog() {
    final nameController = TextEditingController();
    final workEducationController = TextEditingController();
    final positionController = TextEditingController();
    final descriptionController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.createOrgUser),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.organizationName,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.nameHint;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: workEducationController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.organizationDetails,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: positionController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.role,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.description,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.emailLabel,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.emailHint;
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return AppLocalizations.of(context)!.invalidEmail;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.passwordLabel,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.passwordHint;
                      }
                      if (value.length < 6) {
                        return AppLocalizations.of(context)!.shortPassword;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final newProfile = UserProfileModel(
                      id: 0, // سيتم تحديد القيمة بواسطة الخادم
                      userId:0 ,
                      name: nameController.text.trim(),
                      workEducation: workEducationController.text.trim(),
                      position: positionController.text.trim(),
                      description: descriptionController.text.trim(),
                      email: emailController.text.trim(),
                      userType: 'organization',
                      communities: [],
                    );
                    await OrganizationUserService.createOrganizationUser(
                      newProfile,
                      passwordController.text.trim(),
                    );
                    Navigator.pop(context);
                    _fetchData();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.create),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF326B80),
        title: Text(
          loc.adminDashboard,
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.orange,
          tabs: [
            Tab(text: loc.organizations),
            Tab(text: loc.fields),
            Tab(text: loc.communities),
            Tab(text: loc.chatRooms),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Organizations
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: ElevatedButton(
                  onPressed: _showCreateOrgUserDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF326B80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    loc.createOrgUser,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: _orgUsers.isEmpty
                    ? Center(child: Text(loc.noOrganizations))
                    : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _orgUsers.length,
                  itemBuilder: (context, index) {
                    final user = _orgUsers[index];
                    return Card(
                      child: ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditOrgUserDialog(user),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteOrgUser(user.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Tab 2: Fields
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: ElevatedButton(
                  onPressed: _showCreateFieldDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF326B80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    loc.createField,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: _fields.isEmpty
                    ? Center(child: Text(loc.noFields))
                    : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _fields.length,
                  itemBuilder: (context, index) {
                    final field = _fields[index];
                    return Card(
                      child: ListTile(
                        title: Text(field.title),
                        subtitle: Text(field.subtitle),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditFieldDialog(field),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteField(field.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Tab 3: Communities
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: ElevatedButton(
                  onPressed: _showCreateCommunityDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF326B80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    loc.createCommunity,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: _communities.isEmpty
                    ? Center(child: Text(loc.noCommunities))
                    : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _communities.length,
                  itemBuilder: (context, index) {
                    final community = _communities[index];
                    // استخراج عنوان المجال باستخدام id المجتمع (areaId)
                    final areaTitle = _fields.firstWhere(
                            (field) => field.id == community.areaId,
                        orElse: () => AreaModel(id: 0, title: 'غير محدد', subtitle: '', image: null)
                    ).title;
                    return Card(
                      child: ListTile(
                        title: Text(community.name),
                        subtitle: Text("${loc.field}: $areaTitle"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chat, color: Colors.green),
                              onPressed: () => _showCreateChatRoomDialog(community),
                              tooltip: loc.createChatRoom,
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditCommunityDialog(community),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCommunity(community.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Tab 4: Chat Rooms (Placeholder)
          Center(
            child: Text(
              loc.chatRoomsManagementComingSoon,
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
