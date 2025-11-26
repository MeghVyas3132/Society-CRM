import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlue, AppColors.lightBlue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Forgot password',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20), // reduced from 50
                  padding: EdgeInsets.all(20), // reduced from 30
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    // ✅ makes it scrollable
                    child: Column(
                      children: [
                        Container(
                          width: 50, // reduced from 60
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.apartment,
                            color: AppColors.white,
                            size: 26, // reduced from 30
                          ),
                        ),
                        SizedBox(height: 20), // reduced from 30
                        Text(
                          'Forgot Password ?',
                          style: TextStyle(
                            fontSize: 20, // reduced from 24
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Icon(
                          Icons.lock_outline,
                          size: 60, // reduced from 80
                          color: AppColors.primaryBlue,
                        ),
                        SizedBox(height: 16), // reduced from 20
                        Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: 14, // reduced from 16
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        CustomTextField(
                          hintText: 'Enter your email',
                          prefixIcon: Icons.email,
                          controller: _emailController,
                          keyboardType: TextInputType
                              .emailAddress, // ✅ fixed (was null)
                        ),
                        SizedBox(height: 8),
                        Text(
                          "We'll send you an email with further instruction to reset your password.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 13, // reduced from 14
                          ),
                        ),
                        SizedBox(height: 20), // reduced from 30
                        CustomButton(
                          text: 'Reset Password',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Password reset link sent to your email!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
