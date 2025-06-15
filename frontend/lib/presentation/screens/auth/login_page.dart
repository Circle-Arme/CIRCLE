// lib/presentation/screens/auth/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/presentation/blocs/language/language_bloc.dart';
import 'package:frontend/presentation/blocs/language/language_event.dart';
import 'package:frontend/presentation/blocs/auth/auth_bloc.dart';
import 'package:frontend/presentation/blocs/auth/auth_event.dart';
import 'package:frontend/presentation/blocs/auth/auth_state.dart';

import 'package:frontend/core/utils/shared_prefs.dart';
import 'package:frontend/core/services/community_service.dart';

import '../admin/admin_dashboard_page.dart';
import '../home/fields_page.dart';
import '../communities/my_communities_page.dart';
import 'regstraion_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey         = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  static const Color primaryTeal    = Color(0xFF2A6776);
  static const Color loginButtonColor = Color(0xFFE0E0E0);

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginEvent(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        ),
      );
    }
  }

  void _toggleLanguage() {
    final currentLang = Localizations.localeOf(context).languageCode;
    final newLocale = currentLang == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    context.read<LanguageBloc>()
        .add(ChangeLanguageEvent(newLocale));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthAuthenticated) {
            // 1) Admin
            if (state.userType == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminDashboardPage(),
                ),
              );
              return;
            }
            // 2) Organization user → لا نبني بروفايل، بل ننقل حسب انضمام المجتمعات
            if (state.userType == 'organization') {
              final joined = await CommunityService.fetchMyCommunities();
              if (joined.isEmpty) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FieldsPage(),
                  ),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyCommunitiesPage(),
                  ),
                );
              }
              return;
            }
            // 3) Normal user جديد
            if (state.isNewUser) {
              Navigator.pushReplacementNamed(context, '/fields');
              return;
            }
            // 4) Normal user قديم
            final joined = await CommunityService.fetchMyCommunities();
            if (joined.isEmpty) {
              Navigator.pushReplacementNamed(context, '/fields');
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyCommunitiesPage(),
                ),
              );
            }
          }
          else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: OrientationBuilder(
          builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? _buildPortrait(loc)
                : _buildLandscape(loc);
          },
        ),
      ),
    );
  }

  Widget _buildPortrait(AppLocalizations loc) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: primaryTeal,
            padding: EdgeInsets.only(top: 70.h, bottom: 80.h),
            child: Column(
              children: [
                Text(
                  'CIRCLE',
                  style: TextStyle(
                    fontSize: 60.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  loc.welcomeSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 35.w),
            child: _buildForm(loc),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscape(AppLocalizations loc) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            height: 1.sh,
            color: primaryTeal,
            child: Center(
              child: Text(
                'CIRCLE',
                style: TextStyle(
                  fontSize: 40.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 500.w),
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
              child: _buildForm(loc, isLandscape: true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(AppLocalizations loc, {bool isLandscape = false}) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailField(loc, fontSize: isLandscape ? 14.sp : null),
          SizedBox(height: 20.h),
          _buildPasswordField(loc, fontSize: isLandscape ? 14.sp : null),
          SizedBox(height: 30.h),
          _buildLoginButton(loc,
            height: isLandscape ? 80.h : null,
            fontSize: isLandscape ? 8.sp : null,
            isLandscape: isLandscape,
          ),
          SizedBox(height: 40.h),
          SizedBox(
            width: 30.w,
            child: Divider(color: primaryTeal, thickness: 5),
          ),
          SizedBox(height: 40.h),
          _buildSignUpAndLanguage(loc, isLandscape: isLandscape),
        ],
      ),
    );
  }

  Widget _buildEmailField(AppLocalizations loc, {double? fontSize}) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(fontSize: fontSize ?? 16.sp),
      decoration: InputDecoration(
        labelText: loc.emailLabel,
        labelStyle: TextStyle(color: primaryTeal),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: primaryTeal),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return loc.emailHint;
        }
        final pattern = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$');
        if (!pattern.hasMatch(value)) {
          return loc.invalidEmail;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(AppLocalizations loc, {double? fontSize}) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(fontSize: fontSize ?? 16.sp),
      decoration: InputDecoration(
        labelText: loc.passwordLabel,
        labelStyle: TextStyle(color: primaryTeal),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: primaryTeal),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off
                : Icons.visibility,
            color: primaryTeal,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return loc.passwordHint;
        }
        if (value.length < 6) {
          return loc.shortPassword;
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(
      AppLocalizations loc, {
        double? height,
        double? fontSize,
        bool isLandscape = false,
      }) {
    final button = SizedBox(
      height: height ?? 50.h,
      width: double.infinity,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return ElevatedButton(
            onPressed: isLoading ? null : _submitLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: loginButtonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: isLoading
                ? CircularProgressIndicator(color: primaryTeal)
                : Text(
              loc.loginButton,
              style: TextStyle(
                color: primaryTeal,
                fontSize: fontSize ?? 18.sp,
              ),
            ),
          );
        },
      ),
    );
    if (isLandscape) {
      return Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300.w),
          child: button,
        ),
      );
    }
    return button;
  }

  Widget _buildSignUpAndLanguage(
      AppLocalizations loc, {
        bool isLandscape = false,
      }) {
    final signUpBtn = SizedBox(
      height: 50.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateAccountPage(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        child: Text(
          loc.signUpButton,
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
      ),
    );

    final langBtn = TextButton(
      onPressed: _toggleLanguage,
      child: Text(
        Localizations
            .localeOf(context)
            .languageCode == 'ar'
            ? 'English'
            : 'العربية',
        style: TextStyle(fontSize: 16.sp),
      ),
    );

    final column = Column(
      children: [
        signUpBtn,
        SizedBox(height: 16.h),
        langBtn,
      ],
    );

    if (isLandscape) {
      return Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300.w),
          child: column,
        ),
      );
    }
    return column;
  }
}
