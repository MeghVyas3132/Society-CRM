// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import '../screens/login_screen.dart';
// import '../screens/dashboard_screen.dart';

// class AuthWrapper extends StatefulWidget {
//   const AuthWrapper({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _AuthWrapperState createState() => _AuthWrapperState();
// }

// class _AuthWrapperState extends State<AuthWrapper> {
//   @override
//   Widget build(BuildContext context) {
//     // ✅ If user is logged in, go to Dashboard
//     if (AuthService.isLoggedIn) {
//       return DashboardScreen();
//     }
//     // ❌ If not logged in, go to Login
//     else {
//       return LoginScreen();
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';
import '../services/firebase_auth_service.dart';
import 'dashboard_screen.dart';
import 'admin/dashboard/admin_dashboard_screen.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _userName;
  // String? _userEmail;
  String? _buildingInfo;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Simulate splash screen delay
      await Future.delayed(Duration(seconds: 1));

      // First try Firebase auth to determine role and current user
      String? role = await FirebaseAuthService.getCurrentUserRole();
      if (role != null) {
        setState(() {
          _isLoggedIn = true;
          _userName = null; // placeholder, we'll not display name here
          _isLoading = false;
        });
        // We'll navigate from build() below based on role via a post-frame callback
        // but keep wrapper simple: mark logged in and stash role in prefs for build-time decision
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', role);
      } else {
        // Fallback to SharedPreferences (legacy behavior)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        String? userName = prefs.getString('userName');
        String? buildingInfo = prefs.getString('buildingInfo');

        setState(() {
          _isLoggedIn = isLoggedIn;
          _userName = userName;
          _buildingInfo = buildingInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
        _isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show splash screen while checking auth status
      return SplashScreen();
    }

    if (_isLoggedIn) {
      // Determine role and navigate accordingly
      return FutureBuilder<String?>(
        future: SharedPreferences.getInstance()
            .then((prefs) => prefs.getString('userRole')),
        builder: (context, snapshot) {
          final role = snapshot.data;
          if (role == null) {
            // If role not known yet, show splash
            return SplashScreen();
          }

          if (role == 'admin') {
            return AdminDashboardScreen(userName: 'Admin', buildingName: '');
          } else {
            return DashboardScreen(userName: 'Member');
          }
        },
      );
    }

    // Not logged in -> show splash/login flow
    return SplashScreen();
  }
}

// Auth Service class to handle authentication logic
class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';
  static const String _buildingInfoKey = 'buildingInfo';
  static const String _userIdKey = 'userId';
  static const String _loginTimeKey = 'loginTime';

  // Login method
  static Future<bool> login({
    required String username,
    required String password,
    String? email,
    String? buildingInfo,
  }) async {
    try {
      // Here you would typically make an API call to authenticate
      // For demo purposes, we'll use simple validation

      bool isValidLogin = await _validateCredentials(username, password);

      if (isValidLogin) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Save user data
        await prefs.setBool(_isLoggedInKey, true);
        await prefs.setString(_userNameKey, username);
        await prefs.setString(_userEmailKey, email ?? 'user@example.com');
        await prefs.setString(
            _buildingInfoKey, buildingInfo ?? 'B-402, Spire Heights');
        await prefs.setString(
            _userIdKey, 'user_${DateTime.now().millisecondsSinceEpoch}');
        await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String());

        return true;
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Logout method
  static Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Clear all user data
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_buildingInfoKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_loginTimeKey);

      // You could also clear all preferences
      // await prefs.clear();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get current user data
  static Future<Map<String, String?>> getCurrentUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      return {
        'userName': prefs.getString(_userNameKey),
        'userEmail': prefs.getString(_userEmailKey),
        'buildingInfo': prefs.getString(_buildingInfoKey),
        'userId': prefs.getString(_userIdKey),
        'loginTime': prefs.getString(_loginTimeKey),
      };
    } catch (e) {
      return {};
    }
  }

  // Update user profile
  static Future<bool> updateProfile({
    String? userName,
    String? userEmail,
    String? buildingInfo,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (userName != null) {
        await prefs.setString(_userNameKey, userName);
      }
      if (userEmail != null) {
        await prefs.setString(_userEmailKey, userEmail);
      }
      if (buildingInfo != null) {
        await prefs.setString(_buildingInfoKey, buildingInfo);
      }

      return true;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  // Private method to validate credentials
  static Future<bool> _validateCredentials(
      String username, String password) async {
    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 500));

    // Demo validation - replace with actual API call
    const validCredentials = {
      'krisha shira': 'password123',
      'krisha': '123456',
      'john': 'password',
      'admin': 'admin123',
    };

    String lowerUsername = username.toLowerCase();
    return validCredentials[lowerUsername] == password;
  }

  // Check if session is expired (optional)
  static Future<bool> isSessionExpired() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? loginTimeStr = prefs.getString(_loginTimeKey);

      DateTime loginTime = DateTime.parse(loginTimeStr!);
      DateTime now = DateTime.now();

      // Session expires after 7 days (you can adjust this)
      Duration sessionDuration = Duration(days: 7);

      return now.difference(loginTime) > sessionDuration;
    } catch (e) {
      return true;
    }
  }

  // Refresh session
  static Future<void> refreshSession() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_loginTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Refresh session error: $e');
    }
  }
}

// User model for better data handling
class UserData {
  final String? id;
  final String? name;
  final String? email;
  final String? buildingInfo;
  final DateTime? loginTime;

  UserData({
    this.id,
    this.name,
    this.email,
    this.buildingInfo,
    this.loginTime,
  });

  factory UserData.fromMap(Map<String, String?> map) {
    return UserData(
      id: map['userId'],
      name: map['userName'],
      email: map['userEmail'],
      buildingInfo: map['buildingInfo'],
      loginTime:
          map['loginTime'] != null ? DateTime.parse(map['loginTime']!) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': id,
      'userName': name,
      'userEmail': email,
      'buildingInfo': buildingInfo,
      'loginTime': loginTime?.toIso8601String(),
    };
  }
}
