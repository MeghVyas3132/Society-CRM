// // TODO Implement this library.
// // services/auth_service.dart
// // import 'dart:convert';
// import 'dart:async';
// import '../models/user_model.dart';

// class AuthService {
//   // Private static instance for singleton pattern
//   static AuthService? _instance;
  
//   // Current logged-in user
//   static User? _currentUser;
  
//   // Stream controller for auth state changes
//   static final StreamController<User?> _authStateController = StreamController<User?>.broadcast();
  
//   // Private constructor for singleton
//   AuthService._();
  
//   // Get singleton instance
//   static AuthService get instance {
//     _instance ??= AuthService._();
//     return _instance!;
//   }
  
//   // Getters
//   static User? get currentUser => _currentUser;
//   static bool get isLoggedIn => _currentUser != null;
//   static bool get isAdmin => _currentUser?.isAdmin ?? false;
//   static bool get isUser => _currentUser?.isUser ?? false;
//   static String get currentUserId => _currentUser?.id ?? '';
//   static String get currentUserName => _currentUser?.username ?? '';
//   static String get currentUserEmail => _currentUser?.email ?? '';
//   static String get currentUserRole => _currentUser?.roleString ?? 'Guest';
  
//   // Auth state stream
//   static Stream<User?> get authStateChanges => _authStateController.stream;
  
//   // Mock user database - In real app, this would be your backend API
//   static final Map<String, Map<String, dynamic>> _mockUsers = {
//     'admin@mysociety.com': {
//       'id': '1',
//       'username': 'Varsha Solanki',
//       'email': 'admin@mysociety.com',
//       'buildingNumber': 'B-302',
//       'mobileNumber': '+91 98765 43210',
//       'role': UserRole.admin,
//       'password': 'admin123', // In real app, this would be hashed
//       'createdAt': '2024-01-15T10:30:00Z',
//       'isActive': true,
//       'lastLogin': null,
//     },
//     'user@mysociety.com': {
//       'id': '2',
//       'username': 'John Doe',
//       'email': 'user@mysociety.com',
//       'buildingNumber': 'A-101',
//       'mobileNumber': '+91 87654 32109',
//       'role': UserRole.user,
//       'password': 'user123',
//       'createdAt': '2024-01-20T14:45:00Z',
//       'isActive': true,
//       'lastLogin': null,
//     },
//     'resident1@mysociety.com': {
//       'id': '3',
//       'username': 'Priya Sharma',
//       'email': 'resident1@mysociety.com',
//       'buildingNumber': 'C-205',
//       'mobileNumber': '+91 98123 45678',
//       'role': UserRole.user,
//       'password': 'priya123',
//       'createdAt': '2024-02-01T09:15:00Z',
//       'isActive': true,
//       'lastLogin': null,
//     },
//     'admin2@mysociety.com': {
//       'id': '4',
//       'username': 'Rahul Patel',
//       'email': 'admin2@mysociety.com',
//       'buildingNumber': 'A-401',
//       'mobileNumber': '+91 97654 32110',
//       'role': UserRole.admin,
//       'password': 'rahul123',
//       'createdAt': '2024-01-10T16:20:00Z',
//       'isActive': true,
//       'lastLogin': null,
//     },
//     'manager@mysociety.com': {
//       'id': '5',
//       'username': 'Anita Singh',
//       'email': 'manager@mysociety.com',
//       'buildingNumber': 'B-101',
//       'mobileNumber': '+91 96543 21009',
//       'role': UserRole.user,
//       'password': 'anita123',
//       'createdAt': '2024-01-25T11:30:00Z',
//       'isActive': true,
//       'lastLogin': null,
//     },
//   };
  
//   /// Login method with comprehensive validation
//   static Future<AuthResult> login(String email, String password) async {
//     try {
//       // Simulate API delay
//       await Future.delayed(Duration(milliseconds: 1500));
      
//       // Input validation
//       if (email.isEmpty || password.isEmpty) {
//         return AuthResult.failure('Please fill in all fields');
//       }
      
