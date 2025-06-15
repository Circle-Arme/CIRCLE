import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/presentation/blocs/auth/auth_bloc.dart';
import 'package:frontend/presentation/blocs/auth/auth_event.dart';
import 'package:frontend/presentation/blocs/auth/auth_state.dart';
import '../home/fields_page.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  static const Color primaryTeal = Color(0xFF2A6776);
  static const Color headerBackground = Color(0xFFE0E0E0);

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.passwordsNotMatch)),
        );
        return;
      }

      context.read<AuthBloc>().add(
        RegisterEvent(
          _fullNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FieldsPage()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: OrientationBuilder(
          builder: (context, orientation) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Column(
                children: [
                  _buildHeader(context),
                  SizedBox(height: 30.h),
                  Text(
                    AppLocalizations.of(context)!.createAccountTitle,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: primaryTeal,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: _buildForm(orientation == Orientation.landscape),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: headerBackground,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: primaryTeal),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "CIRCLE",
              style: TextStyle(
                fontSize: 50.sp,
                fontWeight: FontWeight.bold,
                color: primaryTeal,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Enhance your skills and build a strong\nprofessional network",
              textAlign: TextAlign.center,
              style: TextStyle(color: primaryTeal, fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(bool isLandscape) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _fullNameController,
            label: AppLocalizations.of(context)!.fullNameLabel,
            icon: Icons.person,
            validator: (val) =>
            val == null || val.isEmpty ? AppLocalizations.of(context)!.fullNameHint : null,
          ),
          SizedBox(height: 25.h),
          _buildTextField(
            controller: _emailController,
            label: AppLocalizations.of(context)!.emailLabel,
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.isEmpty) return AppLocalizations.of(context)!.emailHint;
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(val)) return AppLocalizations.of(context)!.invalidEmail;
              return null;
            },
          ),
          SizedBox(height: 25.h),
          _buildPasswordField(
            controller: _passwordController,
            label: AppLocalizations.of(context)!.passwordLabel,
            icon: Icons.lock,
            validator: (val) {
              if (val == null || val.isEmpty) return AppLocalizations.of(context)!.passwordHint;
              if (val.length < 6) return AppLocalizations.of(context)!.shortPassword;
              return null;
            },
          ),
          SizedBox(height: 25.h),
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: AppLocalizations.of(context)!.confirmPasswordLabel,
            icon: Icons.lock_outline,
            validator: (val) => val == null || val.isEmpty
                ? AppLocalizations.of(context)!.confirmPasswordHint
                : null,
          ),
          SizedBox(height: 40.h),

          // ✅ زر التسجيل مع BlocBuilder
          SizedBox(
            width: isLandscape ? 300.w : double.infinity,
            height: 50.h,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return ElevatedButton(
                  onPressed: isLoading ? null : _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.arrow_forward, color: Colors.white),
                );
              },
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: primaryTeal, fontSize: 16.sp),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryTeal),
        labelText: label,
        labelStyle: TextStyle(color: primaryTeal),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: primaryTeal),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: primaryTeal, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: _obscurePassword,
      style: TextStyle(color: primaryTeal, fontSize: 16.sp),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryTeal),
        labelText: label,
        labelStyle: TextStyle(color: primaryTeal),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: primaryTeal),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: primaryTeal, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: primaryTeal,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: validator,
    );
  }
}
