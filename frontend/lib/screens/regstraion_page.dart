import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  static const Color primaryTeal = Color(0xFF2A6776);
  static const Color headerBackground = Color(0xFFDCE3D7);

  void _createAccount() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      setState(() => _isLoading = true);

      bool isSuccess = await AuthService.register(
        _fullNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (isSuccess) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account creation failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: OrientationBuilder(
        builder: (context, orientation) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Column(
              children: [
                _buildHeader(context),
                SizedBox(height: 30.h),
                Text(
                  "Create an Account",
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
            label: "Full Name",
            icon: Icons.person,
            validator: (val) => val == null || val.isEmpty ? 'Please enter your full name' : null,
          ),
          SizedBox(height: 25.h),
          _buildTextField(
            controller: _emailController,
            label: "Email",
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please enter your email';
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(val)) return 'Enter a valid email';
              return null;
            },
          ),
          SizedBox(height: 25.h),
          _buildPasswordField(
            controller: _passwordController,
            label: "Password",
            icon: Icons.lock,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Enter a password';
              if (val.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          SizedBox(height: 25.h),
          _buildPasswordField(
            controller: _confirmPasswordController,
            label: "Confirm Password",
            icon: Icons.lock_outline,
            validator: (val) => val == null || val.isEmpty ? 'Please confirm your password' : null,
          ),
          SizedBox(height: 40.h),

          // Submit Button
          SizedBox(
            width: isLandscape ? 300.w : double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.arrow_forward, color: Colors.white),
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
