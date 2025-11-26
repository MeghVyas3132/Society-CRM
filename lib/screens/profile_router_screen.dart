

import 'package:flutter/material.dart';
import '../utils/auth_service.dart';
import 'profile_screen.dart';
// import 'admin_profile_screen.dart'; // ✅ fixed import

class ProfileRouterScreen extends StatelessWidget {
  const ProfileRouterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check user role and navigate to appropriate profile screen
    return AuthService.isAdmin
        ? const AdminProfileScreen()
        : const ProfileScreen(userName: '',);
  }
}
// filepath: d:\sproject\flutter_application_1\lib\admin_profile_screen.dart
// import 'package:flutter/material.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Profile')),
      body: const Center(child: Text('Admin Profile Screen')),
    );
  }
}