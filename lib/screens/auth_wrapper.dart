import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../services/firebase_auth_service.dart';
import '../models/user_model.dart';
import 'splash_screen.dart';
import 'dashboard_screen.dart';
import 'admin/dashboard/admin_dashboard_screen.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Initialize FirebaseAuthService
    FirebaseAuthService.instance.initialize();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash screen for 2 seconds
    await Future.delayed(Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen initially
    if (_showSplash) {
      return SplashScreen();
    }

    // Listen to Firebase auth state changes
    return StreamBuilder<firebase_auth.User?>(
      stream: FirebaseAuthService.instance.authStateChanges,
      builder: (context, authSnapshot) {
        print('AuthWrapper - Auth state: ${authSnapshot.connectionState}, hasData: ${authSnapshot.hasData}');
        
        // Still loading auth state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is not logged in
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return SplashScreen();
        }

        // User is logged in - try to get current user from service
        final currentUser = FirebaseAuthService.instance.currentUser;
        print('AuthWrapper - Current user: ${currentUser?.username}');

        if (currentUser != null) {
          return _buildDashboard(currentUser);
        }

        // If current user is null, listen to userChanges stream
        return StreamBuilder<User?>(
          stream: FirebaseAuthService.instance.userChanges.timeout(
            Duration(seconds: 5),
            onTimeout: (_) {
              print('AuthWrapper - User stream timeout, using Firebase Auth fallback');
              return null;
            },
          ),
          builder: (context, userSnapshot) {
            print('AuthWrapper - User stream state: ${userSnapshot.connectionState}, hasData: ${userSnapshot.hasData}, error: ${userSnapshot.error}');
            
            // Loading user data
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading your profile...'),
                    ],
                  ),
                ),
              );
            }

            // Handle errors
            if (userSnapshot.hasError) {
              print('AuthWrapper - Error in user stream: ${userSnapshot.error}');
            }

            final user = userSnapshot.data;

            // No user data found - try Firebase Auth fallback
            if (user == null) {
              print('AuthWrapper - No user data from stream, using Firebase Auth fallback');
              final firebaseUser = authSnapshot.data;
              if (firebaseUser != null) {
                return DashboardScreen(
                  userName: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
                  buildingInfo: null,
                );
              }
              return SplashScreen();
            }

            return _buildDashboard(user);
          },
        );
      },
    );
  }

  Widget _buildDashboard(User user) {
    print('Building dashboard for user: ${user.username}, role: ${user.roleString}');
    // Navigate based on role
    if (user.isAdmin) {
      return AdminDashboardScreen(
        userName: user.username,
        buildingName: user.buildingNumber,
      );
    } else {
      return DashboardScreen(
        userName: user.username,
        buildingInfo: user.buildingNumber,
      );
    }
  }
}