//       if (!_isValidEmail(email)) {
//         return AuthResult.failure('Please enter a valid email address');
//       }
      
//       // Check if user exists in mock database
//       final String emailKey = email.toLowerCase().trim();
//       if (!_mockUsers.containsKey(emailKey)) {
//         return AuthResult.failure('User not found. Please check your email address.');
//       }
      
//       final Map<String, dynamic> userData = _mockUsers[emailKey]!;
      
//       // Check if account is active
//       if (!userData['isActive']) {
//         return AuthResult.failure('Your account has been deactivated. Please contact admin.');
//       }
      
//       // Verify password (in real app, compare with hashed password)
//       if (userData['password'] != password) {
//         return AuthResult.failure('Invalid password. Please try again.');
//       }
      
//       // Create user object
//       _currentUser = User(
//         id: userData['id'],
//         username: userData['username'],
//         email: userData['email'],
//         buildingNumber: userData['buildingNumber'],
//         mobileNumber: userData['mobileNumber'],
//         role: userData['role'],
//         createdAt: DateTime.parse(userData['createdAt']),
//       );
      
//       // Update last login time
//       _mockUsers[emailKey]!['lastLogin'] = DateTime.now().toIso8601String();
      
//       // Notify listeners about auth state change
//       _authStateController.add(_currentUser);
      
//       return AuthResult.success(_currentUser!, 'Login successful');
      
//     } catch (e) {
//       return AuthResult.failure('Login failed. Please try again later.');
//     }
//   }
  
//   /// Register new user
//   static Future<AuthResult> register(String username, String email, String buildingNumber, String password) async {
//     try {
//       // Simulate API delay
//       await Future.delayed(Duration(milliseconds: 2000));
      
//       // Input validation
//       if (username.isEmpty || email.isEmpty || buildingNumber.isEmpty || password.isEmpty) {
//         return AuthResult.failure('Please fill in all fields');
//       }
      
//       if (!_isValidEmail(email)) {
//         return AuthResult.failure('Please enter a valid email address');
//       }
      
//       if (password.length < 6) {
//         return AuthResult.failure('Password must be at least 6 characters long');
//       }
      
//       if (!_isValidBuildingNumber(buildingNumber)) {
//         return AuthResult.failure('Please enter a valid building number (e.g., A-101, B-302)');
//       }
      
//       // Check if email already exists
//       final String emailKey = email.toLowerCase().trim();
//       if (_mockUsers.containsKey(emailKey)) {
//         return AuthResult.failure('An account with this email already exists');
//       }
      
//       // Check if building number is already taken
//       if (_isBuildingNumberTaken(buildingNumber)) {
//         return AuthResult.failure('This building number is already registered');
//       }
      
//       // Generate new user ID
//       final String newUserId = (DateTime.now().millisecondsSinceEpoch).toString();
      
//       // Create new user data
//       final Map<String, dynamic> newUserData = {
//         'id': newUserId,
//         'username': username.trim(),
//         'email': emailKey,
//         'buildingNumber': buildingNumber.toUpperCase().trim(),
//         'mobileNumber': '', // Can be updated later in profile
//         'role': UserRole.user, // New registrations are always regular users
//         'password': password, // In real app, this would be hashed
//         'createdAt': DateTime.now().toIso8601String(),
//         'isActive': true,
//         'lastLogin': null,
//       };
      
//       // Add to mock database
//       _mockUsers[emailKey] = newUserData;
      
//       // Create user object and login automatically
//       _currentUser = User(
//         id: newUserData['id'],
//         username: newUserData['username'],
//         email: newUserData['email'],
//         buildingNumber: newUserData['buildingNumber'],
//         mobileNumber: newUserData['mobileNumber'],
//         role: newUserData['role'],
//         createdAt: DateTime.parse(newUserData['createdAt']),
//       );
      
//       // Notify listeners about auth state change
//       _authStateController.add(_currentUser);
      
