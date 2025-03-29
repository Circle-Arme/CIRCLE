import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/auth_service.dart';
import 'regstraion_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  static const Color primaryTeal = Color(0xFF2A6776);
  static const Color loginButtonColor = Color(0xFFE0E0E0);
  static const Color backgroundWhite = Colors.white;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      bool isSuccess = await AuthService.login(
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
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      resizeToAvoidBottomInset: true,
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? _buildPortraitLayout()
              : _buildLandscapeLayout();
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
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
                  "CIRCLE",
                  style: TextStyle(
                    fontSize: 60.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Enhance your skills and build a strong\nprofessional network",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 35.w),
            child: _buildPortraitForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: 1.sh,
              color: primaryTeal,
              child: Center(
                child: Text(
                  "CIRCLE",
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
                child: _buildLandscapeForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailField(),
          SizedBox(height: 20.h),
          _buildPasswordField(),
          SizedBox(height: 30.h),
          _buildLoginButton(),
          SizedBox(height: 60.h),
          SizedBox(width: 30.w, child: Divider(color: primaryTeal, thickness: 5)),
          SizedBox(height: 60.h),
          _buildSignUpButton(),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildLandscapeForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailField(fontSize: 14.sp),
          SizedBox(height: 15.h),
          _buildPasswordField(fontSize: 14.sp),
          SizedBox(height: 25.h),
          _buildLoginButton(height: 80.h, fontSize: 8.sp, isLandscape: true),
          SizedBox(height: 50.h),
          SizedBox(width: 25.w, child: Divider(color: primaryTeal, thickness: 4)),
          SizedBox(height: 50.h),
          _buildSignUpButton(height: 80.h, fontSize: 8.sp, isLandscape: true),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildEmailField({double? fontSize}) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(fontSize: fontSize ?? 16.sp),
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: TextStyle(color: primaryTeal),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: primaryTeal),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: primaryTeal),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: primaryTeal, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your email';
        final emailPattern = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$');
        if (!emailPattern.hasMatch(value)) return 'Enter a valid email';
        return null;
      },
    );
  }

  Widget _buildPasswordField({double? fontSize}) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(fontSize: fontSize ?? 16.sp),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: primaryTeal),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: primaryTeal),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: primaryTeal),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: primaryTeal, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: primaryTeal,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your password';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  Widget _buildLoginButton({double? height, double? fontSize, bool isLandscape = false}) {
    final button = SizedBox(
      height: height ?? 50.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: loginButtonColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: primaryTeal)
            : Text(
          'Login',
          style: TextStyle(
            color: primaryTeal,
            fontSize: fontSize ?? 18.sp,
          ),
        ),
      ),
    );

    return isLandscape
        ? Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300.w),
        child: button,
      ),
    )
        : button;
  }

  Widget _buildSignUpButton({double? height, double? fontSize, bool isLandscape = false}) {
    final button = SizedBox(
      height: height ?? 50.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateAccountPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        child: Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize ?? 18.sp,
          ),
        ),
      ),
    );

    return isLandscape
        ? Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300.w),
        child: button,
      ),
    )
        : button;
  }
}
