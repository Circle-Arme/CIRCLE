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

  bool _isLoading = false;
  bool _obscurePassword = true;

  void _createAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      //regster
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
    const Color primaryGreen = Color(0xFF567F60);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with back arrow + main text
            Container(
              width: double.infinity,
              color: primaryGreen,
              padding: const EdgeInsets.only(top: 50, bottom: 30),
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        children: const [
                          SizedBox(height: 10),
                          Text(
                            "CIRCLE",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Enhance your skills and build a strong\nprofessional network",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48), // space to mirror arrow
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Title
            const Text(
              "Create an Account",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 20),

            // -------------Form---------------------//
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    //------ Full Name------//
                    TextFormField(
                      controller: _fullNameController,
                      style: const TextStyle(color: primaryGreen),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person, color: primaryGreen),
                        labelText: "Full Name",
                        labelStyle: TextStyle(color: primaryGreen),
                        // Underline border
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryGreen),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: primaryGreen,
                            width: 2.0,
                          ),
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

                    // ------Email------//
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: primaryGreen),
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email, color: primaryGreen),
                        labelText: "Email",
                        labelStyle: TextStyle(color: primaryGreen),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryGreen),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: primaryGreen,
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        final emailPattern = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailPattern.hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    //------- Password-------//
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: primaryGreen),
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: primaryGreen),
                        labelText: "Password",
                        labelStyle: const TextStyle(color: primaryGreen),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryGreen),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: primaryGreen,
                            width: 2.0,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: primaryGreen,
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
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    //------ Confirm button ------//
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Confirm',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
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