//       return AuthResult.success(_currentUser!, 'Registration successful! Welcome to MySociety.');
      
//     } catch (e) {
//       return AuthResult.failure('Registration failed. Please try again later.');
//     }
//   }
  
//   /// Reset password
//   static Future<AuthResult> resetPassword(String email) async {
//     try {
//       // Simulate API delay
//       await Future.delayed(Duration(milliseconds: 1500));
      
//       if (email.isEmpty) {
//         return AuthResult.failure('Please enter your email address');
//       }
      
//       if (!_isValidEmail(email)) {
//         return AuthResult.failure('Please enter a valid email address');
//       }
      
//       // Check if email exists
//       final String emailKey = email.toLowerCase().trim();
//       if (!_mockUsers.containsKey(emailKey)) {
//         return AuthResult.failure('No account found with this email address');
//       }
      
//       // In real app, you would send a password reset email here
//       return AuthResult.success(null, 'Password reset instructions have been sent to your email');
      
//     } catch (e) {
//       return AuthResult.failure('Failed to send reset instructions. Please try again later.');
//     }
//   }
  
//   /// Change password for current user
//   static Future<AuthResult> changePassword(String currentPassword, String newPassword) async {
//     try {
//       if (_currentUser == null) {
//         return AuthResult.failure('Please login first');
//       }
      
//       // Simulate API delay
//       await Future.delayed(Duration(milliseconds: 1000));
      
//       if (currentPassword.isEmpty || newPassword.isEmpty) {
//         return AuthResult.failure('Please fill in all fields');
//       }
      
//       if (newPassword.length < 6) {
//         return AuthResult.failure('New password must be at least 6 characters long');
//       }
      
//       // Get current user data
//       final String emailKey = _currentUser!.email.toLowerCase();
//       final Map<String, dynamic>? userData = _mockUsers[emailKey];
      
//       if (userData == null) {
//         return AuthResult.failure('User data not found');
//       }
      
//       // Verify current password
//       if (userData['password'] != currentPassword) {
//         return AuthResult.failure('Current password is incorrect');
//       }
      
//       // Update password
//       _mockUsers[emailKey]!['password'] = newPassword;
      
//       return AuthResult.success(null, 'Password changed successfully');
      
//     } catch (e) {
//       return AuthResult.failure('Failed to change password. Please try again.');
//     }
//   }
  
//   /// Update user profile
//   static Future<AuthResult> updateProfile(User updatedUser) async {
//     try {
//       if (_currentUser == null) {
//         return AuthResult.failure('Please login first');
//       }
      
//       // Simulate API delay
//       await Future.delayed(Duration(milliseconds: 800));
      
//       // Input validation
//       if (updatedUser.username.isEmpty || updatedUser.email.isEmpty || updatedUser.buildingNumber.isEmpty) {
//         return AuthResult.failure('Please fill in all required fields');
//       }
      
//       // Update current user
//       _currentUser = updatedUser;
      
//       // Update in mock database
//       final String emailKey = updatedUser.email.toLowerCase();
//       if (_mockUsers.containsKey(emailKey)) {
//         _mockUsers[emailKey]!.addAll({
//           'username': updatedUser.username,
//           'buildingNumber': updatedUser.buildingNumber,
//           'mobileNumber': updatedUser.mobileNumber,
//         });
//       }
      
//       // Notify listeners
//       _authStateController.add(_currentUser);
      
//       return AuthResult.success(_currentUser!, 'Profile updated successfully');
      
//     } catch (e) {
//       return AuthResult.failure('Failed to update profile. Please try again.');
//     }
//   }
  
//   /// Logout current user
//   static Future<void> logout() async {
//     try {
//       // Simulate API call
//       await Future.delayed(Duration(milliseconds: 500));
      
//       // Clear current user
//       _currentUser = null;
      
//       // Notify listeners
//       _authStateController.add(null);
      
//     } catch (e) {
//       // Even if logout fails, clear local user
//       _currentUser = null;
//       _authStateController.add(null);
//     }
//   }
  
