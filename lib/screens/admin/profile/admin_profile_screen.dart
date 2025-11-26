import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../services/auth_service.dart';
// import '../../../widgets/common/custom_text_field.dart';
// import '../../../widgets/common/custom_button.dart';
import '../../../config/routes.dart';


class AdminProfileScreen extends StatefulWidget {
  @override
  _AdminProfileScreenState createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _buildingController;
  late TextEditingController _mobileController;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser!;
    _nameController = TextEditingController(text: user.username);
    _emailController = TextEditingController(text: user.email);
    _buildingController = TextEditingController(text: user.buildingNumber);
    _mobileController = TextEditingController(text: user.mobileNumber);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        'Admin Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 24),
                  ],
                ),
              ),

              // Profile Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Profile Picture
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                          ),
                          child: Center(
                            child: Text(
                              user.initials,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'ADMIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 32),

                        // Form Fields
                        _buildInputField('Full Name', _nameController),
                        SizedBox(height: 16),
                        _buildInputField('Email Address', _emailController,
                            keyboardType: TextInputType.emailAddress),
                        SizedBox(height: 16),
                        _buildInputField(
                            'Building Number', _buildingController),
                        SizedBox(height: 16),
                        _buildInputField(
                          'Mobile Number',
                          _mobileController,
                          hintText: 'Enter your mobile number',
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 32),

                        // Admin Permissions
                        _buildAdminPermissions(),
                        SizedBox(height: 32),

                        // Save Button
                        CustomButton(
                          text: 'Save Changes',
                          onPressed: _saveProfile,
                        ),
                        SizedBox(height: 16),

                        // Logout Button
                        Container(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _showLogoutDialog(context),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.red),
                            ),
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    String? hintText,
    TextInputType keyboardType = TextInputType.text, // ✅ default safe value
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          hintText: hintText,
          keyboardType: keyboardType, // ✅ added
        ),
      ],
    );
  }

  Widget _buildAdminPermissions() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.admin_panel_settings,
                  color: Colors.orange[700], size: 20),
              SizedBox(width: 8),
              Text(
                'Admin Permissions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildPermissionItem('Manage Members', true),
          _buildPermissionItem('Handle Maintenance', true),
          _buildPermissionItem('Send Notices', true),
          _buildPermissionItem('View Reports', true),
          _buildPermissionItem('Financial Management', true),
          _buildPermissionItem('System Settings', true),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String title, bool isEnabled) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle : Icons.cancel,
            color: isEnabled ? Colors.green : Colors.red,
            size: 18,
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Admin profile updated successfully'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              AuthService.logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (route) => false);
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _buildingController.dispose();
    _mobileController.dispose();
    super.dispose();
  }
}

CustomTextField({required TextEditingController controller, String? hintText, required TextInputType keyboardType}) {
}

CustomButton({required String text, required void Function() onPressed}) {
}
