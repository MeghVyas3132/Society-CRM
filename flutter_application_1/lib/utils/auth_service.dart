
import '../models/user_model.dart';

class AuthService {
  static User? _currentUser;

  static var authStateChanges;

  // Get current logged in user
  static User? get currentUser => _currentUser;

  // Check if user is logged in
  static bool get isLoggedIn => _currentUser != null;

  // Check if current user is admin
  static bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Check if current user is regular user
  static bool get isUser => _currentUser?.isUser ?? false;

  // Login method with role detection
  static Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    Map<String, Map<String, dynamic>> mockUsers = {
      'admin@mysociety.com': {
        'id': '1',
        'username': 'Varsha Solanki',
        'email': 'admin@mysociety.com',
        'buildingNumber': 'B-302',
        // 'mobileNumber': '+91 98765 43210',
        'role': UserRole.admin,
        'password': 'admin123',
      },
      'user@mysociety.com': {
        'id': '2',
        'username': 'John Doe',
        'email': 'user@mysociety.com',
        'buildingNumber': 'A-101',
        // 'mobileNumber': '+91 87654 32109',
        'role': UserRole.user,
        'password': 'user123',
      },
      'resident1@mysociety.com': {
        'id': '3',
        'username': 'Priya Sharma',
        'email': 'resident1@mysociety.com',
        'buildingNumber': 'C-205',
        // 'mobileNumber': '+91 98123 45678',
        'role': UserRole.user,
        'password': 'priya123',
      },
      'admin2@mysociety.com': {
        'id': '4',
        'username': 'Rahul Patel',
        'email': 'admin2@mysociety.com',
        'buildingNumber': 'A-401',
        // 'mobileNumber': '+91 97654 32110',
        'role': UserRole.admin,
        'password': 'rahul123',
      },
    };

    if (mockUsers.containsKey(email.toLowerCase())) {
      final userData = mockUsers[email.toLowerCase()]!;
      if (userData['password'] == password) {
        _currentUser = User(
          id: userData['id'],
          username: userData['username'],
          email: userData['email'],
          buildingNumber: userData['buildingNumber'],
          // mobileNumber: userData['mobileNumber'],
          role: userData['role'],
          createdAt: DateTime.now(), mobileNumber: '', // ✅ Fix here
        );
        return true;
      }
    }

    return false;
  }

  // Register method
  static Future<bool> register(String username, String email,
      String buildingNumber, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (username.isEmpty ||
        email.isEmpty ||
        buildingNumber.isEmpty ||
        password.isEmpty) {
      return false;
    }

    List<String> existingEmails = [
      'admin@mysociety.com',
      'user@mysociety.com',
      'resident1@mysociety.com',
      'admin2@mysociety.com',
    ];

    if (existingEmails.contains(email.toLowerCase())) {
      throw Exception('Email already exists');
    }

    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      email: email,
      buildingNumber: buildingNumber,
      mobileNumber: "",
      role: UserRole.user,
      createdAt: DateTime.now(), // ✅ Fix here
    );

    return true;
  }

  static void logout() {
    _currentUser = null;
  }

  static void updateProfile(User updatedUser) {
    _currentUser = updatedUser;
  }

  static Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    if (_currentUser == null) return false;
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  static Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    List<String> validEmails = [
      'admin@mysociety.com',
      'user@mysociety.com',
      'resident1@mysociety.com',
      'admin2@mysociety.com',
    ];
    return validEmails.contains(email.toLowerCase());
  }

  static String getUserRoleString() {
    if (_currentUser == null) return 'Guest';
    return _currentUser!.isAdmin ? 'Administrator' : 'Resident';
  }

  static bool hasPermission(String permission) {
    if (_currentUser == null) return false;

    if (_currentUser!.isAdmin) {
      List<String> adminPermissions = [
        'manage_users',
        'handle_maintenance',
        'send_notices',
        'view_reports',
        'financial_management',
        'system_settings',
        'approve_registrations',
      ];
      return adminPermissions.contains(permission);
    }

    List<String> userPermissions = [
      'view_profile',
      'update_profile',
      'pay_maintenance',
      'view_notices',
      'view_members',
    ];

    return userPermissions.contains(permission);
  }

  static List<Map<String, dynamic>> getUserModules() {
    List<Map<String, dynamic>> modules = [
      {
        'title': 'Notice &\nCommunication',
        'icon': 'notifications',
        'route': '/notice',
        'color': 'blue',
      },
      {
        'title': 'Maintenance\n& Billing',
        'icon': 'payment',
        'route': '/maintenance',
        'color': 'green',
      },
      {
        'title': 'Account &\nFinance',
        'icon': 'account_balance',
        'route': '/finance',
        'color': 'orange',
      },
      {
        'title': 'Member &\nResident',
        'icon': 'people',
        'route': '/members',
        'color': 'purple',
      },
    ];

    if (isAdmin) {
      modules.addAll([
        {
          'title': 'Admin\nPanel',
          'icon': 'admin_panel_settings',
          'route': '/admin',
          'color': 'red',
        },
        {
          'title': 'System\nReports',
          'icon': 'analytics',
          'route': '/reports',
          'color': 'teal',
        },
      ]);
    }

    return modules;
  }
}