//   /// Check if user has specific permission
//   static bool hasPermission(String permission) {
//     if (_currentUser == null) return false;
    
//     // Admin permissions
//     if (_currentUser!.isAdmin) {
//       final List<String> adminPermissions = [
//         'manage_users',
//         'create_users',
//         'delete_users',
//         'edit_users',
//         'handle_maintenance',
//         'approve_maintenance',
//         'send_notices',
//         'create_notices',
//         'delete_notices',
//         'view_reports',
//         'export_reports',
//         'financial_management',
//         'view_finances',
//         'manage_finances',
//         'system_settings',
//         'backup_data',
//         'approve_registrations',
//         'deactivate_users',
//         'make_admin',
//         'remove_admin',
//       ];
//       return adminPermissions.contains(permission);
//     }
    
//     // User permissions
//     final List<String> userPermissions = [
//       'view_profile',
//       'update_profile',
//       'change_password',
//       'pay_maintenance',
//       'view_maintenance_history',
//       'view_notices',
//       'view_members',
//       'contact_members',
//       'view_personal_finances',
//     ];
    
//     return userPermissions.contains(permission);
//   }
  
//   /// Get all users (admin only)
//   static Future<List<User>> getAllUsers() async {
//     if (!isAdmin) {
//       throw Exception('Access denied. Admin privileges required.');
//     }
    
//     // Simulate API delay
//     await Future.delayed(Duration(milliseconds: 800));
    
//     final List<User> users = [];
    
//     _mockUsers.forEach((email, userData) {
//       users.add(User(
//         id: userData['id'],
//         username: userData['username'],
//         email: userData['email'],
//         buildingNumber: userData['buildingNumber'],
//         mobileNumber: userData['mobileNumber'],
//         role: userData['role'],
//         createdAt: DateTime.parse(userData['createdAt']),
//       ));
//     });
    
//     return users;
//   }
  
//   /// Promote user to admin (admin only)
//   static Future<AuthResult> promoteToAdmin(String userId) async {
//     if (!isAdmin) {
//       return AuthResult.failure('Access denied. Admin privileges required.');
//     }
    
//     // Find user by ID
//     String? targetUserEmail;
//     _mockUsers.forEach((email, userData) {
//       if (userData['id'] == userId) {
//         targetUserEmail = email;
//       }
//     });
    
//     if (targetUserEmail == null) {
//       return AuthResult.failure('User not found');
//     }
    
//     // Update role
//     _mockUsers[targetUserEmail]!['role'] = UserRole.admin;
    
//     return AuthResult.success(null, 'User promoted to admin successfully');
//   }
  
//   /// Demote admin to user (admin only)
//   static Future<AuthResult> demoteToUser(String userId) async {
//     if (!isAdmin) {
//       return AuthResult.failure('Access denied. Admin privileges required.');
//     }
    
//     // Find user by ID
//     String? targetUserEmail;
//     _mockUsers.forEach((email, userData) {
//       if (userData['id'] == userId) {
//         targetUserEmail = email;
//       }
//     });
    
//     if (targetUserEmail == null) {
//       return AuthResult.failure('User not found');
//     }
    
//     // Update role
//     _mockUsers[targetUserEmail]!['role'] = UserRole.user;
    
//     return AuthResult.success(null, 'Admin demoted to user successfully');
//   }
  
//   /// Get user statistics (admin only)
//   static Future<Map<String, int>> getUserStats() async {
//     if (!isAdmin) {
//       throw Exception('Access denied. Admin privileges required.');
//     }
    
//     await Future.delayed(Duration(milliseconds: 500));
    
//     int totalUsers = _mockUsers.length;
//     int activeUsers = _mockUsers.values.where((user) => user['isActive']).length;
//     int admins = _mockUsers.values.where((user) => user['role'] == UserRole.admin).length;
//     int regularUsers = _mockUsers.values.where((user) => user['role'] == UserRole.user).length;
    
