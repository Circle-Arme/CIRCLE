import 'package:flutter/material.dart';
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
    const Color primaryTeal = Color(0xFF2A6776);
    const Color headerBackground = Color(0xFFDCE3D7);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --------- Header with back and center title ----------
            Container(
              width: double.infinity,
              color: headerBackground,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: primaryTeal),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            "CIRCLE",
                            style: TextStyle(
                              fontSize: 70,
                              fontWeight: FontWeight.bold,
                              color: primaryTeal,
                              letterSpacing: 0,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Enhance your skills and build a strong\nprofessional network",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: primaryTeal,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Create an Account",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryTeal,
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ---- Full Name ----
                    TextFormField(
                      controller: _fullNameController,
                      style: const TextStyle(color: primaryTeal),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person, color: primaryTeal),
                        labelText: "Full Name",
                        labelStyle: TextStyle(color: primaryTeal),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryTeal),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryTeal, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    // ---- Email ----
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: primaryTeal),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email, color: primaryTeal),
                        labelText: "Email",
                        labelStyle: TextStyle(color: primaryTeal),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryTeal),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryTeal, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    // ---- Password ----
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: primaryTeal),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: primaryTeal),
                        labelText: "Password",
                        labelStyle: const TextStyle(color: primaryTeal),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    // ---- Confirm Password ----
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: primaryTeal),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline, color: primaryTeal),
                        labelText: "Confirm Password",
                        labelStyle: TextStyle(color: primaryTeal),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryTeal),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryTeal, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    // ---- Confirm Button (Arrow Icon) ----
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Icon(Icons.arrow_forward, color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
