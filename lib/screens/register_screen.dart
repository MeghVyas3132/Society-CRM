

import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/firebase_auth_service.dart';
import '../services/messaging_service.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _adminCodeController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showAdminCode = false;

  // Secret Admin Code - Change this to your own secret code!
  static const String ADMIN_SECRET_CODE = 'ADMIN2025';
  static const String SUPER_ADMIN_CODE = 'SUPERADMIN2025';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Header with gradient like Login screen
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF4DA0FF), // Light Blue
                      Color(0xFF0072E5), // Darker Blue
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Body with form
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // Logo
                  Container(
                    width: 85,
                    height: 85,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1976D2), // Same as login button
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Registration form box
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32),

                          // Full Name
                          _buildEnhancedTextField(
                            controller: _usernameController,
                            label: 'Full Name',
                            hintText: 'Enter your full name',
                            prefixIcon: Icons.person_outline_rounded,
                          ),

                          const SizedBox(height: 20),

                          // Email
                          _buildEnhancedTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hintText: 'Enter your email address',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 20),

                          // Building Number
                          _buildEnhancedTextField(
                            controller: _buildingController,
                            label: 'Building Number',
                            hintText: 'e.g., B-302, Tower A-15',
                            prefixIcon: Icons.apartment_outlined,
                          ),

                          const SizedBox(height: 20),

                          // Password
                          _buildEnhancedTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hintText: 'Create a strong password',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: const Color.fromARGB(255, 104, 110, 116),
                                size: 22,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Admin Code Toggle - More Visible!
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _showAdminCode ? Color(0xFF1976D2).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _showAdminCode ? Color(0xFF1976D2) : Colors.grey.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showAdminCode = !_showAdminCode;
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    _showAdminCode ? Icons.admin_panel_settings : Icons.admin_panel_settings_outlined,
                                    color: _showAdminCode ? Color(0xFF1976D2) : Colors.grey[600],
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'I have an admin code',
                                      style: TextStyle(
                                        color: _showAdminCode ? Color(0xFF1976D2) : Colors.grey[700],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    _showAdminCode ? Icons.check_circle : Icons.circle_outlined,
                                    color: _showAdminCode ? Color(0xFF1976D2) : Colors.grey,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Admin Code Field (shown only when toggled)
                          if (_showAdminCode) ...[
                            const SizedBox(height: 16),
                            _buildEnhancedTextField(
                              controller: _adminCodeController,
                              label: 'Admin Code',
                              hintText: 'Enter secret admin code',
                              prefixIcon: Icons.security_rounded,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Use ADMIN2025 for Admin or SUPERADMIN2025 for Super Admin',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // Register button
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF1976D2),
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _handleRegister,
                                      borderRadius: BorderRadius.circular(16),
                                      child: const Center(
                                        child: Text(
                                          'Create Account',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                          const SizedBox(height: 24),

                          // Info note
                          Row(
                            children: const [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFF1976D2),
                                size: 20,
                              ),
                              SizedBox(width: 12),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Color(0xFF1976D2),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6F6F6F), // Gray label
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE6F0FA), // same as login input bg
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD1E3F8), // light border
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 15,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  prefixIcon,
                  color: Color(0xFF5F6368), // Gray icons (like screenshot)
                  size: 22,
                ),
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegister() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String building = _buildingController.text.trim();
    String password = _passwordController.text.trim();
    String adminCode = _adminCodeController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        building.isEmpty ||
        password.isEmpty) {
      _showEnhancedMessage('Please fill in all fields', isError: true);
      return;
    }

    if (!_isValidEmail(email)) {
      _showEnhancedMessage('Please enter a valid email address', isError: true);
      return;
    }

    if (password.length < 6) {
      _showEnhancedMessage('Password must be at least 6 characters',
          isError: true);
      return;
    }

    // Determine user role based on admin code
    UserRole userRole = UserRole.user;
    if (_showAdminCode && adminCode.isNotEmpty) {
      if (adminCode == SUPER_ADMIN_CODE) {
        userRole = UserRole.superAdmin;
      } else if (adminCode == ADMIN_SECRET_CODE) {
        userRole = UserRole.admin;
      } else {
        _showEnhancedMessage('Invalid admin code', isError: true);
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use Firebase Auth Service for registration with role
      final result = await FirebaseAuthService.instance.signUp(
        email: email,
        password: password,
        username: username,
        buildingNumber: building,
        role: userRole,
      );

      if (result.isSuccess && result.user != null) {
        // Subscribe to notification topics
        await MessagingService.instance.subscribeToUserTopics(building);
        
        String roleMessage = userRole == UserRole.superAdmin 
            ? 'Super Admin' 
            : userRole == UserRole.admin 
                ? 'Admin' 
                : 'Member';
        
        _showEnhancedMessage(
            'Welcome $roleMessage ${result.user!.username}!');
        await Future.delayed(const Duration(seconds: 1));
        
        // Go back to AuthWrapper - it will detect login and show dashboard
        Navigator.pushNamedAndRemoveUntil(
            context, '/', (route) => false);
      } else {
        _showEnhancedMessage(result.message, isError: true);
      }
    } catch (e) {
      _showEnhancedMessage('Registration failed: ${e.toString()}',
          isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showEnhancedMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFE53E3E) : const Color(0xFF38A169),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _buildingController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }
}