//     return {
//       'total': totalUsers,
//       'active': activeUsers,
//       'inactive': totalUsers - activeUsers,
//       'admins': admins,
//       'users': regularUsers,
//     };
//   }
  
//   // Helper methods
  
//   /// Validate email format
//   static bool _isValidEmail(String email) {
//     return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
//   }
  
//   /// Validate building number format
//   static bool _isValidBuildingNumber(String buildingNumber) {
//     return RegExp(r'^[A-Z]-\d{3}$', caseSensitive: false).hasMatch(buildingNumber);
//   }
  
//   /// Check if building number is already taken
//   static bool _isBuildingNumberTaken(String buildingNumber) {
//     final String formattedBuilding = buildingNumber.toUpperCase().trim();
//     return _mockUsers.values.any((user) => user['buildingNumber'] == formattedBuilding);
//   }
  
//   /// Get user by email
//   static User? getUserByEmail(String email) {
//     final String emailKey = email.toLowerCase().trim();
//     final userData = _mockUsers[emailKey];
    
//     if (userData == null) return null;
    
//     return User(
//       id: userData['id'],
//       username: userData['username'],
//       email: userData['email'],
//       buildingNumber: userData['buildingNumber'],
//       mobileNumber: userData['mobileNumber'],
//       role: userData['role'],
//       createdAt: DateTime.parse(userData['createdAt']),
//     );
//   }
  
//   /// Check if user exists
//   static bool userExists(String email) {
//     return _mockUsers.containsKey(email.toLowerCase().trim());
//   }
  
//   /// Dispose resources
//   static void dispose() {
//     _authStateController.close();
//   }
// }

// /// Authentication result class
// class AuthResult {
//   final bool isSuccess;
//   final String message;
//   final User? user;
  
//   AuthResult._(this.isSuccess, this.message, this.user);
  
//   factory AuthResult.success(User? user, String message) {
//     return AuthResult._(true, message, user);
//   }
  
//   factory AuthResult.failure(String message) {
//     return AuthResult._(false, message, null);
//   }
  
//   @override
//   String toString() {
//     return 'AuthResult(isSuccess: $isSuccess, message: $message, user: ${user?.username})';
//   }
// }

// services/auth_service.dart
import 'dart:async';
import '../models/user_model.dart';

class AuthService {
  static AuthService? _instance;
  static User? _currentUser;
  static final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  AuthService._();

  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  // ✅ Safe getter
  static User get requireUser {
    if (_currentUser == null) {
      throw Exception("No user logged in. Please login first.");
    }
    return _currentUser!;
  }

  
  

  static User? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null;
  static bool get isAdmin => _currentUser?.isAdmin ?? false;
  static bool get isUser => _currentUser?.isUser ?? false;
  static String get currentUserId => _currentUser?.id ?? '';
  static String get currentUserName => _currentUser?.username ?? 'Guest';
  static String get currentUserEmail => _currentUser?.email ?? '';
  static String get currentUserRole => _currentUser?.roleString ?? 'Guest';

  static Stream<User?> get authStateChanges => _authStateController.stream;

  // 🔹 Mock users (no createdAt field now)
  static final Map<String, Map<String, dynamic>> _mockUsers = {
    'admin@mysociety.com': {
      'id': '1',
      'username': 'Varsha Solanki',
      'email': 'admin@mysociety.com',
      'buildingNumber': 'B-302',
      'mobileNumber': '+91 98765 43210',
      'role': UserRole.admin,
      'password': 'admin123',
      'isActive': true,
      'lastLogin': null,
    },
    'user@mysociety.com': {
      'id': '2',
      'username': 'John Doe',
      'email': 'user@mysociety.com',
      'buildingNumber': 'A-101',
      'mobileNumber': '+91 87654 32109',
      'role': UserRole.user,
      'password': 'user123',
      'isActive': true,
      'lastLogin': null,
    },
  };

  /// LOGIN
  static Future<AuthResult> login(String email, String password) async {
    try {
      await Future.delayed(Duration(milliseconds: 800));

      if (email.isEmpty || password.isEmpty) {
        return AuthResult.failure("Please fill in all fields");
      }

      final emailKey = email.toLowerCase().trim();
      if (!_mockUsers.containsKey(emailKey)) {
        return AuthResult.failure("User not found");
      }

      final userData = _mockUsers[emailKey]!;
      if (!userData['isActive']) {
        return AuthResult.failure("Account is deactivated. Contact admin.");
      }

      if (userData['password'] != password) {
        return AuthResult.failure("Invalid password");
      }

      // ✅ Use DateTime.now() instead of createdAt
      _currentUser = User(
        id: userData['id'],
        username: userData['username'],
        email: userData['email'],
        buildingNumber: userData['buildingNumber'],
        mobileNumber: userData['mobileNumber'],
        role: userData['role'],
        createdAt: DateTime.now(),
      );

      _mockUsers[emailKey]!['lastLogin'] = DateTime.now().toIso8601String();
      _authStateController.add(_currentUser);

      return AuthResult.success(_currentUser!, "Login successful");
    } catch (e) {
      return AuthResult.failure("Login failed. Please try again later.");
    }
  }

  /// REGISTER
  static Future<AuthResult> register(
      String username, String email, String buildingNumber, String password) async {
    try {
      await Future.delayed(Duration(milliseconds: 1200));

      if (username.isEmpty ||
          email.isEmpty ||
          buildingNumber.isEmpty ||
          password.isEmpty) {
        return AuthResult.failure("Please fill in all fields");
      }

      final emailKey = email.toLowerCase().trim();
      if (_mockUsers.containsKey(emailKey)) {
        return AuthResult.failure("Email already exists");
      }

      final String newUserId = DateTime.now().millisecondsSinceEpoch.toString();

      final newUserData = {
        'id': newUserId,
        'username': username.trim(),
        'email': emailKey,
        'buildingNumber': buildingNumber.toUpperCase().trim(),
        'mobileNumber': '',
        'role': UserRole.user,
        'password': password,
        'isActive': true,
        'lastLogin': null,
      };

      _mockUsers[emailKey] = newUserData;

      _currentUser = User(
        id: newUserData['id'] as String,
        username: newUserData['username'] as String,
        email: newUserData['email'] as String,
        buildingNumber: newUserData['buildingNumber'] as String,
        mobileNumber: newUserData['mobileNumber'] as String,
        role: newUserData['role'] as UserRole,
        createdAt: DateTime.now(), // ✅ always set now
      );

      _authStateController.add(_currentUser);

      return AuthResult.success(_currentUser!, "Registration successful!");
    } catch (e) {
      return AuthResult.failure("Registration failed. Please try again.");
    }
  }

  /// LOGOUT
  static Future<void> logout() async {
    await Future.delayed(Duration(milliseconds: 300));
    _currentUser = null;
    _authStateController.add(null);
  }

  /// GET ALL USERS (Admin only)
  static Future<List<User>> getAllUsers() async {
    if (!isAdmin) throw Exception("Access denied. Admin only.");
    await Future.delayed(Duration(milliseconds: 500));
    return _mockUsers.values.map((u) {
      return User(
        id: u['id'],
        username: u['username'],
        email: u['email'],
        buildingNumber: u['buildingNumber'],
        mobileNumber: u['mobileNumber'],
        role: u['role'],
        createdAt: DateTime.now(), // ✅ fallback
      );
    }).toList();
  }

  static void dispose() {
    _authStateController.close();
  }
}

/// Auth result wrapper
class AuthResult {
  final bool isSuccess;
  final String message;
  final User? user;

  AuthResult._(this.isSuccess, this.message, this.user);

  factory AuthResult.success(User? user, String msg) =>
      AuthResult._(true, msg, user);

  factory AuthResult.failure(String msg) => AuthResult._(false, msg, null);

  @override
  String toString() =>
      "AuthResult(success: $isSuccess, message: $message, user: ${user?.username})";
}

